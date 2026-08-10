import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/company_employee.dart';
import '../entities/company_project.dart';
import 'company_employee_catalog.dart';
import 'company_project_catalog.dart';

class CompanyCheck {
  const CompanyCheck({required this.isEligible, required this.reason});

  final bool isEligible;
  final String reason;
}

class CompanyActionResult {
  const CompanyActionResult({required this.state, required this.message});

  final PlayerState state;
  final String message;
}

class CompanyOperationResult {
  const CompanyOperationResult({required this.state, required this.messages});

  final PlayerState state;
  final List<String> messages;
}

class CompanyService {
  static const establishmentCost = 1000;
  static const recruitmentCost = 0;
  static const projectCost = 100;
  static const maxCompanyLevel = 3;
  static const dailyBaseRevenue = 50;
  static const dailyEmployeeRevenue = 75;
  static const dailyProjectRevenue = 25;

  static int upgradeCost(int level) => level * 600;
  static int employeeCapacity(int level) => level * 4;

  static List<CompanyEmployee> employeesFor(PlayerState state) {
    if (state.employees.isNotEmpty) {
      return state.employees;
    }
    return CompanyEmployeeCatalog.legacyDefaults(state.employeeCount);
  }

  List<CompanyEmployee> availableEmployees(PlayerState state) {
    return CompanyEmployeeCatalog.available(
      state.companyLevel,
      employeesFor(state).map((employee) => employee.id),
    );
  }

  int dailyPayroll(PlayerState state) {
    return employeesFor(state).fold(0, (total, employee) => total + employee.dailySalary);
  }

  int dailyEmployeeContribution(CompanyEmployee employee) => dailyEmployeeRevenue + employee.performance ~/ 20;

  int dailyEmployeeNetContribution(CompanyEmployee employee) => dailyEmployeeContribution(employee) - employee.dailySalary;

  int dailyRevenue(PlayerState state) {
    if (state.companyLevel == 0) return 0;
    final projectLevel = CompanyProjectCatalog.byId(state.activeProjectId).id;
    return state.companyLevel * dailyBaseRevenue +
        employeesFor(state).fold<int>(
          0,
          (total, employee) => total + dailyEmployeeContribution(employee),
        ) +
        projectLevel * dailyProjectRevenue;
  }

  PlayerState collectDailyRevenue(PlayerState state, {int days = 1}) {
    return processDailyOperations(state, days: days).state;
  }

  CompanyOperationResult processDailyOperations(PlayerState state, {int days = 1}) {
    if (days < 1 || state.companyLevel == 0) {
      return CompanyOperationResult(state: state, messages: const <String>[]);
    }
    var current = state;
    final messages = <String>[];
    for (var day = 0; day < days; day++) {
      final revenue = dailyRevenue(current);
      final payroll = dailyPayroll(current);
      final completedProjectsBeforeOperation = current.completedProjects;
      current = current.copyWith(companyFunds: current.companyFunds + revenue - payroll);
      if (employeesFor(current).isEmpty) {
        continue;
      }
      final projectResult = advanceProject(current);
      current = projectResult.state;
      if (projectResult.state.completedProjects > completedProjectsBeforeOperation) {
        messages.add(projectResult.message);
      }
    }
    return CompanyOperationResult(state: current, messages: messages);
  }

  CompanyCheck checkEstablishment(PlayerState state) {
    if (state.companyLevel > 0) {
      return const CompanyCheck(isEligible: false, reason: 'Zaten bir şirketin var.');
    }
    if (state.careerLevel < 3) {
      return const CompanyCheck(isEligible: false, reason: 'Şirket kurmak için kariyer seviyesi 3 olmalı.');
    }
    if (state.money < establishmentCost) {
      return const CompanyCheck(isEligible: false, reason: 'Şirket kurmak için yeterli sermayen yok.');
    }
    return const CompanyCheck(isEligible: true, reason: 'Şirket kurmaya hazırsın.');
  }

  PlayerState establish(PlayerState state) {
    final check = checkEstablishment(state);
    if (!check.isEligible) {
      throw GameRuleException(check.reason);
    }
    return state.copyWith(
      currentJobId: null,
      employment: null,
      money: state.money - establishmentCost,
      companyLevel: 1,
      companyFunds: 500,
      employeeCount: 0,
      projectProgress: 0,
      activeProjectId: CompanyProjectCatalog.projects.first.id,
      completedProjects: 0,
    );
  }

  PlayerState recruit(PlayerState state, {CompanyEmployee? employee}) {
    if (state.companyLevel == 0) {
      throw const GameRuleException('Önce şirketini kurmalısın.');
    }
    final employees = employeesFor(state);
    if (employees.length >= employeeCapacity(state.companyLevel)) {
      throw const GameRuleException('Bu şirket seviyesi için çalışan kapasitesi dolu.');
    }
    final selected = employee;
    if (selected == null) {
      throw const GameRuleException('İşe almak istediğin çalışanı seçmelisin.');
    }
    if (selected.requiredCompanyLevel > state.companyLevel ||
        employees.any((current) => current.id == selected.id)) {
      throw const GameRuleException('Bu çalışan şu anda işe alınamaz.');
    }
    return state.copyWith(
      employeeCount: employees.length + 1,
      employees: <CompanyEmployee>[...employees, selected],
    );
  }

  PlayerState dismissEmployee(PlayerState state, int employeeId) {
    if (state.companyLevel == 0) {
      throw const GameRuleException('Önce şirketini kurmalısın.');
    }
    final employees = employeesFor(state);
    if (!employees.any((employee) => employee.id == employeeId)) {
      throw const GameRuleException('Bu çalışan şirketinde bulunamadı.');
    }
    final remaining = employees.where((employee) => employee.id != employeeId).toList(growable: false);
    return state.copyWith(
      employeeCount: remaining.length,
      employees: remaining,
    );
  }

  int dailyProjectProgress(PlayerState state) {
    if (state.companyLevel == 0) {
      return 0;
    }
    final project = CompanyProjectCatalog.byId(state.activeProjectId);
    return employeesFor(state).fold(
      0,
      (total, employee) {
        final progress = (project.progressPerEmployee * employee.performance / 100).round();
        return total + (progress < 1 ? 1 : progress);
      },
    );
  }

  CompanyActionResult advanceProject(PlayerState state) {
    if (state.companyLevel == 0) {
      throw const GameRuleException('Önce şirketini kurmalısın.');
    }
    if (employeesFor(state).isEmpty) {
      throw const GameRuleException('Proje için en az bir çalışan almalısın.');
    }
    final project = CompanyProjectCatalog.byId(state.activeProjectId);
    final totalProgress = state.projectProgress + dailyProjectProgress(state);
    final completed = totalProgress >= 100;
    final nextProgress = completed ? totalProgress - 100 : totalProgress;
    final netReward = project.reward - project.cost;
    final nextState = state.copyWith(
      companyFunds: state.companyFunds + (completed ? netReward : 0),
      projectProgress: nextProgress,
      experience: completed ? state.experience + project.experienceReward : state.experience,
      completedProjects: completed ? state.completedProjects + 1 : state.completedProjects,
    );
    return CompanyActionResult(
      state: nextState,
      message: completed
          ? 'Proje tamamlandı. Net şirket geliri: ₺$netReward.'
          : 'Proje otomatik olarak %$nextProgress ilerledi.',
    );
  }

  CompanyCheck checkUpgrade(PlayerState state) {
    if (state.companyLevel == 0) {
      return const CompanyCheck(isEligible: false, reason: 'Önce şirketini kurmalısın.');
    }
    if (state.companyLevel >= maxCompanyLevel) {
      return const CompanyCheck(isEligible: false, reason: 'Şirketin en yüksek seviyede.');
    }
    final cost = upgradeCost(state.companyLevel);
    if (state.companyFunds < cost) {
      return CompanyCheck(isEligible: false, reason: 'Seviye yükseltmek için şirket kasasında ₺$cost olmalı.');
    }
    return CompanyCheck(isEligible: true, reason: 'Yeni seviye ve çalışan kapasitesi açılacak.');
  }

  PlayerState upgrade(PlayerState state) {
    final check = checkUpgrade(state);
    if (!check.isEligible) {
      throw GameRuleException(check.reason);
    }
    return state.copyWith(
      companyLevel: state.companyLevel + 1,
      companyFunds: state.companyFunds - upgradeCost(state.companyLevel),
    );
  }

  CompanyCheck checkProjectSelection(PlayerState state, CompanyProject project) {
    if (state.companyLevel == 0) {
      return const CompanyCheck(isEligible: false, reason: 'Önce şirketini kurmalısın.');
    }
    if (project.id > state.companyLevel) {
      return CompanyCheck(isEligible: false, reason: 'Bu proje için şirket seviyesi ${project.id} olmalı.');
    }
    if (state.projectProgress > 0) {
      return const CompanyCheck(isEligible: false, reason: 'Devam eden proje bitmeden proje değiştirilemez.');
    }
    return const CompanyCheck(isEligible: true, reason: 'Proje seçilebilir.');
  }

  PlayerState selectProject(PlayerState state, CompanyProject project) {
    final check = checkProjectSelection(state, project);
    if (!check.isEligible) {
      throw GameRuleException(check.reason);
    }
    return state.copyWith(activeProjectId: project.id);
  }
}
