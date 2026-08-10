import '../../../../core/errors/game_rule_exception.dart';
import '../../../cities/domain/entities/city.dart';
import '../../../cities/domain/services/city_catalog.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/company_branch.dart';
import '../entities/company_employee.dart';
import 'company_employee_catalog.dart';
import 'company_service.dart';

class CompanyBranchOperationResult {
  const CompanyBranchOperationResult({required this.state, required this.messages});

  final PlayerState state;
  final List<String> messages;
}

class CompanyBranchService {
  static const maxBranchLevel = 3;

  static int openingCost(City city) => (city.dailyCost * 4 + city.marketLevel * 500).clamp(3000, 150000);

  static int employeeCapacity(CompanyBranch branch) => branch.level * 3;

  List<CompanyEmployee> availableEmployees(PlayerState state, CompanyBranch branch) {
    final hiredIds = <int>{
      ...CompanyService.employeesFor(state).map((employee) => employee.id),
      for (final current in state.branches) ...current.employees.map((employee) => employee.id),
    };
    return CompanyEmployeeCatalog.available(
      state.companyLevel,
      hiredIds,
    );
  }

  CompanyCheckResult checkOpen(PlayerState state, City city) {
    if (state.companyLevel == 0) {
      return const CompanyCheckResult(isEligible: false, reason: 'Önce şirketini kurmalısın.');
    }
    if (state.branches.any((branch) => branch.cityId == city.id)) {
      return const CompanyCheckResult(isEligible: false, reason: 'Bu şehirde zaten bir bayin var.');
    }
    final cost = openingCost(city);
    if (state.companyFunds < cost) {
      return CompanyCheckResult(isEligible: false, reason: 'Bayi açmak için şirket kasasında ₺$cost olmalı.');
    }
    return const CompanyCheckResult(isEligible: true, reason: 'Bayi açmaya hazırsın.');
  }

  PlayerState open(PlayerState state, City city) {
    final check = checkOpen(state, city);
    if (!check.isEligible) {
      throw GameRuleException(check.reason);
    }
    final branch = CompanyBranch(id: city.id, cityId: city.id);
    return state.copyWith(
      companyFunds: state.companyFunds - openingCost(city),
      branches: <CompanyBranch>[...state.branches, branch],
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
    final alreadyHired = CompanyService.employeesFor(state).any((item) => item.id == employee.id) || state.branches.any((item) => item.employees.any((current) => current.id == employee.id));
    if (employee.requiredCompanyLevel > state.companyLevel || alreadyHired) {
      throw const GameRuleException('Bu çalışan şu anda bayiye alınamaz.');
    }
    return _replaceBranch(state, branch.copyWith(employees: <CompanyEmployee>[...branch.employees, employee]));
  }

  PlayerState dismiss(PlayerState state, int cityId, int employeeId) {
    final branch = _find(state, cityId);
    if (branch == null) {
      throw const GameRuleException('Bayi bulunamadı.');
    }
    final employees = branch.employees.where((employee) => employee.id != employeeId).toList(growable: false);
    if (employees.length == branch.employees.length) {
      throw const GameRuleException('Bu çalışan bayide bulunamadı.');
    }
    return _replaceBranch(state, branch.copyWith(employees: employees));
  }

  int dailyRevenue(CompanyBranch branch) {
    final city = CityCatalog.findById(branch.cityId);
    if (city == null || branch.employees.isEmpty) return 0;
    final marketIncome = 60 + city.marketLevel * 20 + city.opportunityCount * 10 + branch.level * 50;
    return marketIncome + branch.employees.fold(0, (total, employee) => total + 80 + employee.performance ~/ 5);
  }

  int dailyPayroll(CompanyBranch branch) => branch.employees.fold(0, (total, employee) => total + employee.dailySalary);

  CompanyBranch? _find(PlayerState state, int cityId) {
    for (final branch in state.branches) {
      if (branch.cityId == cityId) return branch;
    }
    return null;
  }

  PlayerState _replaceBranch(PlayerState state, CompanyBranch replacement) {
    return state.copyWith(
      branches: <CompanyBranch>[for (final branch in state.branches) branch.id == replacement.id ? replacement : branch],
    );
  }

  CompanyBranchOperationResult processDailyOperations(PlayerState state, {int days = 1}) {
    if (days < 1 || state.branches.isEmpty) {
      return CompanyBranchOperationResult(state: state, messages: const <String>[]);
    }
    var current = state;
    final messages = <String>[];
    for (var day = 0; day < days; day++) {
      var net = 0;
      for (final branch in current.branches) {
        net += dailyRevenue(branch) - dailyPayroll(branch);
      }
      if (net != 0) {
        current = current.copyWith(companyFunds: current.companyFunds + net);
        messages.add(net > 0 ? 'Bayiler şirkete +₺$net kazandırdı.' : 'Bayi giderleri şirket kasasından ₺${net.abs()} aldı.');
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
