import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/features/assets/domain/services/car_catalog.dart';
import 'package:kariyerden_sirkete/features/assets/domain/services/home_catalog.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_branch_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_catalog.dart';
import 'package:kariyerden_sirkete/features/economy/domain/services/investment_return_service.dart';
import 'package:kariyerden_sirkete/features/training/domain/services/training_catalog.dart';

void main() {
  test('personal investments stay inside their payback targets', () {
    final homeTarget = InvestmentReturnService.target(InvestmentType.home);
    for (final city in CityCatalog.cities) {
      for (final home in HomeCatalog.forCity(city)) {
        expect(
          homeTarget.contains(InvestmentReturnService.homeDays(home)),
          isTrue,
        );
      }
    }

    final carTarget = InvestmentReturnService.target(InvestmentType.car);
    for (final car in CarCatalog.cars) {
      expect(carTarget.contains(InvestmentReturnService.carDays(car)), isTrue);
    }

    final trainingTarget = InvestmentReturnService.target(
      InvestmentType.training,
    );
    for (final course in TrainingCatalog.courses.where(
      (item) => item.cost > 0,
    )) {
      expect(
        trainingTarget.contains(InvestmentReturnService.trainingDays(course)),
        isTrue,
      );
    }
  });

  test('company investments stay inside their payback targets', () {
    final upgradeTarget = InvestmentReturnService.target(
      InvestmentType.companyUpgrade,
    );
    for (final level in const [1, 2]) {
      expect(
        upgradeTarget.contains(
          InvestmentReturnService.companyUpgradeDays(level),
        ),
        isTrue,
      );
    }

    final branchTarget = InvestmentReturnService.target(InvestmentType.branch);
    final branches = CompanyBranchService();
    for (final city in CityCatalog.cities) {
      final employee = CompanyEmployeeCatalog.availableForCity(
        cityId: city.id,
        occupiedSlots: 0,
        hiredIds: const [],
      ).first;
      final branch = CompanyBranch(
        id: city.id,
        cityId: city.id,
        employees: [employee],
      );
      final dailyNet =
          branches.dailyRevenue(branch) - branches.dailyPayroll(branch);
      final days = InvestmentReturnService.estimateDays(
        cost: CompanyBranchService.openingCost(city),
        dailyBenefit: dailyNet,
      );
      expect(branchTarget.contains(days), isTrue);
    }
  });
}
