import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/company/domain/entities/company_employee.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_project_team_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_project_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_project_team_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_service.dart';
import 'package:kariyerden_sirkete/features/game/data/mappers/company_project_team_codec.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  const operationsEmployee = CompanyEmployee(
    id: 1,
    name: 'Ayşe Kaya',
    role: 'Operasyon uzmanı',
    performance: 90,
    dailySalary: 40,
  );
  const technologyEmployee = CompanyEmployee(
    id: 2,
    name: 'Can Demir',
    role: 'Dijital uzmanı',
    performance: 90,
    dailySalary: 40,
  );
  final state = PlayerState.initial.copyWith(
    companyLevel: 1,
    companyFunds: 500,
    employeeCount: 2,
    employees: const [operationsEmployee, technologyEmployee],
  );
  const teamService = CompanyProjectTeamService();
  final operationsProject = CompanyProjectCatalog.byId(1);
  final technologyProject = CompanyProjectCatalog.byId(2);

  test('unconfigured legacy projects use every headquarters employee', () {
    expect(teamService.teamFor(state, operationsProject), hasLength(2));
    expect(teamService.summaryFor(state, operationsProject).specialistCount, 1);
  });

  test('first assignment change creates a project-specific team', () {
    final changed = teamService.setAssignment(
      state,
      project: operationsProject,
      employeeId: technologyEmployee.id,
      assigned: false,
    );

    expect(
      changed.companyProjectTeams.isConfigured(operationsProject.id),
      isTrue,
    );
    expect(
      teamService.teamFor(changed, operationsProject).map((item) => item.id),
      [operationsEmployee.id],
    );
    expect(teamService.teamFor(changed, technologyProject), hasLength(2));
  });

  test('only assigned employees affect project forecast', () {
    final allEmployeesForecast = CompanyService().projectForecast(
      state,
      operationsProject,
    );
    final assignedState = state.copyWith(
      companyProjectTeams: const CompanyProjectTeamState(
        employeeIdsByProject: {
          1: [1],
        },
      ),
    );
    final assignedForecast = CompanyService().projectForecast(
      assignedState,
      operationsProject,
    );

    expect(
      assignedForecast.dailyProgress,
      lessThan(allEmployeesForecast.dailyProgress),
    );
    expect(assignedForecast.specialistCount, 1);
  });

  test('an explicitly empty team pauses project progress safely', () {
    final paused = state.copyWith(
      companyProjectTeams: const CompanyProjectTeamState(
        employeeIdsByProject: {1: []},
      ),
    );

    final result = CompanyService().processDailyOperations(paused);

    expect(result.state.projectProgress, 0);
    expect(
      CompanyService().projectForecast(paused, operationsProject).dailyProgress,
      0,
    );
  });

  test('dismissing an employee removes stale project assignments', () {
    final configured = state.copyWith(
      companyProjectTeams: const CompanyProjectTeamState(
        employeeIdsByProject: {
          1: [1, 2],
          2: [2],
        },
      ),
    );

    final changed = CompanyService().dismissEmployee(
      configured,
      technologyEmployee.id,
    );

    expect(changed.companyProjectTeams.employeeIdsFor(1), [1]);
    expect(changed.companyProjectTeams.employeeIdsFor(2), isEmpty);
  });

  test(
    'project team codec preserves explicit empty teams and rejects bad data',
    () {
      const codec = CompanyProjectTeamCodec();
      const expected = CompanyProjectTeamState(
        employeeIdsByProject: {
          1: [1, 2],
          2: [],
        },
      );

      final decoded = codec.decode(codec.encode(expected));

      expect(decoded.employeeIdsFor(1), [1, 2]);
      expect(decoded.isConfigured(2), isTrue);
      expect(decoded.employeeIdsFor(2), isEmpty);
      expect(codec.decode('{bad').employeeIdsByProject, isEmpty);
    },
  );
}
