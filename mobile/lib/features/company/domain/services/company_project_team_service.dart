import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/company_employee.dart';
import '../entities/company_project.dart';
import '../entities/company_specialty.dart';
import 'company_employee_catalog.dart';

class CompanyProjectTeamSummary {
  const CompanyProjectTeamSummary({
    required this.employeeCount,
    required this.specialistCount,
    required this.averageJobFit,
  });

  final int employeeCount;
  final int specialistCount;
  final int averageJobFit;
}

class CompanyProjectTeamService {
  const CompanyProjectTeamService();

  List<CompanyEmployee> teamFor(PlayerState state, CompanyProject project) {
    final employees = _employeesFor(state);
    if (!state.companyProjectTeams.isConfigured(project.id)) return employees;
    final selectedIds = state.companyProjectTeams
        .employeeIdsFor(project.id)
        .toSet();
    return employees
        .where((employee) => selectedIds.contains(employee.id))
        .toList(growable: false);
  }

  bool isAssigned(PlayerState state, CompanyProject project, int employeeId) =>
      teamFor(state, project).any((employee) => employee.id == employeeId);

  CompanyProjectTeamSummary summaryFor(
    PlayerState state,
    CompanyProject project,
  ) {
    final team = teamFor(state, project);
    if (team.isEmpty) {
      return const CompanyProjectTeamSummary(
        employeeCount: 0,
        specialistCount: 0,
        averageJobFit: 0,
      );
    }
    return CompanyProjectTeamSummary(
      employeeCount: team.length,
      specialistCount: team
          .where((employee) => employee.specialty == project.specialty)
          .length,
      averageJobFit:
          team.fold<int>(
            0,
            (total, employee) =>
                total + employee.jobFitPercentFor(project.specialty),
          ) ~/
          team.length,
    );
  }

  PlayerState setAssignment(
    PlayerState state, {
    required CompanyProject project,
    required int employeeId,
    required bool assigned,
  }) {
    final employees = _employeesFor(state);
    if (!employees.any((employee) => employee.id == employeeId)) {
      throw const GameRuleException('Bu çalışan şirket merkezinde bulunamadı.');
    }
    final currentIds = state.companyProjectTeams.isConfigured(project.id)
        ? state.companyProjectTeams.employeeIdsFor(project.id).toSet()
        : employees.map((employee) => employee.id).toSet();
    assigned ? currentIds.add(employeeId) : currentIds.remove(employeeId);
    return state.copyWith(
      companyProjectTeams: state.companyProjectTeams.setTeam(
        project.id,
        currentIds,
      ),
    );
  }

  List<CompanyEmployee> _employeesFor(PlayerState state) =>
      state.employees.isNotEmpty
          ? state.employees
          : CompanyEmployeeCatalog.legacyDefaults(state.employeeCount);
}
