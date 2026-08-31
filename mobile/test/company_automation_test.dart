import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_employee.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_automation_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  const service = CompanyAutomationService();
  const headquartersEmployee = CompanyEmployee(
    id: 1,
    name: 'Merkez uzmanı',
    role: 'Operasyon',
    performance: 80,
    dailySalary: 100,
    requestedDailySalary: 110,
  );
  const branchEmployee = CompanyEmployee(
    id: 2,
    name: 'Bayi lideri',
    role: 'Lider',
    performance: 90,
    dailySalary: 120,
    requestedDailySalary: 160,
  );

  test('balanced automation assigns teams, managers and resolves raises', () {
    final state = PlayerState.initial.copyWith(
      companyLevel: 2,
      employees: [headquartersEmployee],
      branches: const [
        CompanyBranch(id: 1, cityId: 1, employees: [branchEmployee]),
      ],
    );

    final result = service.apply(state, CompanyAutomationPreset.balanced);

    expect(result.state.companyProjectTeams.employeeIdsFor(1), [1]);
    expect(result.state.employees.single.dailySalary, 110);
    expect(result.state.employees.single.hasRaiseRequest, isFalse);
    expect(result.state.branches.single.employees.single.dailySalary, 120);
    expect(
      result.state.branches.single.employees.single.hasRaiseRequest,
      isFalse,
    );
    expect(result.state.branches.single.managerEmployeeId, 2);
    expect(result.managerCount, 1);
    expect(result.raiseCount, 2);
  });
}
