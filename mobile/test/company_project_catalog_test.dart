import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_project.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_project_catalog.dart';

void main() {
  test('project catalog offers balanced and valid contract categories', () {
    final projects = CompanyProjectCatalog.projects;
    final ids = projects.map((project) => project.id).toSet();

    expect(projects, hasLength(15));
    expect(ids, hasLength(projects.length));
    expect(ids, containsAll(List<int>.generate(15, (index) => index + 1)));

    const expectedCounts = <CompanyProjectCategory, int>{
      CompanyProjectCategory.shortTerm: 4,
      CompanyProjectCategory.mediumTerm: 4,
      CompanyProjectCategory.large: 4,
      CompanyProjectCategory.strategic: 3,
    };
    for (final entry in expectedCounts.entries) {
      expect(
        projects.where((project) => project.category == entry.key).length,
        entry.value,
      );
    }
    for (final project in projects) {
      expect(project.cost, greaterThan(0));
      expect(project.reward, greaterThan(project.cost));
      expect(project.progressPerEmployee, greaterThan(0));
      expect(project.riskPercent, inInclusiveRange(0, 100));
      expect(project.recommendedCompanyLevel, inInclusiveRange(1, 3));
      expect(project.deliveryDays, greaterThan(0));
      expect(project.delayRiskPercent, inInclusiveRange(0, 100));
    }
    expect(
      projects.map((project) => project.customerType).toSet(),
      containsAll(CompanyCustomerType.values),
    );

    final invited = projects.singleWhere(
      (project) => project.requiresSeasonInvitation,
    );
    expect(invited.category, CompanyProjectCategory.strategic);
  });
}
