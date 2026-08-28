import '../../../../core/errors/game_rule_exception.dart';
import '../../../cities/domain/entities/city.dart';
import '../../../cities/domain/services/city_catalog.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/company_branch.dart';
import '../entities/company_employee.dart';
import '../entities/company_specialty.dart';

class CompanyBranchManagementService {
  const CompanyBranchManagementService();

  static CompanySpecialty preferredSpecialty(City city) =>
      switch (city.economicLevel) {
        CityEconomicLevel.regional => CompanySpecialty.operations,
        CityEconomicLevel.developing => CompanySpecialty.logistics,
        CityEconomicLevel.metropolis => CompanySpecialty.sales,
        CityEconomicLevel.economicCenter => CompanySpecialty.technology,
      };

  CompanySpecialty effectiveSpecialty(CompanyBranch branch) {
    final city = CityCatalog.findById(branch.cityId);
    return branch.specialty ??
        (city == null ? CompanySpecialty.operations : preferredSpecialty(city));
  }

  CompanyEmployee? managerFor(CompanyBranch branch) {
    final managerId = branch.managerEmployeeId;
    if (managerId == null) return null;
    for (final employee in branch.employees) {
      if (employee.id == managerId) return employee;
    }
    return null;
  }

  int managerRevenueBonusPercent(CompanyBranch branch) {
    final manager = managerFor(branch);
    if (manager == null) return 0;
    final leadershipBonus = manager.specialty == CompanySpecialty.leadership
        ? 4
        : 0;
    return (3 +
            manager.effectivePerformance ~/ 20 +
            manager.seniority.index * 2 +
            leadershipBonus)
        .clamp(3, 16)
        .toInt();
  }

  PlayerState setManager(PlayerState state, int cityId, int? employeeId) {
    final branch = _requireBranch(state, cityId);
    if (employeeId != null &&
        !branch.employees.any((employee) => employee.id == employeeId)) {
      throw const GameRuleException('Yönetici bu bayinin çalışanı olmalı.');
    }
    return _replaceBranch(
      state,
      branch.copyWith(managerEmployeeId: employeeId),
    );
  }

  PlayerState setLocalGoal(
    PlayerState state,
    int cityId,
    CompanyBranchLocalGoal goal,
  ) {
    final branch = _requireBranch(state, cityId);
    return _replaceBranch(state, branch.copyWith(localGoal: goal));
  }

  PlayerState setSpecialty(
    PlayerState state,
    int cityId,
    CompanySpecialty specialty,
  ) {
    final branch = _requireBranch(state, cityId);
    return _replaceBranch(state, branch.copyWith(specialty: specialty));
  }

  CompanyBranch applyDailyGoal(CompanyBranch branch) {
    final goal = branch.localGoal;
    if (goal.experienceGain == 0 && goal.burnoutDelta == 0) return branch;
    return branch.copyWith(
      employees: [
        for (final employee in branch.employees)
          employee.copyWith(
            experience: employee.experience + goal.experienceGain,
            burnout: (employee.burnout + goal.burnoutDelta).clamp(0, 100),
          ),
      ],
    );
  }

  CompanyBranch _requireBranch(PlayerState state, int cityId) {
    for (final branch in state.branches) {
      if (branch.cityId == cityId) return branch;
    }
    throw const GameRuleException('Bayi bulunamadı.');
  }

  PlayerState _replaceBranch(PlayerState state, CompanyBranch replacement) =>
      state.copyWith(
        branches: [
          for (final branch in state.branches)
            branch.id == replacement.id ? replacement : branch,
        ],
      );
}
