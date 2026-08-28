import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/cities/domain/services/city_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_deal.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_expansion_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_region.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_expansion_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_growth_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_region_service.dart';
import 'package:kariyerden_sirkete/features/finance/domain/entities/finance_ledger.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  final service = CompanyExpansionService();

  test('catalog offers two deals for every expansion type', () {
    for (final type in CompanyDealType.values) {
      expect(
        CompanyExpansionService.deals.where((deal) => deal.type == type),
        hasLength(2),
      );
    }
  });

  test('deal checks stage, region, championship and company funds', () {
    final acquisition = CompanyExpansionService.deals[1];
    final merger = CompanyExpansionService.deals[2];
    final regional = _companyState(stageIndex: 1);

    expect(service.check(regional, acquisition).reason, contains('bölge'));
    expect(service.check(regional, merger).reason, contains('Ulusal marka'));

    final national = _companyState(
      stageIndex: 2,
      branches: _controlledRegions(2),
    );
    expect(service.check(national, merger).reason, contains('şampiyonluğu'));

    final champion = national.copyWith(
      companyCompetition: const CompanyCompetitionState(championships: 1),
      companyFunds: merger.cost - 1,
    );
    expect(service.check(champion, merger).reason, contains('kasasında'));
    expect(
      service
          .check(champion.copyWith(companyFunds: merger.cost), merger)
          .isEligible,
      isTrue,
    );
  });

  test('completed deal spends only company funds and cannot repeat', () {
    final deal = CompanyExpansionService.deals.first;
    final initial = _companyState(stageIndex: 1, companyFunds: deal.cost + 500);
    final result = service.execute(initial, deal);

    expect(result.money, initial.money);
    expect(result.companyFunds, 500);
    expect(result.companyExpansion.completedDealIds, [deal.id]);
    final entry = result.financeLedger.entries.single;
    expect(entry.account, FinanceAccount.company);
    expect(entry.category, FinanceCategory.companyExpansion);
    expect(entry.amount, -deal.cost);
    expect(service.check(result, deal).isEligible, isFalse);
    expect(() => service.execute(result, deal), throwsA(isA<Exception>()));
  });

  test('completed deals permanently increase company growth metrics', () {
    final deals = CompanyExpansionService.deals.take(3).toList();
    final base = _companyState(stageIndex: 2);
    final expanded = base.copyWith(
      companyExpansion: CompanyExpansionState(
        completedDealIds: deals.map((deal) => deal.id).toList(),
      ),
    );
    final growth = CompanyGrowthService();

    expect(
      growth.valuation(expanded) - growth.valuation(base),
      deals.fold(0, (total, deal) => total + deal.valuationGain),
    );
    expect(
      growth.reputation(expanded) - growth.reputation(base),
      deals.fold(0, (total, deal) => total + deal.reputationGain),
    );
    expect(
      growth.marketShare(expanded) - growth.marketShare(base),
      deals.fold(0, (total, deal) => total + deal.marketShareGain),
    );
  });
}

PlayerState _companyState({
  required int stageIndex,
  int companyFunds = 2000000,
  List<CompanyBranch> branches = const [],
}) => PlayerState.initial.copyWith(
  money: 240,
  companyLevel: 3,
  companyFunds: companyFunds,
  companyStageIndex: stageIndex,
  branches: branches,
);

List<CompanyBranch> _controlledRegions(int count) => [
  for (final region in CompanyRegion.values.take(count))
    ..._regionBranches(region),
];

List<CompanyBranch> _regionBranches(CompanyRegion region) {
  final definition = CompanyRegionService.definitions.firstWhere(
    (item) => item.region == region,
  );
  final cities = definition.cityNames
      .take(2)
      .map(
        (name) => CityCatalog.cities.firstWhere((city) => city.name == name),
      );
  return [
    for (final city in cities)
      CompanyBranch(id: city.id, cityId: city.id, level: 2),
  ];
}
