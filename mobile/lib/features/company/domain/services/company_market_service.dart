import 'dart:math' as math;

import '../../../game/domain/entities/player_state.dart';
import '../entities/company_competition_strategy.dart';
import '../entities/company_competitor.dart';
import '../entities/company_market_event.dart';
import '../entities/company_season_rule.dart';
import 'company_branch_service.dart';
import 'company_competitor_catalog.dart';
import 'company_competition_strategy_service.dart';
import 'company_finance_recorder.dart';
import 'company_market_event_catalog.dart';
import 'company_region_service.dart';
import 'company_season_event_service.dart';
import 'company_season_rule_service.dart';
import 'company_service.dart';
import 'company_trophy_service.dart';
import '../../../finance/domain/entities/finance_ledger.dart';

export '../entities/company_competitor.dart';
export '../entities/company_market_event.dart';

class CompanyMarketForecast {
  const CompanyMarketForecast({
    required this.event,
    required this.competitor,
    required this.playerScore,
    required this.competitorScore,
    required this.fundsDelta,
    required this.activeEmployeeCount,
    required this.daysRemaining,
    this.competitorProfileModifier = 0,
    this.competitorProfileReason = 'Bu koşulda özel profil etkisi yok.',
    this.seasonRule = const CompanySeasonRule.neutral(),
    this.playerSeasonRuleModifier = 0,
    this.competitorSeasonRuleModifier = 0,
    this.strategy = const CompanyCompetitionStrategy.neutral(),
    this.strategyStrengthModifier = 0,
    this.strategyReason = 'Bu sezon için strateji avantajı yok.',
  });

  final CompanyMarketEvent event;
  final CompanyCompetitor competitor;
  final int playerScore;
  final int competitorScore;
  final int fundsDelta;
  final int activeEmployeeCount;
  final int daysRemaining;
  final int competitorProfileModifier;
  final String competitorProfileReason;
  final CompanySeasonRule seasonRule;
  final int playerSeasonRuleModifier;
  final int competitorSeasonRuleModifier;
  final CompanyCompetitionStrategy strategy;
  final int strategyStrengthModifier;
  final String strategyReason;

  bool get won => playerScore >= competitorScore;
  int get totalRevenuePercent =>
      event.revenuePercent +
      seasonRule.revenuePercent +
      strategy.revenuePercent;
  int get totalPayrollPercent =>
      event.payrollPercent +
      seasonRule.payrollPercent +
      strategy.payrollPercent;
}

class DailyMarketOutcome {
  const DailyMarketOutcome({
    required this.day,
    required this.forecast,
    required this.actualFundsDelta,
  });

  final int day;
  final CompanyMarketForecast forecast;
  final int actualFundsDelta;

  bool get won => forecast.won;
}

class CompanyMarketOperationResult {
  const CompanyMarketOperationResult({
    required this.state,
    required this.outcomes,
    required this.messages,
  });

  final PlayerState state;
  final List<DailyMarketOutcome> outcomes;
  final List<String> messages;
}

class CompanyMarketService {
  static const competitorSectorBonus = 4;
  CompanyMarketService({
    CompanyService? companyService,
    CompanyBranchService? branchService,
    CompanyRegionService? regionService,
    CompanySeasonRuleService? seasonRuleService,
    CompanySeasonEventService? seasonEventService,
    CompanyCompetitionStrategyService? strategyService,
  }) : _companyService = companyService ?? CompanyService(),
       _branchService = branchService ?? CompanyBranchService(),
       _regionService = regionService ?? CompanyRegionService(),
       _seasonRuleService =
           seasonRuleService ?? const CompanySeasonRuleService(),
       _seasonEventService =
           seasonEventService ?? const CompanySeasonEventService(),
       _strategyService =
           strategyService ?? const CompanyCompetitionStrategyService();

  static const eventDurationDays = CompanySeasonEventService.eventDurationDays;
  static const events = CompanyMarketEventCatalog.events;
  static const competitors = CompanyCompetitorCatalog.competitors;

  static CompanyMarketEvent eventForDay(int day) =>
      const CompanySeasonEventService().eventForDay(day);

  static int competitorProfileModifier(
    CompanyCompetitor competitor,
    CompanyMarketEvent event,
  ) {
    var modifier = competitor.specialty == event.specialty
        ? competitorSectorBonus
        : 0;
    if (competitor.strongEventId == event.id) {
      modifier += competitor.strongEventBonus;
    }
    if (competitor.weakEventId == event.id) {
      modifier -= competitor.weakEventPenalty;
    }
    return modifier;
  }

  static String competitorProfileReason(
    CompanyCompetitor competitor,
    CompanyMarketEvent event,
  ) {
    final reasons = <String>[];
    if (competitor.specialty == event.specialty) {
      reasons.add(
        '${competitor.specialty.label} uzmanlığı +$competitorSectorBonus',
      );
    }
    if (competitor.strongEventId == event.id) {
      reasons.add(
        '${competitor.strengthTitle} +${competitor.strongEventBonus}',
      );
    }
    if (competitor.weakEventId == event.id) {
      reasons.add(
        '${competitor.weaknessTitle} -${competitor.weakEventPenalty}',
      );
    }
    return reasons.isEmpty
        ? 'Bu piyasa koşulunda özel profil etkisi yok.'
        : reasons.join(' · ');
  }

  final CompanyService _companyService;
  final CompanyBranchService _branchService;
  final CompanyRegionService _regionService;
  final CompanySeasonRuleService _seasonRuleService;
  final CompanySeasonEventService _seasonEventService;
  final CompanyCompetitionStrategyService _strategyService;

  CompanyMarketForecast forecast(PlayerState state, {int? day}) {
    final currentDay = day ?? state.day;
    final event = _seasonEventService.eventForDay(currentDay);
    final seasonRule = _seasonRuleService.ruleForDay(currentDay);
    final competitorIndex =
        ((currentDay - 1) ~/ 3 + state.companyLevel + state.branches.length) %
        competitors.length;
    final competitor = competitors[competitorIndex];
    final strategy = _strategyService.selectedFor(state);
    final strategyEffect = _strategyService.effectFor(
      state,
      strategy,
      competitor,
    );
    final employees = [
      ...CompanyService.employeesFor(state),
      for (final branch in state.branches) ...branch.employees,
    ];
    final averagePerformance = employees.isEmpty
        ? 0
        : employees.fold<int>(
                0,
                (total, employee) => total + employee.effectivePerformance,
              ) ~/
              employees.length;
    final playerVariation =
        (currentDay * 7 + state.companyFunds + state.completedProjects) % 11;
    final competitorVariation =
        (currentDay * 13 + competitor.baseStrength * 7) % 11;
    final playerSeasonRuleModifier = _seasonRuleService
        .employeeStrengthModifier(employees, seasonRule);
    final competitorSeasonRuleModifier = _seasonRuleService
        .competitorStrengthModifier(competitor, seasonRule);
    final playerScore =
        (state.companyLevel * 15 +
                averagePerformance ~/ 4 +
                state.branches.length * 6 +
                state.completedProjects.clamp(0, 20) +
                CompanyTrophyService.marketScoreBonus(state) +
                playerSeasonRuleModifier +
                strategyEffect.strengthModifier +
                playerVariation)
            .clamp(0, 100)
            .toInt();
    final profileModifier = competitorProfileModifier(competitor, event);
    final competitorScore =
        (competitor.baseStrength +
                competitorVariation +
                profileModifier +
                competitorSeasonRuleModifier)
            .clamp(0, 100)
            .toInt();
    final revenue = _totalRevenue(state);
    final payroll = _totalPayroll(state);
    final eventDelta =
        revenue *
            (event.revenuePercent +
                seasonRule.revenuePercent +
                strategy.revenuePercent) ~/
            100 -
        payroll *
            (event.payrollPercent +
                seasonRule.payrollPercent +
                strategy.payrollPercent) ~/
            100;
    final stake = math.max(20, revenue * 12 ~/ 100);
    final competitionDelta = playerScore >= competitorScore
        ? stake
        : -(stake ~/ 2);
    final fundsDelta = eventDelta + competitionDelta;
    final marketBonus = fundsDelta > 0 ? _regionService.marketBonus(state) : 0;
    return CompanyMarketForecast(
      event: event,
      competitor: competitor,
      playerScore: playerScore,
      competitorScore: competitorScore,
      fundsDelta: employees.isEmpty
          ? 0
          : (fundsDelta * (100 + marketBonus) / 100).round(),
      activeEmployeeCount: employees.length,
      daysRemaining: _seasonEventService.daysRemainingForDay(currentDay),
      competitorProfileModifier: profileModifier,
      competitorProfileReason: competitorProfileReason(competitor, event),
      seasonRule: seasonRule,
      playerSeasonRuleModifier: playerSeasonRuleModifier,
      competitorSeasonRuleModifier: competitorSeasonRuleModifier,
      strategy: strategy,
      strategyStrengthModifier: strategyEffect.strengthModifier,
      strategyReason: strategyEffect.reason,
    );
  }

  CompanyMarketOperationResult process(PlayerState state, {int days = 1}) {
    if (state.companyLevel == 0 || days < 1) {
      return CompanyMarketOperationResult(
        state: state,
        outcomes: const [],
        messages: const [],
      );
    }
    var current = state;
    final outcomes = <DailyMarketOutcome>[];
    final messages = <String>[];
    for (var index = 0; index < days; index++) {
      final day = math.max(1, state.day - days + 1 + index);
      final market = forecast(current, day: day);
      if (market.activeEmployeeCount == 0) continue;
      final nextFunds = (current.companyFunds + market.fundsDelta)
          .clamp(0, 1 << 62)
          .toInt();
      final actualDelta = nextFunds - current.companyFunds;
      current = current.copyWith(
        companyFunds: nextFunds,
        financeLedger: CompanyFinanceRecorder.record(
          current,
          FinanceCategory.companyMarket,
          actualDelta,
        ),
      );
      outcomes.add(
        DailyMarketOutcome(
          day: day,
          forecast: market,
          actualFundsDelta: actualDelta,
        ),
      );
      messages.add(
        '${market.event.title}: ${market.competitor.name} karşısında '
        '${market.won ? 'pazar payı kazandın' : 'pazar kaybettin'} '
        '(${_signed(actualDelta)}).',
      );
    }
    return CompanyMarketOperationResult(
      state: current,
      outcomes: outcomes,
      messages: messages,
    );
  }

  int _totalRevenue(PlayerState state) =>
      _companyService.dailyRevenue(state) +
      state.branches.fold<int>(
        0,
        (total, branch) =>
            total + _branchService.dailyRevenueFor(state, branch),
      );

  int _totalPayroll(PlayerState state) =>
      _companyService.dailyPayroll(state) +
      state.branches.fold<int>(
        0,
        (total, branch) =>
            total + _branchService.dailyPayrollFor(state, branch),
      );

  String _signed(int value) => '${value >= 0 ? '+' : '-'}₺${value.abs()}';
}
