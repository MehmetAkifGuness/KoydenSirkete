import '../entities/company_competition_state.dart';
import '../entities/company_rival_progress.dart';
import 'company_market_service.dart';
import 'company_season_rule_service.dart';

class CompanyRivalProgressService {
  const CompanyRivalProgressService({
    this.seasonRuleService = const CompanySeasonRuleService(),
  });

  final CompanySeasonRuleService seasonRuleService;

  CompanyRivalProgress progressFor(
    CompanyCompetitor competitor, {
    required int seasonNumber,
    required int throughDay,
  }) {
    final season = seasonNumber.clamp(1, 10000).toInt();
    final startDay = CompanyCompetitionState.startDay(season);
    final endDay = CompanyCompetitionState.endDay(season);
    final lastDay = throughDay.clamp(startDay - 1, endDay).toInt();
    final elapsedDays = lastDay < startDay ? 0 : lastDay - startDay + 1;
    final startingBranches =
        1 + competitor.baseStrength ~/ 24 + (season - 1) ~/ 2;
    final startingEmployees =
        4 + competitor.baseStrength ~/ 5 + (season - 1) * 2;
    final startingFunds =
        10000 + competitor.baseStrength * 450 + (season - 1) * 5000;
    final startingCompleted = competitor.baseStrength ~/ 24 + season - 1;
    var branches = startingBranches;
    var employees = startingEmployees;
    var funds = startingFunds;
    var completedProjects = startingCompleted;
    var projectProgress = (competitor.baseStrength * 3 + season * 11) % 70;
    final hiringInterval = competitor.hiringIntervalDays
        .clamp(1, CompanyCompetitionState.seasonDurationDays)
        .toInt();
    final branchInterval = competitor.branchIntervalDays
        .clamp(1, CompanyCompetitionState.seasonDurationDays)
        .toInt();
    final seasonRule = seasonRuleService.ruleForSeason(season);
    final seasonStrengthModifier = seasonRuleService.competitorStrengthModifier(
      competitor,
      seasonRule,
    );

    for (var elapsed = 1; elapsed <= elapsedDays; elapsed++) {
      final day = startDay + elapsed - 1;
      final event = CompanyMarketService.eventForDay(day);
      final profileModifier = CompanyMarketService.competitorProfileModifier(
        competitor,
        event,
      );
      final marketPercent =
          event.revenuePercent -
          event.payrollPercent +
          seasonRule.revenuePercent -
          seasonRule.payrollPercent;
      final variation =
          (day * 11 + competitor.baseStrength * 7 + season * 5) % 81 - 40;
      funds +=
          competitor.dailyFinanceGrowth * (100 + marketPercent) ~/ 100 +
          profileModifier * 8 +
          seasonStrengthModifier * 4 +
          variation;

      if (elapsed % hiringInterval == 0) {
        employees++;
        funds -= 300 + competitor.baseStrength * 2;
      }
      if (elapsed % branchInterval == 0) {
        branches++;
        employees += 2;
        funds -= 2000 + competitor.baseStrength * 20;
      }

      final profileProjectEffect = profileModifier > 0
          ? 1
          : profileModifier < 0
          ? -1
          : 0;
      projectProgress +=
          competitor.dailyProjectProgress +
          profileProjectEffect +
          (seasonStrengthModifier > 0 ? 1 : 0) +
          ((day + competitor.baseStrength) % 4 == 0 ? 1 : 0);
      while (projectProgress >= 100) {
        projectProgress -= 100;
        completedProjects++;
      }
    }

    return CompanyRivalProgress(
      competitor: competitor,
      seasonNumber: season,
      elapsedDays: elapsedDays,
      startingBranchCount: startingBranches,
      branchCount: branches,
      startingEmployeeCount: startingEmployees,
      employeeCount: employees,
      startingCompanyFunds: startingFunds,
      companyFunds: funds.clamp(0, 1 << 62).toInt(),
      startingCompletedProjects: startingCompleted,
      completedProjects: completedProjects,
      projectProgress: projectProgress.clamp(0, 99).toInt(),
    );
  }
}
