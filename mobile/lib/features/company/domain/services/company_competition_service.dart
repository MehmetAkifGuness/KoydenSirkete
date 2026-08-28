import '../../../finance/domain/entities/finance_ledger.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/company_competition_state.dart';
import '../entities/company_season_trophy.dart';
import 'company_finance_recorder.dart';
import 'company_market_service.dart';
import 'company_rival_progress_service.dart';
import 'company_season_reward_service.dart';
import 'company_season_rule_service.dart';
import 'company_trophy_service.dart';

class CompanySeasonStanding {
  const CompanySeasonStanding({
    required this.rank,
    required this.name,
    required this.points,
    required this.isPlayer,
    required this.strength,
  });

  final int rank;
  final String name;
  final int points;
  final bool isPlayer;
  final int strength;

  CompanySeasonStanding withRank(int value) => CompanySeasonStanding(
    rank: value,
    name: name,
    points: points,
    isPlayer: isPlayer,
    strength: strength,
  );
}

class CompanyCompetitionResult {
  const CompanyCompetitionResult({required this.state, required this.messages});

  final PlayerState state;
  final List<String> messages;
}

class CompanyCompetitionService {
  static const _playerName = 'Senin şirketin';
  static const rewards = <int>[6000, 3000, 1500];

  CompanyCompetitionService({
    CompanyRivalProgressService? rivalProgressService,
    CompanySeasonRewardService? seasonRewardService,
    CompanySeasonRuleService? seasonRuleService,
  }) : _rivalProgressService =
           rivalProgressService ??
           CompanyRivalProgressService(
             seasonRuleService:
                 seasonRuleService ?? const CompanySeasonRuleService(),
           ),
       _seasonRuleService =
           seasonRuleService ?? const CompanySeasonRuleService(),
       _seasonRewardService =
           seasonRewardService ?? const CompanySeasonRewardService();

  final CompanyRivalProgressService _rivalProgressService;
  final CompanySeasonRuleService _seasonRuleService;
  final CompanySeasonRewardService _seasonRewardService;

  PlayerState initialize(PlayerState state) => state.copyWith(
    companyCompetition: CompanyCompetitionState.forDay(state.day),
  );

  int rewardForRank(int rank) =>
      rank >= 1 && rank <= rewards.length ? rewards[rank - 1] : 0;

  List<CompanySeasonStanding> standings(
    PlayerState state, {
    CompanyCompetitionState? competition,
    int? throughDay,
  }) {
    final season = competition ?? state.companyCompetition;
    final endDay = CompanyCompetitionState.endDay(season.seasonNumber);
    final lastDay = (throughDay ?? state.day).clamp(
      CompanyCompetitionState.startDay(season.seasonNumber) - 1,
      endDay,
    );
    final entries = <CompanySeasonStanding>[
      CompanySeasonStanding(
        rank: 0,
        name: _playerName,
        points: season.points,
        isPlayer: true,
        strength: CompanyMarketService().forecast(state).playerScore,
      ),
      for (final competitor in CompanyMarketService.competitors)
        CompanySeasonStanding(
          rank: 0,
          name: competitor.name,
          points: _rivalPoints(competitor, season.seasonNumber, lastDay),
          isPlayer: false,
          strength: rivalStrength(competitor, season.seasonNumber, lastDay),
        ),
    ];
    entries.sort((left, right) {
      final pointOrder = right.points.compareTo(left.points);
      return pointOrder != 0 ? pointOrder : left.name.compareTo(right.name);
    });
    return [
      for (var index = 0; index < entries.length; index++)
        entries[index].withRank(index + 1),
    ];
  }

  CompanyCompetitionResult process(
    PlayerState state,
    List<DailyMarketOutcome> outcomes,
  ) {
    if (state.companyLevel == 0) {
      return CompanyCompetitionResult(state: state, messages: const []);
    }
    var current = state;
    var competition = state.companyCompetition;
    final messages = <String>[];
    for (final outcome in outcomes) {
      final targetSeason = CompanyCompetitionState.seasonForDay(outcome.day);
      while (competition.seasonNumber < targetSeason) {
        final settlement = _settle(current, competition);
        current = settlement.state;
        competition = settlement.competition;
        messages.add(settlement.message);
      }
      competition = competition.copyWith(
        points: competition.points + (outcome.won ? 3 : 0),
        wins: competition.wins + (outcome.won ? 1 : 0),
        losses: competition.losses + (outcome.won ? 0 : 1),
      );
      current = current.copyWith(companyCompetition: competition);
    }
    final targetSeason = CompanyCompetitionState.seasonForDay(state.day);
    while (competition.seasonNumber < targetSeason) {
      final settlement = _settle(current, competition);
      current = settlement.state;
      competition = settlement.competition;
      messages.add(settlement.message);
    }
    return CompanyCompetitionResult(state: current, messages: messages);
  }

  _SeasonSettlement _settle(
    PlayerState state,
    CompanyCompetitionState competition,
  ) {
    final table = standings(
      state,
      competition: competition,
      throughDay: CompanyCompetitionState.endDay(competition.seasonNumber),
    );
    final rank = table.firstWhere((entry) => entry.isPlayer).rank;
    final reward = rewardForRank(rank);
    final seasonReward = _seasonRewardService.rewardFor(
      seasonNumber: competition.seasonNumber,
      rank: rank,
    );
    final trophies = _normalizedTrophies(competition);
    final wonChampionship = rank == 1;
    final trophyCount = trophies.length + (wonChampionship ? 1 : 0);
    if (wonChampionship) {
      trophies.add(
        CompanySeasonTrophy(
          seasonNumber: competition.seasonNumber,
          points: competition.points,
          reward: reward,
        ),
      );
    }
    final nextCompetition = CompanyCompetitionState(
      seasonNumber: competition.seasonNumber + 1,
      championships: trophyCount,
      bestRank: competition.bestRank == 0
          ? rank
          : competition.bestRank.clamp(1, rank),
      lastRank: rank,
      lastReward: reward,
      trophies: List<CompanySeasonTrophy>.unmodifiable(trophies),
      seasonRewards: List.unmodifiable([
        ...competition.seasonRewards,
        seasonReward,
      ]),
    );
    final nextState = state.copyWith(
      companyFunds: state.companyFunds + reward,
      companyCompetition: nextCompetition,
      financeLedger: CompanyFinanceRecorder.record(
        state,
        FinanceCategory.companySeason,
        reward,
      ),
    );
    final unlockedBenefit = wonChampionship
        ? CompanyTrophyService.benefitUnlockedAt(trophyCount)
        : null;
    final baseMessage = reward > 0
        ? '${competition.seasonNumber}. sezonu $rank. bitirdin. '
              'Şirket kasasına ₺$reward ödül eklendi.'
        : '${competition.seasonNumber}. sezonu $rank. bitirdin. '
              'Bu sezon derece ödülü kazanamadın.';
    return _SeasonSettlement(
      state: nextState,
      competition: nextCompetition,
      message:
          '$baseMessage'
          ' ${seasonReward.title}: ${seasonReward.description}.'
          '${wonChampionship ? ' Şampiyonluk kupa geçmişine işlendi.' : ''}'
          '${unlockedBenefit == null ? '' : ' ${unlockedBenefit.title} avantajı açıldı.'}',
    );
  }

  List<CompanySeasonTrophy> _normalizedTrophies(
    CompanyCompetitionState competition,
  ) => [
    ...competition.trophies,
    for (
      var index = competition.trophies.length;
      index < competition.championships;
      index++
    )
      const CompanySeasonTrophy.imported(),
  ];

  int _rivalPoints(
    CompanyCompetitor competitor,
    int seasonNumber,
    int throughDay,
  ) {
    final start = CompanyCompetitionState.startDay(seasonNumber);
    if (throughDay < start) return 0;
    final seasonRule = _seasonRuleService.ruleForSeason(seasonNumber);
    final seasonRuleModifier = _seasonRuleService.competitorStrengthModifier(
      competitor,
      seasonRule,
    );
    var points = 0;
    for (var day = start; day <= throughDay; day++) {
      final event = CompanyMarketService.eventForDay(day);
      final profileModifier = CompanyMarketService.competitorProfileModifier(
        competitor,
        event,
      );
      final strength = rivalStrength(competitor, seasonNumber, day);
      final winChance = (30 + strength + profileModifier + seasonRuleModifier)
          .clamp(40, 90)
          .toInt();
      final roll =
          (day * 17 + competitor.baseStrength * 13 + seasonNumber * 19) % 100;
      if (roll < winChance) {
        points += 3;
      } else if (roll < winChance + 8) {
        points++;
      }
    }
    return points;
  }

  int rivalStrength(
    CompanyCompetitor competitor,
    int seasonNumber,
    int throughDay,
  ) {
    final progress = _rivalProgressService.progressFor(
      competitor,
      seasonNumber: seasonNumber,
      throughDay: throughDay,
    );
    return (competitor.baseStrength +
            (seasonNumber - 1) * 2 +
            progress.competitiveStrengthBonus)
        .clamp(0, 95)
        .toInt();
  }
}

class _SeasonSettlement {
  const _SeasonSettlement({
    required this.state,
    required this.competition,
    required this.message,
  });

  final PlayerState state;
  final CompanyCompetitionState competition;
  final String message;
}
