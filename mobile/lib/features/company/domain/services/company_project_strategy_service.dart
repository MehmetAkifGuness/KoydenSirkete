import 'dart:math' as math;

import '../../../game/domain/entities/player_state.dart';
import '../entities/company_employee.dart';
import '../entities/company_project.dart';
import '../entities/company_specialty.dart';
import 'company_region_service.dart';
import 'company_trophy_service.dart';

class CompanyProjectForecast {
  const CompanyProjectForecast({
    required this.dailyProgress,
    required this.estimatedDays,
    required this.successChance,
    required this.specialistCount,
  });

  final int dailyProgress;
  final int estimatedDays;
  final int successChance;
  final int specialistCount;
}

class CompanyProjectStrategyService {
  CompanyProjectStrategyService({CompanyRegionService? regionService})
    : _regionService = regionService ?? CompanyRegionService();

  static const specialistProgressBonusPercent = 35;
  static const specialistRiskReductionPercent = 5;
  final CompanyRegionService _regionService;

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
      final progress = employee.specialty == project.specialty
          ? (base * (100 + specialistProgressBonusPercent) / 100).ceil()
          : base;
      return total + progress;
    });
    final levelMultiplier = 1 + math.max(0, state.companyLevel - 1) * .10;
    final dailyProgress = math.max(
      1,
      (employeeProgress * levelMultiplier).round() +
          _regionService.projectProgressBonusFor(state),
    );
    final remaining = math.max(0, 100 - state.projectProgress);
    return CompanyProjectForecast(
      dailyProgress: dailyProgress,
      estimatedDays: (remaining / dailyProgress).ceil(),
      successChance: _successChance(state, project, employees),
      specialistCount: specialists,
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
                performanceReduction)
            .clamp(5, 75);
    return (100 -
            effectiveRisk +
            _regionService.projectSuccessBonusFor(state) +
            CompanyTrophyService.projectSuccessBonus(state))
        .clamp(0, 100)
        .toInt();
  }
}
