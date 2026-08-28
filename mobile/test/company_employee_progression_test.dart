import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_employee.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_specialty.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_management_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_wellbeing_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_market_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_project_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_project_strategy_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  const employee = CompanyEmployee(
    id: 1,
    name: 'Deneyimli Çalışan',
    role: 'Operasyon uzmanı',
    performance: 82,
    dailySalary: 50,
    experience: 60,
    burnout: 20,
  );

  test('burnout lowers effective power and job fit follows specialty', () {
    final exhausted = employee.copyWith(burnout: 90);

    expect(
      exhausted.effectivePerformance,
      lessThan(employee.effectivePerformance),
    );
    expect(employee.jobFitPercentFor(CompanySpecialty.operations), 100);
    expect(employee.jobFitPercentFor(CompanySpecialty.logistics), 75);
    expect(employee.jobFitPercentFor(CompanySpecialty.finance), 50);
  });

  test('matching job fit improves project speed and success', () {
    final project = CompanyProjectCatalog.projects.first;
    final state = PlayerState.initial.copyWith(companyLevel: 1);
    const mismatched = CompanyEmployee(
      id: 2,
      name: 'Uyumsuz Çalışan',
      role: 'Finans analisti',
      performance: 82,
      dailySalary: 50,
    );
    final service = CompanyProjectStrategyService();
    final matching = service.forecast(
      state: state,
      project: project,
      employees: const [employee],
    );
    final other = service.forecast(
      state: state,
      project: project,
      employees: const [mismatched],
    );

    expect(matching.dailyProgress, greaterThan(other.dailyProgress));
    expect(matching.successChance, greaterThan(other.successChance));
  });

  test('promotion raises seniority and records its company cost', () {
    final service = CompanyEmployeeManagementService();
    final cost = CompanyEmployeeManagementService.promotionCost(employee);
    final state = PlayerState.initial.copyWith(
      companyLevel: 1,
      companyFunds: cost + 100,
      employeeCount: 1,
      employees: const [employee],
    );
    final inexperienced = state.copyWith(
      employees: [employee.copyWith(experience: 59)],
    );

    final check = service.checkHeadquarters(state, employee.id);
    final promoted = service.promoteHeadquarters(state, employee.id);

    expect(
      service.checkHeadquarters(inexperienced, employee.id).isEligible,
      isFalse,
    );
    expect(check.isEligible, isTrue);
    expect(promoted.companyFunds, 100);
    expect(
      promoted.employees.single.seniority,
      CompanyEmployeeSeniority.specialist,
    );
    expect(
      promoted.employees.single.dailySalary,
      greaterThan(employee.dailySalary),
    );
  });

  test(
    'raise decisions update salary and wellbeing at headquarters and branch',
    () {
      final service = CompanyEmployeeManagementService();
      final requesting = employee.copyWith(requestedDailySalary: 60);
      final headquarters = PlayerState.initial.copyWith(
        employees: [requesting],
      );
      final accepted = service.respondToHeadquartersRaise(
        headquarters,
        employee.id,
        accept: true,
      );

      expect(accepted.employees.single.dailySalary, 60);
      expect(accepted.employees.single.requestedDailySalary, isNull);
      expect(
        accepted.employees.single.loyalty,
        greaterThan(requesting.loyalty),
      );

      final branchState = PlayerState.initial.copyWith(
        branches: [
          CompanyBranch(id: 1, cityId: 1, employees: [requesting]),
        ],
      );
      final rejected = service.respondToBranchRaise(
        branchState,
        1,
        employee.id,
        accept: false,
      );
      final branchEmployee = rejected.branches.single.employees.single;
      expect(branchEmployee.dailySalary, employee.dailySalary);
      expect(branchEmployee.requestedDailySalary, isNull);
      expect(branchEmployee.loyalty, lessThan(requesting.loyalty));
    },
  );

  test(
    'daily work grants experience, changes burnout, and can request a raise',
    () {
      final working = employee.copyWith(experience: 58, burnout: 30);
      final state = PlayerState.initial.copyWith(
        companyLevel: 1,
        employeeCount: 1,
        employees: [working],
      );
      final outcome = DailyMarketOutcome(
        day: 19,
        forecast: CompanyMarketForecast(
          event: CompanyMarketService.events.first,
          competitor: CompanyMarketService.competitors.first,
          playerScore: 80,
          competitorScore: 20,
          fundsDelta: 100,
          activeEmployeeCount: 1,
          daysRemaining: 1,
        ),
        actualFundsDelta: 100,
      );

      final result = CompanyEmployeeWellbeingService().process(state, [
        outcome,
      ]);
      final updated = result.state.employees.single;

      expect(updated.experience, 62);
      expect(updated.burnout, lessThan(working.burnout));
      expect(updated.requestedDailySalary, greaterThan(working.dailySalary));
      expect(result.messages, isNotEmpty);
    },
  );
}
