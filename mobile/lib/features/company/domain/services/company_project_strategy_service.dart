import 'dart:math' as math;

import '../../../game/domain/entities/player_state.dart';
import '../entities/company_employee.dart';
import '../entities/company_project.dart';
import '../entities/company_project_outcome.dart';
import '../entities/company_specialty.dart';
import 'company_budget_service.dart';
import 'company_region_service.dart';
import 'company_trophy_service.dart';

class CompanyProjectForecast {
  const CompanyProjectForecast({
    required this.dailyProgress,
    required this.estimatedDays,
    required this.successChance,
    required this.specialistCount,
    required this.delayChance,
    required this.expectedQuality,
  });

  final int dailyProgress;
  final int estimatedDays;
  final int successChance;
  final int specialistCount;
  final int delayChance;
  final CompanyProjectQuality expectedQuality;
}

class CompanyProjectStrategyService {
  CompanyProjectStrategyService({
    CompanyRegionService? regionService,
    CompanyBudgetService? budgetService,
  }) : _regionService = regionService ?? CompanyRegionService(),
       _budgetService = budgetService ?? const CompanyBudgetService();

  static const specialistProgressBonusPercent = 35;
  static const specialistRiskReductionPercent = 5;
  final CompanyRegionService _regionService;
  final CompanyBudgetService _budgetService;

  CompanyProjectForecast forecast({
    required PlayerState state,
    required CompanyProject project,
    required List<CompanyEmployee> employees,
  }) {
    if (employees.isEmpty) {
      return CompanyProjectForecast(
        dailyProgress: 0,
        estimatedDays: 0,
        successChance: _successChance(state, project, employees),
        specialistCount: 0,
        delayChance: 90,
        expectedQuality: CompanyProjectQuality.low,
      );
    }
    final specialists = employees
        .where((employee) => employee.specialty == project.specialty)
        .length;
    final employeeProgress = employees.fold<int>(0, (total, employee) {
      final base = math.max(
        1,
        (project.progressPerEmployee * employee.effectivePerformance / 100)
            .round(),
      );
      final fitAdjusted = base <= 2
          ? base
          : math.max(
              1,
              (base *
                      (50 + employee.jobFitPercentFor(project.specialty) / 2) /
                      100)
                  .ceil(),
            );
      final progress = employee.specialty == project.specialty
          ? (fitAdjusted * (100 + specialistProgressBonusPercent) / 100).ceil()
          : fitAdjusted;
      return total + progress;
    });
    final levelMultiplier = 1 + math.max(0, state.companyLevel - 1) * .10;
    final dailyProgress = math.max(
      1,
      (employeeProgress * levelMultiplier).round() +
          _regionService.projectProgressBonusFor(state) +
          _budgetService.researchProgressBonus(state),
    );
    final remaining = math.max(0, 100 - state.projectProgress);
    final estimatedDays = (remaining / dailyProgress).ceil();
    final estimatedCompletionDays = state.projectElapsedDays + estimatedDays;
    return CompanyProjectForecast(
      dailyProgress: dailyProgress,
      estimatedDays: estimatedDays,
      successChance: _successChance(state, project, employees),
      specialistCount: specialists,
      delayChance: _delayChance(
        state,
        project,
        employees,
        estimatedCompletionDays,
      ),
      expectedQuality: _qualityFor(
        state,
        project,
        employees,
        delayed: estimatedCompletionDays > project.deliveryDays,
      ),
    );
  }

  bool succeeds({
    required PlayerState state,
    required CompanyProject project,
    required List<CompanyEmployee> employees,
  }) {
    final chance = _successChance(state, project, employees);
    final seed =
        state.day * 37 +
        state.companyFunds * 3 +
        state.completedProjects * 101 +
        project.id * 53;
    return seed.abs() % 100 < chance;
  }

  CompanyProjectOutcome resolveOutcome({
    required PlayerState state,
    required CompanyProject project,
    required List<CompanyEmployee> employees,
    required bool succeeded,
    required int elapsedDays,
  }) {
    final seed =
        state.day * 43 +
        state.companyFunds * 7 +
        state.completedProjects * 109 +
        project.id * 61 +
        elapsedDays * 17;
    final delayed =
        elapsedDays > project.deliveryDays ||
        seed.abs() % 100 < _delayChance(state, project, employees, elapsedDays);
    final quality = succeeded
        ? _qualityFor(
            state,
            project,
            employees,
            delayed: delayed,
            variance: (seed.abs() ~/ 100) % 17 - 8,
          )
        : CompanyProjectQuality.rejected;
    final grossReward = succeeded
        ? (project.reward *
                  quality.rewardPercent /
                  100 *
                  (delayed ? 90 : 100) /
                  100)
              .round()
        : 0;
    return CompanyProjectOutcome(
      projectId: project.id,
      completedDay: state.day,
      elapsedDays: elapsedDays,
      delayed: delayed,
      succeeded: succeeded,
      quality: quality,
      netIncome: succeeded ? grossReward - project.cost : -project.cost,
    );
  }

  int _successChance(
    PlayerState state,
    CompanyProject project,
    List<CompanyEmployee> employees,
  ) {
    final specialists = employees
        .where((employee) => employee.specialty == project.specialty)
        .length;
    final averagePerformance = employees.isEmpty
        ? 0
        : employees.fold<int>(
                0,
                (total, item) => total + item.effectivePerformance,
              ) ~/
              employees.length;
    final levelGap = math.max(
      0,
      project.recommendedCompanyLevel - state.companyLevel,
    );
    final levelAdvantage = math.max(
      0,
      state.companyLevel - project.recommendedCompanyLevel,
    );
    final performanceReduction = math.max(0, averagePerformance - 60) ~/ 8;
    final effectiveRisk =
        (project.riskPercent +
                levelGap * 10 -
                levelAdvantage * 4 -
                specialists * specialistRiskReductionPercent -
                performanceReduction -
                _budgetService.projectRiskReduction(state))
            .clamp(5, 75);
    return (100 -
            effectiveRisk +
            _regionService.projectSuccessBonusFor(state) +
            CompanyTrophyService.projectSuccessBonus(state))
        .clamp(0, 100)
        .toInt();
  }

  int _delayChance(
    PlayerState state,
    CompanyProject project,
    List<CompanyEmployee> employees,
    int estimatedCompletionDays,
  ) {
    if (employees.isEmpty) return 90;
    final specialists = employees
        .where((employee) => employee.specialty == project.specialty)
        .length;
    final averagePerformance =
        employees.fold<int>(
          0,
          (total, employee) => total + employee.effectivePerformance,
        ) ~/
        employees.length;
    final levelGap = math.max(
      0,
      project.recommendedCompanyLevel - state.companyLevel,
    );
    final scheduleOverrun = math.max(
      0,
      estimatedCompletionDays - project.deliveryDays,
    );
    final performanceReduction = math.max(0, averagePerformance - 55) ~/ 5;
    final fitPenalty = (100 - _averageJobFit(employees, project)) ~/ 8;
    return (project.delayRiskPercent +
            levelGap * 8 +
            scheduleOverrun * 10 -
            specialists * 4 -
            performanceReduction +
            fitPenalty -
            _budgetService.projectRiskReduction(state))
        .clamp(5, 90)
        .toInt();
  }

  CompanyProjectQuality _qualityFor(
    PlayerState state,
    CompanyProject project,
    List<CompanyEmployee> employees, {
    required bool delayed,
    int variance = 0,
  }) {
    if (employees.isEmpty) return CompanyProjectQuality.low;
    final specialists = employees
        .where((employee) => employee.specialty == project.specialty)
        .length;
    final averagePerformance =
        employees.fold<int>(
          0,
          (total, employee) => total + employee.effectivePerformance,
        ) ~/
        employees.length;
    final levelGap = math.max(
      0,
      project.recommendedCompanyLevel - state.companyLevel,
    );
    final levelAdvantage = math.max(
      0,
      state.companyLevel - project.recommendedCompanyLevel,
    );
    final score =
        averagePerformance +
        math.min(15, specialists * 5) +
        levelAdvantage * 4 -
        levelGap * 8 -
        (100 - _averageJobFit(employees, project)) ~/ 3 -
        (delayed ? 10 : 0) +
        variance;
    if (score >= 90) return CompanyProjectQuality.excellent;
    if (score >= 76) return CompanyProjectQuality.high;
    if (score >= 60) return CompanyProjectQuality.standard;
    return CompanyProjectQuality.low;
  }

  int _averageJobFit(List<CompanyEmployee> employees, CompanyProject project) =>
      employees.fold<int>(
        0,
        (total, employee) =>
            total + employee.jobFitPercentFor(project.specialty),
      ) ~/
      employees.length;
}
