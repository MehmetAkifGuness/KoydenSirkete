import '../../../../core/errors/game_rule_exception.dart';
import '../../../finance/domain/entities/finance_ledger.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/company_branch.dart';
import '../entities/company_employee.dart';
import 'company_finance_recorder.dart';

class EmployeePromotionCheck {
  const EmployeePromotionCheck({
    required this.isEligible,
    required this.reason,
    required this.cost,
  });

  final bool isEligible;
  final String reason;
  final int cost;
}

class CompanyEmployeeManagementService {
  static int promotionCost(CompanyEmployee employee) =>
      500 + employee.dailySalary * 20 + employee.seniority.index * 600;

  EmployeePromotionCheck checkHeadquarters(PlayerState state, int employeeId) =>
      _checkPromotion(state, _findEmployee(state.employees, employeeId));

  EmployeePromotionCheck checkBranch(
    PlayerState state,
    int cityId,
    int employeeId,
  ) {
    final branch = _findBranch(state, cityId);
    return _checkPromotion(
      state,
      branch == null ? null : _findEmployee(branch.employees, employeeId),
    );
  }

  PlayerState promoteHeadquarters(PlayerState state, int employeeId) {
    final employee = _findEmployee(state.employees, employeeId);
    final check = _checkPromotion(state, employee);
    if (!check.isEligible) throw GameRuleException(check.reason);
    return state.copyWith(
      companyFunds: state.companyFunds - check.cost,
      employees: _replaceEmployee(state.employees, _promote(employee!)),
      financeLedger: CompanyFinanceRecorder.record(
        state,
        FinanceCategory.companyDevelopment,
        -check.cost,
      ),
    );
  }

  PlayerState promoteBranch(PlayerState state, int cityId, int employeeId) {
    final branch = _findBranch(state, cityId);
    final employee = branch == null
        ? null
        : _findEmployee(branch.employees, employeeId);
    final check = _checkPromotion(state, employee);
    if (!check.isEligible) throw GameRuleException(check.reason);
    final replacement = branch!.copyWith(
      employees: _replaceEmployee(branch.employees, _promote(employee!)),
    );
    return _replaceBranch(
      state.copyWith(
        companyFunds: state.companyFunds - check.cost,
        financeLedger: CompanyFinanceRecorder.record(
          state,
          FinanceCategory.companyDevelopment,
          -check.cost,
        ),
      ),
      replacement,
    );
  }

  PlayerState respondToHeadquartersRaise(
    PlayerState state,
    int employeeId, {
    required bool accept,
  }) {
    final employee = _findEmployee(state.employees, employeeId);
    if (employee == null) {
      throw const GameRuleException('Çalışan bulunamadı.');
    }
    return state.copyWith(
      employees: _replaceEmployee(
        state.employees,
        _respondToRaise(employee, accept: accept),
      ),
    );
  }

  PlayerState respondToBranchRaise(
    PlayerState state,
    int cityId,
    int employeeId, {
    required bool accept,
  }) {
    final branch = _findBranch(state, cityId);
    final employee = branch == null
        ? null
        : _findEmployee(branch.employees, employeeId);
    if (employee == null) {
      throw const GameRuleException('Bayi çalışanı bulunamadı.');
    }
    return _replaceBranch(
      state,
      branch!.copyWith(
        employees: _replaceEmployee(
          branch.employees,
          _respondToRaise(employee, accept: accept),
        ),
      ),
    );
  }

  EmployeePromotionCheck _checkPromotion(
    PlayerState state,
    CompanyEmployee? employee,
  ) {
    if (employee == null) {
      return const EmployeePromotionCheck(
        isEligible: false,
        reason: 'Çalışan bulunamadı.',
        cost: 0,
      );
    }
    final cost = promotionCost(employee);
    final next = employee.seniority.next;
    if (next == null) {
      return EmployeePromotionCheck(
        isEligible: false,
        reason: 'Çalışan en yüksek kıdem seviyesinde.',
        cost: cost,
      );
    }
    if (employee.hasRaiseRequest) {
      return EmployeePromotionCheck(
        isEligible: false,
        reason: 'Önce çalışanın zam talebini sonuçlandır.',
        cost: cost,
      );
    }
    final requiredExperience = employee.seniority.nextPromotionExperience!;
    if (employee.experience < requiredExperience) {
      return EmployeePromotionCheck(
        isEligible: false,
        reason:
            'Terfi için $requiredExperience deneyim gerekli; mevcut ${employee.experience}.',
        cost: cost,
      );
    }
    final requiredPerformance = switch (next) {
      CompanyEmployeeSeniority.specialist => 65,
      CompanyEmployeeSeniority.senior => 78,
      CompanyEmployeeSeniority.lead => 88,
      CompanyEmployeeSeniority.junior => 0,
    };
    if (employee.performance < requiredPerformance) {
      return EmployeePromotionCheck(
        isEligible: false,
        reason: 'Terfi için performans en az %$requiredPerformance olmalı.',
        cost: cost,
      );
    }
    if (state.companyFunds < cost) {
      return EmployeePromotionCheck(
        isEligible: false,
        reason: 'Terfi için şirket kasasında ₺$cost olmalı.',
        cost: cost,
      );
    }
    return EmployeePromotionCheck(
      isEligible: true,
      reason: '${next.label} kıdemine terfi ettir.',
      cost: cost,
    );
  }

  CompanyEmployee _promote(CompanyEmployee employee) => employee.copyWith(
    seniority: employee.seniority.next,
    dailySalary: (employee.dailySalary * 1.08).ceil(),
    performance: (employee.performance + 3).clamp(0, 100),
    morale: (employee.morale + 10).clamp(0, 100),
    loyalty: (employee.loyalty + 12).clamp(0, 100),
    burnout: (employee.burnout - 10).clamp(0, 100),
  );

  CompanyEmployee _respondToRaise(
    CompanyEmployee employee, {
    required bool accept,
  }) {
    final requestedSalary = employee.requestedDailySalary;
    if (requestedSalary == null) {
      throw const GameRuleException('Çalışanın bekleyen zam talebi yok.');
    }
    return employee.copyWith(
      dailySalary: accept ? requestedSalary : employee.dailySalary,
      morale: (employee.morale + (accept ? 8 : -10)).clamp(0, 100),
      loyalty: (employee.loyalty + (accept ? 10 : -12)).clamp(0, 100),
      burnout: (employee.burnout + (accept ? -5 : 5)).clamp(0, 100),
      requestedDailySalary: null,
    );
  }

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

  PlayerState _replaceBranch(PlayerState state, CompanyBranch replacement) =>
      state.copyWith(
        branches: [
          for (final branch in state.branches)
            branch.cityId == replacement.cityId ? replacement : branch,
        ],
      );
}
