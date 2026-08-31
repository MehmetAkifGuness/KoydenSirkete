import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_branch_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_wellbeing_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_market_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_season_event_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_competition_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/economy/domain/entities/economy_difficulty.dart';

void main() {
  test('market events rotate every seven days deterministically', () {
    final service = CompanyMarketService();
    final state = _companyState();
    const seasonEvents = CompanySeasonEventService();
    final schedule = seasonEvents.scheduleForSeason(1);

    expect(service.forecast(state, day: 1).event, schedule[0]);
    expect(service.forecast(state, day: 2).event, schedule[0]);
    expect(service.forecast(state, day: 8).event, schedule[0]);
    expect(service.forecast(state, day: 9).event, schedule[1]);
    expect(service.forecast(state, day: 16).event, schedule[2]);
    expect(service.forecast(state, day: 31).event, schedule[4]);
    expect(
      service.forecast(state, day: 15).playerScore,
      service.forecast(state, day: 15).playerScore,
    );
  });

  test('company development creates a measurable competitive advantage', () {
    final service = CompanyMarketService();
    final employee = CompanyEmployeeCatalog.candidates.first;
    final weak = _companyState().copyWith(
      employees: [employee.copyWith(performance: 40, morale: 40)],
      employeeCount: 1,
    );
    final strong = weak.copyWith(
      companyLevel: 3,
      completedProjects: 12,
      employees: [employee.copyWith(performance: 100, morale: 100)],
    );

    expect(
      service.forecast(strong, day: 20).playerScore,
      greaterThan(service.forecast(weak, day: 20).playerScore),
    );
  });

  test('hard economy gives rivals a variable strength bonus', () {
    final service = CompanyMarketService();
    final normal = _companyState();
    final hard = normal.copyWith(economyDifficulty: EconomyDifficulty.hard);

    expect(
      service.forecast(hard, day: 20).competitorScore,
      greaterThan(service.forecast(normal, day: 20).competitorScore),
    );
  });

  test('market outcome changes funds and employee wellbeing', () {
    final marketService = CompanyMarketService();
    final wellbeingService = CompanyEmployeeWellbeingService();
    final initial = _companyState().copyWith(day: 15);
    final market = marketService.process(initial);
    final updated = wellbeingService.process(market.state, market.outcomes);

    expect(market.outcomes, hasLength(1));
    expect(
      market.state.companyFunds,
      initial.companyFunds + market.outcomes.single.actualFundsDelta,
    );
    expect(market.state.companyFunds, greaterThanOrEqualTo(0));
    expect(
      updated.state.employees.single.morale,
      lessThan(initial.employees.single.morale),
    );
  });

  test('six-month company simulation stays bounded and internally valid', () {
    final companyService = CompanyService();
    final branchService = CompanyBranchService();
    final marketService = CompanyMarketService();
    final wellbeingService = CompanyEmployeeWellbeingService();
    final competitionService = CompanyCompetitionService();
    final staff = CompanyEmployeeCatalog.candidates.take(7).toList();
    var state = PlayerState.initial.copyWith(
      day: 1,
      companyLevel: 3,
      companyFunds: 100000,
      employeeCount: 4,
      employees: staff.take(4).toList(),
      branches: [
        CompanyBranch(
          id: 1,
          cityId: 1,
          level: 2,
          employees: staff.skip(4).toList(),
        ),
      ],
    );
    final observedEvents = <String>{};

    for (var day = 2; day <= 181; day++) {
      state = state.copyWith(day: day);
      state = companyService.processDailyOperations(state).state;
      state = branchService.processDailyOperations(state).state;
      final market = marketService.process(state);
      observedEvents.add(marketService.forecast(state).event.title);
      state = wellbeingService.process(market.state, market.outcomes).state;
      state = competitionService.process(state, market.outcomes).state;

      expect(state.companyFunds, greaterThanOrEqualTo(0));
      expect(state.employeeCount, state.employees.length);
      for (final employee in [
        ...state.employees,
        for (final branch in state.branches) ...branch.employees,
      ]) {
        expect(employee.morale, inInclusiveRange(0, 100));
        expect(employee.loyalty, inInclusiveRange(0, 100));
        expect(employee.effectivePerformance, inInclusiveRange(0, 100));
      }
    }

    expect(observedEvents.length, greaterThanOrEqualTo(12));
    expect(state.companyFunds, lessThan(1000000));
    expect(state.companyCompetition.seasonNumber, 6);
    expect(state.companyCompetition.championships, inInclusiveRange(0, 5));
  });
}

PlayerState _companyState() {
  final employee = CompanyEmployeeCatalog.candidates.first;
  return PlayerState.initial.copyWith(
    companyLevel: 1,
    companyFunds: 10000,
    employeeCount: 1,
    employees: [employee],
  );
}
