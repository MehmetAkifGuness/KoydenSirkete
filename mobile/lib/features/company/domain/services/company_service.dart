import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/company_employee.dart';
import '../entities/company_project.dart';
import '../entities/company_project_outcome.dart';
import 'company_employee_catalog.dart';
import 'company_finance_recorder.dart';
import 'company_project_catalog.dart';
import 'company_project_strategy_service.dart';
import 'company_project_team_service.dart';
import 'company_season_reward_service.dart';
import '../../../finance/domain/entities/finance_ledger.dart';

class CompanyCheck {
  const CompanyCheck({required this.isEligible, required this.reason});

  final bool isEligible;
  final String reason;
}

class CompanyActionResult {
  const CompanyActionResult({
    required this.state,
    required this.message,
    this.succeeded,
    this.projectOutcome,
  });

  final PlayerState state;
  final String message;
  final bool? succeeded;
  final CompanyProjectOutcome? projectOutcome;

  bool get resolved => succeeded != null;
}

class CompanyOperationResult {
  const CompanyOperationResult({required this.state, required this.messages});

  final PlayerState state;
  final List<String> messages;
}

class CompanyService {
  CompanyService({
    CompanyProjectStrategyService? projectStrategy,
    CompanyProjectTeamService? projectTeamService,
    CompanySeasonRewardService? seasonRewardService,
  }) : _projectStrategy = projectStrategy ?? CompanyProjectStrategyService(),
       _projectTeamService =
           projectTeamService ?? const CompanyProjectTeamService(),
       _seasonRewardService =
           seasonRewardService ?? const CompanySeasonRewardService();
  static const establishmentCost = 15000;
  static const maxCompanyLevel = 3;
  static const dailyBaseRevenue = 50;
  static const dailyEmployeeRevenue = 75;
  final CompanyProjectStrategyService _projectStrategy;
  final CompanyProjectTeamService _projectTeamService;
  final CompanySeasonRewardService _seasonRewardService;
  static int upgradeCost(int level) => switch (level) {
    1 => 25000,
    2 => 75000,
    _ => 0,
  };
  static int employeeCapacity(int level) => level * 4;
  static List<CompanyEmployee> employeesFor(PlayerState state) =>
      state.employees.isNotEmpty
      ? state.employees
      : CompanyEmployeeCatalog.legacyDefaults(state.employeeCount);

  List<CompanyEmployee> availableEmployees(PlayerState state) {
    return CompanyEmployeeCatalog.available(
      state.companyLevel,
      employeesFor(state).map((employee) => employee.id),
    );
  }

  int dailyPayroll(PlayerState state) => employeesFor(
    state,
  ).fold(0, (total, employee) => total + employee.dailySalary);

  int dailyEmployeeContribution(CompanyEmployee employee) =>
      dailyEmployeeRevenue + employee.effectivePerformance ~/ 20;

  int dailyEmployeeNetContribution(CompanyEmployee employee) =>
      dailyEmployeeContribution(employee) - employee.dailySalary;

  int dailyRevenue(PlayerState state) {
    final employees = employeesFor(state);
    if (state.companyLevel == 0 || employees.isEmpty) return 0;
    final gross =
        state.companyLevel * dailyBaseRevenue +
        employees.fold<int>(
          0,
          (total, employee) => total + dailyEmployeeContribution(employee),
        );
    final bonus = _seasonRewardService.sponsorshipRevenueBonus(state);
    return (gross * (100 + bonus) / 100).round();
  }

  PlayerState collectDailyRevenue(PlayerState state, {int days = 1}) =>
      processDailyOperations(state, days: days).state;

  CompanyOperationResult processDailyOperations(
    PlayerState state, {
    int days = 1,
  }) {
    if (days < 1 || state.companyLevel == 0) {
      return CompanyOperationResult(state: state, messages: const <String>[]);
    }
    var current = state;
    final messages = <String>[];
    for (var day = 0; day < days; day++) {
      final revenue = dailyRevenue(current);
      final payroll = dailyPayroll(current);
      current = current.copyWith(
        companyFunds: current.companyFunds + revenue - payroll,
        financeLedger: CompanyFinanceRecorder.recordDailyOperations(
          current,
          revenue: revenue,
          payroll: payroll,
        ),
      );
      final project = CompanyProjectCatalog.byId(current.activeProjectId);
      if (_projectTeamService.teamFor(current, project).isEmpty) {
        continue;
      }
      final projectResult = CompanyProjectOperations(
        this,
      ).advanceProject(current);
      current = projectResult.state;
      if (projectResult.resolved) {
        messages.add(projectResult.message);
      }
    }
    return CompanyOperationResult(state: current, messages: messages);
  }

  CompanyCheck checkEstablishment(PlayerState state) {
    if (state.companyLevel > 0) {
      return const CompanyCheck(
        isEligible: false,
        reason: 'Zaten bir şirketin var.',
      );
    }
    if (state.careerLevel < 3) {
      return const CompanyCheck(
        isEligible: false,
        reason: 'Şirket kurmak için kariyer seviyesi 3 olmalı.',
      );
    }
    if (state.money < establishmentCost) {
      return const CompanyCheck(
        isEligible: false,
        reason: 'Şirket kurmak için yeterli sermayen yok.',
      );
    }
    return const CompanyCheck(
      isEligible: true,
      reason: 'Şirket kurmaya hazırsın.',
    );
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
      projectElapsedDays: 0,
      lastProjectOutcome: null,
      activeProjectId: CompanyProjectCatalog.projects.first.id,
      completedProjects: 0,
      financeLedger: CompanyFinanceRecorder.recordEstablishment(
        state,
        cost: establishmentCost,
        initialFunds: 500,
      ),
    );
  }

  PlayerState recruit(PlayerState state, {CompanyEmployee? employee}) {
    if (state.companyLevel == 0) {
      throw const GameRuleException('Önce şirketini kurmalısın.');
    }
    final employees = employeesFor(state);
    if (employees.length >= employeeCapacity(state.companyLevel)) {
      throw const GameRuleException(
        'Bu şirket seviyesi için çalışan kapasitesi dolu.',
      );
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
    final remaining = employees
        .where((employee) => employee.id != employeeId)
        .toList(growable: false);
    return state.copyWith(
      employeeCount: remaining.length,
      employees: remaining,
      companyProjectTeams: state.companyProjectTeams.removeEmployee(employeeId),
    );
  }

  CompanyCheck checkUpgrade(PlayerState state) {
    if (state.companyLevel == 0) {
      return const CompanyCheck(
        isEligible: false,
        reason: 'Önce şirketini kurmalısın.',
      );
    }
    if (state.companyLevel >= maxCompanyLevel) {
      return const CompanyCheck(
        isEligible: false,
        reason: 'Şirketin en yüksek seviyede.',
      );
    }
    final cost = upgradeCost(state.companyLevel);
    if (state.companyFunds < cost) {
      return CompanyCheck(
        isEligible: false,
        reason: 'Seviye yükseltmek için şirket kasasında ₺$cost olmalı.',
      );
    }
    return CompanyCheck(
      isEligible: true,
      reason: 'Yeni seviye ve çalışan kapasitesi açılacak.',
    );
  }

  PlayerState upgrade(PlayerState state) {
    final check = checkUpgrade(state);
    if (!check.isEligible) {
      throw GameRuleException(check.reason);
    }
    return state.copyWith(
      companyLevel: state.companyLevel + 1,
      companyFunds: state.companyFunds - upgradeCost(state.companyLevel),
      financeLedger: CompanyFinanceRecorder.record(
        state,
        FinanceCategory.companyInvestment,
        -upgradeCost(state.companyLevel),
      ),
    );
  }
}

extension CompanyProjectOperations on CompanyService {
  int dailyProjectProgress(PlayerState state) {
    if (state.companyLevel == 0) return 0;
    final project = CompanyProjectCatalog.byId(state.activeProjectId);
    return projectForecast(state, project).dailyProgress;
  }

  CompanyProjectForecast projectForecast(
    PlayerState state,
    CompanyProject project,
  ) => _projectStrategy.forecast(
    state: state,
    project: project,
    employees: _projectTeamService.teamFor(state, project),
  );

  CompanyActionResult advanceProject(PlayerState state) {
    if (state.companyLevel == 0) {
      throw const GameRuleException('Önce şirketini kurmalısın.');
    }
    final project = CompanyProjectCatalog.byId(state.activeProjectId);
    final employees = _projectTeamService.teamFor(state, project);
    if (employees.isEmpty) {
      throw const GameRuleException('Projeye en az bir çalışan atamalısın.');
    }
    if (project.requiresSeasonInvitation &&
        !_seasonRewardService.hasProjectInvitation(state)) {
      throw const GameRuleException('Özel proje daveti artık kullanılamıyor.');
    }
    final totalProgress = state.projectProgress + dailyProjectProgress(state);
    final elapsedDays = state.projectElapsedDays + 1;
    final completed = totalProgress >= 100;
    final succeeded = completed
        ? _projectStrategy.succeeds(
            state: state,
            project: project,
            employees: employees,
          )
        : null;
    final outcome = succeeded == null
        ? null
        : _projectStrategy.resolveOutcome(
            state: state,
            project: project,
            employees: employees,
            succeeded: succeeded,
            elapsedDays: elapsedDays,
          );
    final invitationUsed = completed && project.requiresSeasonInvitation;
    final rewardState = invitationUsed
        ? _seasonRewardService.consumeProjectInvitation(state)
        : state;
    final nextFunds = outcome == null
        ? state.companyFunds
        : (state.companyFunds + outcome.netIncome).clamp(0, 1 << 62).toInt();
    final nextState = rewardState.copyWith(
      companyFunds: nextFunds,
      activeProjectId: invitationUsed
          ? CompanyProjectCatalog.projects.first.id
          : state.activeProjectId,
      projectProgress: completed ? 0 : totalProgress,
      projectElapsedDays: completed ? 0 : elapsedDays,
      lastProjectOutcome: outcome ?? state.lastProjectOutcome,
      experience: succeeded == true
          ? state.experience + project.experienceReward
          : state.experience,
      completedProjects: succeeded == true
          ? state.completedProjects + 1
          : state.completedProjects,
      financeLedger: CompanyFinanceRecorder.record(
        state,
        FinanceCategory.companyProject,
        nextFunds - state.companyFunds,
      ),
    );
    final invitationMessage = invitationUsed
        ? ' Özel proje daveti kullanıldı.'
        : '';
    final timingMessage = outcome?.delayed == true ? 'Gecikmeli' : 'Zamanında';
    return CompanyActionResult(
      state: nextState,
      message: switch (succeeded) {
        true =>
          'Proje başarıyla tamamlandı. Kalite: ${outcome!.quality.label}. '
              'Teslimat: $timingMessage. Net şirket geliri: ₺${outcome.netIncome}.'
              '$invitationMessage',
        false =>
          'Proje başarısız oldu. Kalite: ${outcome!.quality.label}. '
              'Teslimat: $timingMessage. Şirket kasasından ₺${project.cost} gider yazıldı.'
              '$invitationMessage',
        null => 'Proje otomatik olarak %$totalProgress ilerledi.',
      },
      succeeded: succeeded,
      projectOutcome: outcome,
    );
  }

  CompanyCheck checkProjectSelection(
    PlayerState state,
    CompanyProject project,
  ) {
    if (state.companyLevel == 0) {
      return const CompanyCheck(
        isEligible: false,
        reason: 'Önce şirketini kurmalısın.',
      );
    }
    if (project.requiresSeasonInvitation &&
        !_seasonRewardService.hasProjectInvitation(state)) {
      return const CompanyCheck(
        isEligible: false,
        reason: 'Bu sözleşme için sezon ödülü olan özel proje daveti gerekli.',
      );
    }
    return const CompanyCheck(isEligible: true, reason: 'Proje seçilebilir.');
  }

  PlayerState selectProject(PlayerState state, CompanyProject project) {
    final check = checkProjectSelection(state, project);
    if (!check.isEligible) throw GameRuleException(check.reason);
    return state.copyWith(
      activeProjectId: project.id,
      projectProgress: state.activeProjectId == project.id
          ? state.projectProgress
          : 0,
      projectElapsedDays: state.activeProjectId == project.id
          ? state.projectElapsedDays
          : 0,
    );
  }
}
