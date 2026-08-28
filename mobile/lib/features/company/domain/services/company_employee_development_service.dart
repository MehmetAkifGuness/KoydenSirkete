import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/company_branch.dart';
import '../entities/company_employee.dart';
import 'company_finance_recorder.dart';
import '../../../finance/domain/entities/finance_ledger.dart';

class EmployeeDevelopmentCheck {
  const EmployeeDevelopmentCheck({
    required this.isEligible,
    required this.reason,
    required this.cost,
  });

  final bool isEligible;
  final String reason;
  final int cost;
}

class CompanyEmployeeDevelopmentService {
  static const performanceGain = 5;
  static const maximumPerformance = 100;

  static int developmentCost(CompanyEmployee employee) =>
      400 + employee.performance * 15;

  EmployeeDevelopmentCheck checkHeadquarters(
    PlayerState state,
    int employeeId,
  ) => _check(state, _findEmployee(state.employees, employeeId));

  EmployeeDevelopmentCheck checkBranch(
    PlayerState state,
    int cityId,
    int employeeId,
  ) {
    final branch = _findBranch(state, cityId);
    return _check(
      state,
      branch == null ? null : _findEmployee(branch.employees, employeeId),
    );
  }

  PlayerState developHeadquarters(PlayerState state, int employeeId) {
    final employee = _findEmployee(state.employees, employeeId);
    final check = _check(state, employee);
    if (!check.isEligible) throw GameRuleException(check.reason);
    return state.copyWith(
      companyFunds: state.companyFunds - check.cost,
      employees: _replaceEmployee(state.employees, _improve(employee!)),
      financeLedger: CompanyFinanceRecorder.record(
        state,
        FinanceCategory.companyDevelopment,
        -check.cost,
      ),
    );
  }

  PlayerState developBranch(PlayerState state, int cityId, int employeeId) {
    final branch = _findBranch(state, cityId);
    final employee = branch == null
        ? null
        : _findEmployee(branch.employees, employeeId);
    final check = _check(state, employee);
    if (!check.isEligible) throw GameRuleException(check.reason);
    final replacement = branch!.copyWith(
      employees: _replaceEmployee(branch.employees, _improve(employee!)),
    );
    return state.copyWith(
      companyFunds: state.companyFunds - check.cost,
      branches: [
        for (final current in state.branches)
          current.cityId == cityId ? replacement : current,
      ],
      financeLedger: CompanyFinanceRecorder.record(
        state,
        FinanceCategory.companyDevelopment,
        -check.cost,
      ),
    );
  }

  EmployeeDevelopmentCheck _check(
    PlayerState state,
    CompanyEmployee? employee,
  ) {
    if (employee == null) {
      return const EmployeeDevelopmentCheck(
        isEligible: false,
        reason: 'Çalışan bulunamadı.',
        cost: 0,
      );
    }
    final cost = developmentCost(employee);
    if (employee.isFullyDeveloped) {
      return EmployeeDevelopmentCheck(
        isEligible: false,
        reason: 'Çalışan en yüksek gelişim seviyesinde.',
        cost: cost,
      );
    }
    if (state.companyFunds < cost) {
      return EmployeeDevelopmentCheck(
        isEligible: false,
        reason: 'Gelişim için şirket kasasında ₺$cost olmalı.',
        cost: cost,
      );
    }
    return EmployeeDevelopmentCheck(
      isEligible: true,
      reason:
          'Şirket kasasından ₺$cost: performans +$performanceGain, '
          'moral +8, sadakat +5.',
      cost: cost,
    );
  }

  CompanyEmployee _improve(CompanyEmployee employee) => employee.copyWith(
    performance: (employee.performance + performanceGain).clamp(
      0,
      maximumPerformance,
    ),
    morale: (employee.morale + 8).clamp(0, 100),
    loyalty: (employee.loyalty + 5).clamp(0, 100),
  );

  CompanyEmployee? _findEmployee(
    Iterable<CompanyEmployee> employees,
    int employeeId,
  ) {
    for (final employee in employees) {
      if (employee.id == employeeId) return employee;
    }
    return null;
  }

  CompanyBranch? _findBranch(PlayerState state, int cityId) {
    for (final branch in state.branches) {
      if (branch.cityId == cityId) return branch;
    }
    return null;
  }

  List<CompanyEmployee> _replaceEmployee(
    List<CompanyEmployee> employees,
    CompanyEmployee replacement,
  ) => [
    for (final employee in employees)
      employee.id == replacement.id ? replacement : employee,
  ];
}
