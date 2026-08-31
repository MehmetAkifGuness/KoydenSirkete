import '../../../../core/errors/game_rule_exception.dart';
import '../../../finance/domain/entities/finance_ledger.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../../economy/domain/entities/economy_difficulty.dart';
import '../entities/company_decision.dart';
import '../entities/company_employee.dart';
import '../entities/company_market_event.dart';
import 'company_finance_recorder.dart';
import 'company_season_event_service.dart';

class CompanyDecisionService {
  const CompanyDecisionService();

  static const maxResolvedDecisions = 1000;
  static const choices = <CompanyDecisionChoice>[
    CompanyDecisionChoice(
      id: 'growth',
      title: 'Hızlı büyü',
      description: 'Fırsatı projeye çevir; ekip daha yoğun çalışsın.',
      costPerLevel: 120,
      projectProgress: 8,
      reputation: 2,
      morale: -3,
      burnout: 4,
    ),
    CompanyDecisionChoice(
      id: 'people',
      title: 'Ekibi koru',
      description:
          'Çalışan desteğine yatırım yap; sürdürülebilirliği güçlendir.',
      costPerLevel: 80,
      projectProgress: 2,
      reputation: 1,
      morale: 7,
      burnout: -5,
    ),
    CompanyDecisionChoice(
      id: 'cautious',
      title: 'Temkinli kal',
      description: 'Kasayı koru; ekibe kısa bir nefes alanı aç.',
      costPerLevel: 0,
      projectProgress: 0,
      reputation: 0,
      morale: 2,
      burnout: -1,
    ),
  ];

  CompanyDecision current(PlayerState state) {
    final season = state.companyCompetition.seasonNumber;
    final slots = const CompanySeasonEventService().slotsForSeason(season);
    final slot = slots.firstWhere(
      (item) => item.contains(state.day),
      orElse: () => slots.first,
    );
    return CompanyDecision(
      key: '$season:${slot.index}:${slot.event.id}',
      title: _titleFor(slot.event.category),
      description: slot.event.description,
      event: slot.event,
      choices: choices,
    );
  }

  bool isResolved(PlayerState state) => state
      .companyCompetition
      .resolvedDecisionKeys
      .contains(current(state).key);

  int cost(PlayerState state, CompanyDecisionChoice choice) =>
      choice.costPerLevel * state.companyLevel.clamp(1, 10);

  String? hardModeRewardPreview(
    PlayerState state,
    CompanyDecisionChoice choice,
  ) {
    if (state.economyDifficulty != EconomyDifficulty.hard ||
        choice.id != _recommendedChoiceId(current(state).event.category)) {
      return null;
    }
    return 'Doğru kriz hamlesi: kasa +₺${state.companyLevel.clamp(1, 10) * 800}, proje +5, itibar +3';
  }

  PlayerState resolve(PlayerState state, CompanyDecisionChoice choice) {
    if (state.companyLevel == 0) {
      throw const GameRuleException('Önce şirketini kurmalısın.');
    }
    final decision = current(state);
    if (isResolved(state)) {
      throw const GameRuleException('Bu dönem için kararını zaten verdin.');
    }
    if (!choices.any((item) => item.id == choice.id)) {
      throw const GameRuleException('Geçersiz şirket kararı.');
    }
    final expense = cost(state, choice);
    if (state.companyFunds < expense) {
      throw GameRuleException(
        'Bu karar için şirket kasasında ₺$expense gerekli.',
      );
    }
    final decisionKeys = [
      ...state.companyCompetition.resolvedDecisionKeys,
      decision.key,
    ];
    final correctHardChoice =
        state.economyDifficulty == EconomyDifficulty.hard &&
        choice.id == _recommendedChoiceId(decision.event.category);
    final hardFundsReward = correctHardChoice
        ? state.companyLevel.clamp(1, 10) * 800
        : 0;
    final hardProjectReward = correctHardChoice ? 5 : 0;
    final hardReputationReward = correctHardChoice ? 3 : 0;
    final competition = state.companyCompetition.copyWith(
      resolvedDecisionKeys: decisionKeys.length <= maxResolvedDecisions
          ? decisionKeys
          : decisionKeys.sublist(decisionKeys.length - maxResolvedDecisions),
      lastDecisionChoiceId: choice.id,
      decisionReputation:
          (state.companyCompetition.decisionReputation +
                  choice.reputation +
                  hardReputationReward)
              .clamp(0, 100),
    );
    return state.copyWith(
      companyFunds: state.companyFunds - expense + hardFundsReward,
      projectProgress:
          (state.projectProgress + choice.projectProgress + hardProjectReward)
              .clamp(0, 99),
      employees: [
        for (final employee in state.employees) _affect(employee, choice),
      ],
      branches: [
        for (final branch in state.branches)
          branch.copyWith(
            employees: [
              for (final employee in branch.employees)
                _affect(employee, choice),
            ],
          ),
      ],
      companyCompetition: competition,
      financeLedger: CompanyFinanceRecorder.record(
        state,
        FinanceCategory.companyMarket,
        hardFundsReward - expense,
      ),
    );
  }

  CompanyEmployee _affect(
    CompanyEmployee employee,
    CompanyDecisionChoice choice,
  ) => employee.copyWith(
    morale: (employee.morale + choice.morale).clamp(0, 100),
    burnout: (employee.burnout + choice.burnout).clamp(0, 100),
  );

  String _titleFor(CompanyMarketEventCategory category) => switch (category) {
    CompanyMarketEventCategory.opportunity => 'Büyüme fırsatı',
    CompanyMarketEventCategory.threat => 'Piyasa baskısı',
    CompanyMarketEventCategory.workforce => 'Ekip gündemi',
    CompanyMarketEventCategory.stable => 'Yönetim kurulu kararı',
  };

  String _recommendedChoiceId(CompanyMarketEventCategory category) =>
      switch (category) {
        CompanyMarketEventCategory.opportunity => 'growth',
        CompanyMarketEventCategory.threat => 'cautious',
        CompanyMarketEventCategory.workforce => 'people',
        CompanyMarketEventCategory.stable => 'cautious',
      };
}
