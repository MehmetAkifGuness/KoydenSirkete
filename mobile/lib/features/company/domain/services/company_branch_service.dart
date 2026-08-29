import '../../../../core/errors/game_rule_exception.dart';
import '../../../cities/domain/entities/city.dart';
import '../../../cities/domain/services/city_catalog.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/company_branch.dart';
import '../entities/company_employee.dart';
import '../entities/company_specialty.dart';
import 'company_employee_catalog.dart';
import 'company_branch_management_service.dart';
import 'company_budget_service.dart';
import 'company_finance_recorder.dart';
import 'company_region_service.dart';
import 'company_service.dart';
import 'company_season_reward_service.dart';
import 'company_trophy_service.dart';
import '../../../finance/domain/entities/finance_ledger.dart';

class CompanyBranchOperationResult {
  const CompanyBranchOperationResult({
    required this.state,
    required this.messages,
  });

  final PlayerState state;
  final List<String> messages;
}

class CompanyBranchService {
  CompanyBranchService({
    CompanyRegionService? regionService,
    CompanySeasonRewardService? seasonRewardService,
    CompanyBranchManagementService? managementService,
    CompanyBudgetService? budgetService,
  }) : _regionService = regionService ?? CompanyRegionService(),
       _seasonRewardService =
           seasonRewardService ?? const CompanySeasonRewardService(),
       _managementService =
           managementService ?? const CompanyBranchManagementService(),
       _budgetService = budgetService ?? const CompanyBudgetService();

  static const maxBranchLevel = 3;
  static const levelRevenueBonusPercent = 25;
  static const specialistDailyRevenueBonus = 35;
  final CompanyRegionService _regionService;
  final CompanySeasonRewardService _seasonRewardService;
  final CompanyBranchManagementService _managementService;
  final CompanyBudgetService _budgetService;

  static int openingCost(City city) =>
      (city.dailyCost * 12 + city.marketLevel * 2000).clamp(30000, 200000);

  int openingCostFor(PlayerState state, City city) =>
      (openingCost(city) *
              (100 - _regionService.investmentDiscount(state)) /
              100)
          .round();

  static int employeeCapacity(CompanyBranch branch) => branch.level * 3;

  static int upgradeCost(CompanyBranch branch) {
    final city = CityCatalog.findById(branch.cityId);
    if (city == null || branch.level >= maxBranchLevel) return 0;
    final percent = branch.level == 1 ? 60 : 100;
    return (openingCost(city) * percent / 100).round();
  }

  int upgradeCostFor(PlayerState state, CompanyBranch branch) =>
      (upgradeCost(branch) *
              (100 - _regionService.investmentDiscount(state)) /
              100)
          .round();

  static CompanySpecialty preferredSpecialty(City city) =>
      CompanyBranchManagementService.preferredSpecialty(city);

  List<CompanyEmployee> availableEmployees(
    PlayerState state,
    CompanyBranch branch,
  ) {
    final hiredIds = <int>{
      ...CompanyService.employeesFor(state).map((employee) => employee.id),
      for (final current in state.branches)
        ...current.employees.map((employee) => employee.id),
    };
    return CompanyEmployeeCatalog.availableForCity(
      cityId: branch.cityId,
      occupiedSlots: branch.employees.length,
      hiredIds: hiredIds,
    );
  }

  CompanyCheckResult checkOpen(PlayerState state, City city) {
    if (state.companyLevel == 0) {
      return const CompanyCheckResult(
        isEligible: false,
        reason: 'Önce şirketini kurmalısın.',
      );
    }
    if (state.branches.any((branch) => branch.cityId == city.id)) {
      return const CompanyCheckResult(
        isEligible: false,
        reason: 'Bu şehirde zaten bir bayin var.',
      );
    }
    final cost = openingCostFor(state, city);
    if (state.companyFunds < cost) {
      return CompanyCheckResult(
        isEligible: false,
        reason: 'Bayi açmak için şirket kasasında ₺$cost olmalı.',
      );
    }
    return const CompanyCheckResult(
      isEligible: true,
      reason: 'Bayi açmaya hazırsın.',
    );
  }

  PlayerState open(PlayerState state, City city) {
    final check = checkOpen(state, city);
    if (!check.isEligible) {
      throw GameRuleException(check.reason);
    }
    final branch = CompanyBranch(id: city.id, cityId: city.id);
    final cost = openingCostFor(state, city);
    return state.copyWith(
      companyFunds: state.companyFunds - cost,
      branches: <CompanyBranch>[...state.branches, branch],
      financeLedger: CompanyFinanceRecorder.record(
        state,
        FinanceCategory.companyBranch,
        -cost,
      ),
    );
  }

  PlayerState recruit(PlayerState state, int cityId, CompanyEmployee employee) {
    final branch = _find(state, cityId);
    if (branch == null) {
      throw const GameRuleException('Bayi bulunamadı.');
    }
    if (branch.employees.length >= employeeCapacity(branch)) {
      throw const GameRuleException('Bu bayinin çalışan kapasitesi dolu.');
    }
    final alreadyHired =
        CompanyService.employeesFor(
          state,
        ).any((item) => item.id == employee.id) ||
        state.branches.any(
          (item) => item.employees.any((current) => current.id == employee.id),
        );
    if (employee.requiredCompanyLevel > state.companyLevel || alreadyHired) {
      throw const GameRuleException('Bu çalışan şu anda bayiye alınamaz.');
    }
    return _replaceBranch(
      state,
      branch.copyWith(
        employees: <CompanyEmployee>[...branch.employees, employee],
      ),
    );
  }

  PlayerState dismiss(PlayerState state, int cityId, int employeeId) {
    final branch = _find(state, cityId);
    if (branch == null) {
      throw const GameRuleException('Bayi bulunamadı.');
    }
    final employees = branch.employees
        .where((employee) => employee.id != employeeId)
        .toList(growable: false);
    if (employees.length == branch.employees.length) {
      throw const GameRuleException('Bu çalışan bayide bulunamadı.');
    }
    return _replaceBranch(
      state,
      branch.copyWith(
        employees: employees,
        managerEmployeeId: branch.managerEmployeeId == employeeId
            ? null
            : branch.managerEmployeeId,
      ),
    );
  }

  CompanyCheckResult checkUpgrade(PlayerState state, int cityId) {
    final branch = _find(state, cityId);
    if (branch == null) {
      return const CompanyCheckResult(
        isEligible: false,
        reason: 'Bayi bulunamadı.',
      );
    }
    if (branch.level >= maxBranchLevel) {
      return const CompanyCheckResult(
        isEligible: false,
        reason: 'Bayi en yüksek seviyede.',
      );
    }
    if (state.companyLevel <= branch.level) {
      return CompanyCheckResult(
        isEligible: false,
        reason: 'Önce şirketini seviye ${branch.level + 1} yapmalısın.',
      );
    }
    final cost = upgradeCostFor(state, branch);
    if (state.companyFunds < cost) {
      return CompanyCheckResult(
        isEligible: false,
        reason: 'Bayi yükseltmesi için şirket kasasında ₺$cost olmalı.',
      );
    }
    return CompanyCheckResult(
      isEligible: true,
      reason: 'Kapasite +3, gelir +%$levelRevenueBonusPercent.',
    );
  }

  PlayerState upgrade(PlayerState state, int cityId) {
    final check = checkUpgrade(state, cityId);
    if (!check.isEligible) throw GameRuleException(check.reason);
    final branch = _find(state, cityId)!;
    final cost = upgradeCostFor(state, branch);
    return _replaceBranch(
      state.copyWith(
        companyFunds: state.companyFunds - cost,
        financeLedger: CompanyFinanceRecorder.record(
          state,
          FinanceCategory.companyBranch,
          -cost,
        ),
      ),
      branch.copyWith(level: branch.level + 1),
    );
  }

  int dailyRevenue(CompanyBranch branch) {
    final city = CityCatalog.findById(branch.cityId);
    if (city == null || branch.employees.isEmpty) return 0;
    final specialty = _managementService.effectiveSpecialty(branch);
    final marketIncome =
        60 +
        city.marketLevel * 20 +
        city.opportunityCount * 10 +
        branch.level * 50;
    final gross =
        marketIncome +
        branch.employees.fold<int>(
          0,
          (total, employee) =>
              total +
              80 +
              employee.effectivePerformance ~/ 5 +
              (employee.specialty == specialty
                  ? specialistDailyRevenueBonus
                  : 0),
        );
    final multiplier =
        100 +
        (branch.level - 1) * levelRevenueBonusPercent +
        _managementService.managerRevenueBonusPercent(branch) +
        branch.localGoal.revenuePercent;
    return (gross * multiplier / 100).round();
  }

  int dailyRevenueFor(PlayerState state, CompanyBranch branch) {
    final bonus =
        _regionService.revenueBonus(state) +
        CompanyTrophyService.branchRevenueBonus(state) +
        _seasonRewardService.sponsorshipRevenueBonus(state) +
        _budgetService.marketingRevenueBonusPercent(state) +
        _budgetService.maintenanceRevenueBonusPercent(state);
    return (dailyRevenue(branch) * (100 + bonus) / 100).round();
  }

  int dailyPayroll(CompanyBranch branch) => branch.employees.fold(
    0,
    (total, employee) => total + employee.dailySalary,
  );

  int dailyPayrollFor(PlayerState state, CompanyBranch branch) {
    final discount =
        _regionService.payrollDiscount(state) +
        CompanyTrophyService.branchPayrollDiscount(state);
    final multiplier = (100 + branch.localGoal.payrollPercent - discount)
        .clamp(0, 200)
        .toInt();
    return (dailyPayroll(branch) * multiplier / 100).round();
  }

  CompanyBranch? _find(PlayerState state, int cityId) {
    for (final branch in state.branches) {
      if (branch.cityId == cityId) return branch;
    }
    return null;
  }

  PlayerState _replaceBranch(PlayerState state, CompanyBranch replacement) {
    return state.copyWith(
      branches: <CompanyBranch>[
        for (final branch in state.branches)
          branch.id == replacement.id ? replacement : branch,
      ],
    );
  }

  CompanyBranchOperationResult processDailyOperations(
    PlayerState state, {
    int days = 1,
  }) {
    if (days < 1 || state.branches.isEmpty) {
      return CompanyBranchOperationResult(
        state: state,
        messages: const <String>[],
      );
    }
    var current = state;
    final messages = <String>[];
    for (var day = 0; day < days; day++) {
      current = current.copyWith(
        branches: [
          for (final branch in current.branches)
            _budgetService.applyDailyBranchOfficeEffect(current, branch),
        ],
      );
      var net = 0;
      for (final branch in current.branches) {
        net +=
            dailyRevenueFor(current, branch) - dailyPayrollFor(current, branch);
      }
      final updatedBranches = [
        for (final branch in current.branches)
          _managementService.applyDailyGoal(branch),
      ];
      if (net != 0) {
        current = current.copyWith(
          companyFunds: current.companyFunds + net,
          branches: updatedBranches,
          financeLedger: CompanyFinanceRecorder.record(
            current,
            FinanceCategory.companyBranch,
            net,
          ),
        );
        messages.add(
          net > 0
              ? 'Bayiler şirkete +₺$net kazandırdı.'
              : 'Bayi giderleri şirket kasasından ₺${net.abs()} aldı.',
        );
      } else if (updatedBranches.indexed.any(
        (entry) => !identical(entry.$2, current.branches[entry.$1]),
      )) {
        current = current.copyWith(branches: updatedBranches);
      }
    }
    return CompanyBranchOperationResult(state: current, messages: messages);
  }
}

class CompanyCheckResult {
  const CompanyCheckResult({required this.isEligible, required this.reason});

  final bool isEligible;
  final String reason;
}
