import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/company_branch.dart';
import '../entities/company_budget_state.dart';
import 'company_branch_management_service.dart';
import 'company_employee_management_service.dart';

enum CompanyAutomationPreset {
  balanced('Dengeli', 'Bütçe, yöneticiler ve zamlar dengeli yönetilir.'),
  growth('Büyüme', 'Gelir ve proje hızı öne alınır; pahalı zamlar reddedilir.'),
  people('Ekip', 'Moral, bağlılık ve çalışan talepleri öne alınır.');

  const CompanyAutomationPreset(this.label, this.description);

  final String label;
  final String description;
}

class CompanyAutomationResult {
  const CompanyAutomationResult({
    required this.state,
    required this.managerCount,
    required this.raiseCount,
  });

  final PlayerState state;
  final int managerCount;
  final int raiseCount;
}

class CompanyAutomationService {
  const CompanyAutomationService();

  CompanyAutomationResult apply(
    PlayerState state,
    CompanyAutomationPreset preset,
  ) {
    if (state.companyLevel == 0) {
      throw const GameRuleException('Önce şirketini kurmalısın.');
    }
    var current = state.copyWith(
      companyBudget: _budgetFor(preset),
      companyProjectTeams: state.companyProjectTeams.setTeam(
        state.activeProjectId,
        state.employees.map((employee) => employee.id),
      ),
    );
    var managers = 0;
    var raises = 0;
    const branchManagement = CompanyBranchManagementService();
    final employeeManagement = CompanyEmployeeManagementService();

    for (final employee in [...current.employees]) {
      if (!employee.hasRaiseRequest) continue;
      current = employeeManagement.respondToHeadquartersRaise(
        current,
        employee.id,
        accept: _acceptRaise(
          employee.dailySalary,
          employee.requestedDailySalary!,
          preset,
        ),
      );
      raises++;
    }
    for (final original in [...current.branches]) {
      var branch = current.branches.firstWhere(
        (item) => item.cityId == original.cityId,
      );
      for (final employee in [...branch.employees]) {
        if (!employee.hasRaiseRequest) continue;
        current = employeeManagement.respondToBranchRaise(
          current,
          branch.cityId,
          employee.id,
          accept: _acceptRaise(
            employee.dailySalary,
            employee.requestedDailySalary!,
            preset,
          ),
        );
        raises++;
      }
      branch = current.branches.firstWhere(
        (item) => item.cityId == original.cityId,
      );
      final manager = branch.employees.isEmpty
          ? null
          : branch.employees.reduce(
              (left, right) =>
                  left.effectivePerformance >= right.effectivePerformance
                  ? left
                  : right,
            );
      current = branchManagement.setManager(
        current,
        branch.cityId,
        manager?.id,
      );
      current = branchManagement.setLocalGoal(
        current,
        branch.cityId,
        _goalFor(preset),
      );
      if (manager != null) managers++;
    }
    return CompanyAutomationResult(
      state: current,
      managerCount: managers,
      raiseCount: raises,
    );
  }

  bool _acceptRaise(
    int salary,
    int requested,
    CompanyAutomationPreset preset,
  ) => switch (preset) {
    CompanyAutomationPreset.people => true,
    CompanyAutomationPreset.growth => false,
    CompanyAutomationPreset.balanced => requested <= (salary * 1.15).ceil(),
  };

  CompanyBudgetState _budgetFor(CompanyAutomationPreset preset) =>
      switch (preset) {
        CompanyAutomationPreset.balanced => const CompanyBudgetState(
          office: CompanyBudgetLevel.low,
          marketing: CompanyBudgetLevel.low,
          research: CompanyBudgetLevel.low,
          maintenance: CompanyBudgetLevel.low,
        ),
        CompanyAutomationPreset.growth => const CompanyBudgetState(
          marketing: CompanyBudgetLevel.medium,
          research: CompanyBudgetLevel.low,
          maintenance: CompanyBudgetLevel.low,
        ),
        CompanyAutomationPreset.people => const CompanyBudgetState(
          office: CompanyBudgetLevel.medium,
          maintenance: CompanyBudgetLevel.low,
        ),
      };

  CompanyBranchLocalGoal _goalFor(CompanyAutomationPreset preset) =>
      switch (preset) {
        CompanyAutomationPreset.balanced => CompanyBranchLocalGoal.balanced,
        CompanyAutomationPreset.growth => CompanyBranchLocalGoal.marketGrowth,
        CompanyAutomationPreset.people =>
          CompanyBranchLocalGoal.teamDevelopment,
      };
}
