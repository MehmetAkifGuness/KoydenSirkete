import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/core/errors/game_rule_exception.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_employee.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_specialty.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_branch_management_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_branch_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_wellbeing_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_market_service.dart';
import 'package:kariyerden_sirkete/features/game/data/mappers/company_branch_codec.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  const manager = CompanyEmployee(
    id: 11,
    name: 'Deniz Akın',
    role: 'Şube yöneticisi',
    performance: 90,
    dailySalary: 70,
    experience: 400,
    seniority: CompanyEmployeeSeniority.senior,
    burnout: 20,
  );
  const technologyEmployee = CompanyEmployee(
    id: 12,
    name: 'Ece Yalın',
    role: 'Dijital uzmanı',
    performance: 85,
    dailySalary: 55,
  );
  final city = CityCatalog.cities[2];
  final branch = CompanyBranch(
    id: city.id,
    cityId: city.id,
    employees: const [manager, technologyEmployee],
  );
  final state = PlayerState.initial.copyWith(
    companyLevel: 3,
    companyFunds: 10000,
    branches: [branch],
  );
  const management = CompanyBranchManagementService();

  test('legacy branch defaults preserve city specialty and balanced goal', () {
    expect(
      management.effectiveSpecialty(branch),
      CompanyBranchService.preferredSpecialty(city),
    );
    expect(branch.localGoal, CompanyBranchLocalGoal.balanced);
    expect(management.managerFor(branch), isNull);
    expect(management.managerRevenueBonusPercent(branch), 0);
  });

  test('manager must be a branch employee and increases revenue', () {
    final managed = management.setManager(state, city.id, manager.id);
    final managedBranch = managed.branches.single;
    final service = CompanyBranchService();

    expect(managedBranch.managerEmployeeId, manager.id);
    expect(
      management.managerRevenueBonusPercent(managedBranch),
      greaterThan(0),
    );
    expect(
      service.dailyRevenue(managedBranch),
      greaterThan(service.dailyRevenue(branch)),
    );
    expect(
      () => management.setManager(state, city.id, 9999),
      throwsA(isA<GameRuleException>()),
    );
  });

  test('selected specialty controls which employee earns the bonus', () {
    final technologyOnly = branch.copyWith(
      employees: const [technologyEmployee],
      specialty: CompanySpecialty.technology,
    );
    final operationsFocus = technologyOnly.copyWith(
      specialty: CompanySpecialty.operations,
    );
    final service = CompanyBranchService();

    expect(
      service.dailyRevenue(technologyOnly) -
          service.dailyRevenue(operationsFocus),
      CompanyBranchService.specialistDailyRevenueBonus,
    );
  });

  test('local goals apply explicit economy and employee tradeoffs', () {
    final service = CompanyBranchService();
    final growth = branch.copyWith(
      localGoal: CompanyBranchLocalGoal.marketGrowth,
    );
    final costControl = branch.copyWith(
      localGoal: CompanyBranchLocalGoal.costControl,
    );
    final development = branch.copyWith(
      localGoal: CompanyBranchLocalGoal.teamDevelopment,
      employees: [manager.copyWith(experience: 20, burnout: 30)],
    );
    final developmentState = state.copyWith(branches: [development]);

    expect(
      service.dailyRevenue(growth),
      greaterThan(service.dailyRevenue(branch)),
    );
    expect(
      service.dailyPayrollFor(state, costControl),
      lessThan(service.dailyPayrollFor(state, branch)),
    );

    final operated = service.processDailyOperations(developmentState).state;
    final developedEmployee = operated.branches.single.employees.single;
    expect(developedEmployee.experience, 22);
    expect(developedEmployee.burnout, 29);
  });

  test('dismissal and resignation clear stale manager assignment', () {
    final managedBranch = branch.copyWith(managerEmployeeId: manager.id);
    final managedState = state.copyWith(branches: [managedBranch]);
    final dismissed = CompanyBranchService().dismiss(
      managedState,
      city.id,
      manager.id,
    );
    expect(dismissed.branches.single.managerEmployeeId, isNull);

    final atRiskManager = manager.copyWith(loyalty: 10, morale: 10);
    final resigningState = state.copyWith(
      branches: [
        branch.copyWith(
          employees: [atRiskManager],
          managerEmployeeId: atRiskManager.id,
        ),
      ],
    );
    final outcome = DailyMarketOutcome(
      day: 1,
      forecast: CompanyMarketForecast(
        event: CompanyMarketService.events.first,
        competitor: CompanyMarketService.competitors.first,
        playerScore: 10,
        competitorScore: 90,
        fundsDelta: -100,
        activeEmployeeCount: 1,
        daysRemaining: 1,
      ),
      actualFundsDelta: -100,
    );
    final resigned = CompanyEmployeeWellbeingService().process(resigningState, [
      outcome,
    ]);
    expect(resigned.state.branches.single.employees, isEmpty);
    expect(resigned.state.branches.single.managerEmployeeId, isNull);
  });

  test('branch codec preserves management and employee career fields', () {
    final configured = branch.copyWith(
      managerEmployeeId: manager.id,
      localGoal: CompanyBranchLocalGoal.teamDevelopment,
      specialty: CompanySpecialty.leadership,
    );
    final codec = CompanyBranchCodec();

    final decoded = codec.decodeList(codec.encodeList([configured])).single;

    expect(decoded.managerEmployeeId, manager.id);
    expect(decoded.localGoal, CompanyBranchLocalGoal.teamDevelopment);
    expect(decoded.specialty, CompanySpecialty.leadership);
    expect(decoded.employees.first.experience, manager.experience);
    expect(decoded.employees.first.seniority, manager.seniority);
    expect(decoded.employees.first.burnout, manager.burnout);
  });
}
