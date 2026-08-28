import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_employee.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_region.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_branch_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_wellbeing_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_market_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_project_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_project_strategy_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_region_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  test('all 81 cities belong to exactly one strategic region', () {
    final service = CompanyRegionService();
    final assigned = CompanyRegionService.definitions
        .expand((definition) => definition.cityNames)
        .toList();

    expect(assigned, hasLength(81));
    expect(assigned.toSet(), hasLength(81));
    for (final city in CityCatalog.cities) {
      expect(service.definitionForCity(city), isNotNull, reason: city.name);
    }
  });

  test('four branch-level influence points unlock regional control', () {
    final service = CompanyRegionService();
    final definition = _definition(CompanyRegion.marmara);
    final belowTarget = _stateWithRegion(
      CompanyRegion.marmara,
      levels: const [2, 1],
    );
    final controlled = _stateWithRegion(
      CompanyRegion.marmara,
      levels: const [2, 2],
    );

    expect(service.progress(belowTarget, definition).isControlled, isFalse);
    expect(service.progress(controlled, definition).isControlled, isTrue);
  });

  test('every controlled region activates its distinct advantage', () {
    final service = CompanyRegionService();

    expect(service.revenueBonus(_controlled(CompanyRegion.marmara)), 8);
    expect(
      service.projectSuccessBonusFor(_controlled(CompanyRegion.aegean)),
      5,
    );
    expect(service.marketBonus(_controlled(CompanyRegion.mediterranean)), 10);
    expect(
      service.payrollDiscount(_controlled(CompanyRegion.centralAnatolia)),
      8,
    );
    expect(service.moraleProtection(_controlled(CompanyRegion.blackSea)), 1);
    expect(
      service.investmentDiscount(_controlled(CompanyRegion.easternAnatolia)),
      10,
    );
    expect(
      service.projectProgressBonusFor(
        _controlled(CompanyRegion.southeasternAnatolia),
      ),
      1,
    );
  });

  test('branch finance applies revenue, payroll, and investment bonuses', () {
    final branchService = CompanyBranchService();
    final employee = _employee();
    final marmara = _controlled(CompanyRegion.marmara, employees: [employee]);
    final central = _controlled(
      CompanyRegion.centralAnatolia,
      employees: [employee],
    );
    final east = _controlled(CompanyRegion.easternAnatolia);
    final targetCity = CityCatalog.cities.first;
    final marmaraBranch = marmara.branches.first;
    final centralBranch = central.branches.first;

    expect(
      branchService.dailyRevenueFor(marmara, marmaraBranch),
      (branchService.dailyRevenue(marmaraBranch) * 1.08).round(),
    );
    expect(
      branchService.dailyPayrollFor(central, centralBranch),
      (branchService.dailyPayroll(centralBranch) * .92).round(),
    );
    expect(
      branchService.openingCostFor(east, targetCity),
      (CompanyBranchService.openingCost(targetCity) * .90).round(),
    );
  });

  test('regional project bonuses affect forecast quality and speed', () {
    final service = CompanyProjectStrategyService();
    final base = PlayerState.initial.copyWith(
      companyLevel: 3,
      employees: [_employee()],
      employeeCount: 1,
    );
    final aegean = base.copyWith(
      branches: _branches(CompanyRegion.aegean, const [2, 2]),
    );
    final southeast = base.copyWith(
      branches: _branches(CompanyRegion.southeasternAnatolia, const [2, 2]),
    );
    final project = CompanyProjectCatalog.projects.first;
    final baseForecast = service.forecast(
      state: base,
      project: project,
      employees: base.employees,
    );
    final successForecast = service.forecast(
      state: aegean,
      project: project,
      employees: aegean.employees,
    );
    final speedForecast = service.forecast(
      state: southeast,
      project: project,
      employees: southeast.employees,
    );

    expect(successForecast.successChance, baseForecast.successChance + 5);
    expect(speedForecast.dailyProgress, baseForecast.dailyProgress + 1);
  });

  test(
    'market and morale bonuses apply only to positive or negative outcomes',
    () {
      final marketService = CompanyMarketService();
      final wellbeingService = CompanyEmployeeWellbeingService();
      final base = PlayerState.initial.copyWith(
        day: 1,
        companyLevel: 3,
        companyFunds: 10000,
        employees: [_employee()],
        employeeCount: 1,
        branches: _mixedBranches(),
      );
      final mediterranean = base.copyWith(
        branches: _branches(CompanyRegion.mediterranean, const [1, 1, 1, 1]),
      );
      final baseMarket = marketService.forecast(base);
      final boostedMarket = marketService.forecast(mediterranean);
      final losingOutcome = DailyMarketOutcome(
        day: 3,
        forecast: CompanyMarketForecast(
          event: CompanyMarketService.events[2],
          competitor: CompanyMarketService.competitors.last,
          playerScore: 10,
          competitorScore: 90,
          fundsDelta: -50,
          activeEmployeeCount: 1,
          daysRemaining: 1,
        ),
        actualFundsDelta: -50,
      );
      final blackSea = base.copyWith(
        branches: _branches(CompanyRegion.blackSea, const [1, 1, 1, 1]),
      );
      final baseMorale = wellbeingService.process(base, [losingOutcome]);
      final protectedMorale = wellbeingService.process(blackSea, [
        losingOutcome,
      ]);

      expect(baseMarket.fundsDelta, greaterThan(0));
      expect(boostedMarket.fundsDelta, (baseMarket.fundsDelta * 1.10).round());
      expect(
        protectedMorale.state.employees.single.morale,
        baseMorale.state.employees.single.morale + 1,
      );
    },
  );
}

CompanyRegionDefinition _definition(CompanyRegion region) =>
    CompanyRegionService.definitions.firstWhere(
      (definition) => definition.region == region,
    );

PlayerState _controlled(
  CompanyRegion region, {
  List<CompanyEmployee> employees = const [],
}) => _stateWithRegion(region, levels: const [2, 2], employees: employees);

PlayerState _stateWithRegion(
  CompanyRegion region, {
  required List<int> levels,
  List<CompanyEmployee> employees = const [],
}) => PlayerState.initial.copyWith(
  companyLevel: 3,
  companyFunds: 100000,
  branches: _branches(region, levels, employees: employees),
);

List<CompanyBranch> _branches(
  CompanyRegion region,
  List<int> levels, {
  List<CompanyEmployee> employees = const [],
}) {
  final cityNames = _definition(region).cityNames.toList();
  return [
    for (var index = 0; index < levels.length; index++)
      CompanyBranch(
        id: CityCatalog.cities
            .firstWhere((city) => city.name == cityNames[index])
            .id,
        cityId: CityCatalog.cities
            .firstWhere((city) => city.name == cityNames[index])
            .id,
        level: levels[index],
        employees: index == 0 ? employees : const [],
      ),
  ];
}

List<CompanyBranch> _mixedBranches() => [
  for (final region in CompanyRegion.values.take(4))
    _branches(region, const [1]).single,
];

CompanyEmployee _employee() => const CompanyEmployee(
  id: 700,
  name: 'Bölge Uzmanı',
  role: 'Operasyon uzmanı',
  performance: 80,
  dailySalary: 50,
  morale: 70,
  loyalty: 70,
);
