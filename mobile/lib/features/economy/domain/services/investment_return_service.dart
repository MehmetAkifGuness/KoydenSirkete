import '../../../assets/domain/entities/car_asset.dart';
import '../../../assets/domain/entities/home_asset.dart';
import '../../../assets/domain/services/asset_service.dart';
import '../../../company/domain/services/company_service.dart';
import '../../../training/domain/entities/course.dart';

enum InvestmentType { home, car, training, branch, companyUpgrade }

class InvestmentReturnTarget {
  const InvestmentReturnTarget(this.minimumDays, this.maximumDays);

  final int minimumDays;
  final int maximumDays;

  bool contains(int days) => days >= minimumDays && days <= maximumDays;

  String get label => '$minimumDays–$maximumDays oyun günü';
}

abstract final class InvestmentReturnService {
  static const targets = <InvestmentType, InvestmentReturnTarget>{
    InvestmentType.home: InvestmentReturnTarget(3000, 3600),
    InvestmentType.car: InvestmentReturnTarget(480, 1500),
    InvestmentType.training: InvestmentReturnTarget(2, 5),
    InvestmentType.branch: InvestmentReturnTarget(60, 220),
    InvestmentType.companyUpgrade: InvestmentReturnTarget(150, 550),
  };

  static InvestmentReturnTarget target(InvestmentType type) => targets[type]!;

  static int estimateDays({required int cost, required num dailyBenefit}) {
    if (cost <= 0) return 0;
    if (dailyBenefit <= 0) return 1 << 30;
    return (cost / dailyBenefit).ceil();
  }

  static int homeDays(HomeAsset home) {
    final assets = AssetService();
    final monthlyNet =
        assets.monthlyRent(home) *
        (100 - AssetService.rentalMaintenancePercent) /
        100;
    return estimateDays(cost: home.price, dailyBenefit: monthlyNet / 30);
  }

  static int carDays(CarAsset car) {
    const referenceDailyTransportationCost = 30;
    const dailyOpportunityValue = 25;
    final transportSaving =
        referenceDailyTransportationCost * car.moveDiscountPercent / 200;
    final opportunityValue = car.opportunityBonus * dailyOpportunityValue;
    return estimateDays(
      cost: car.price,
      dailyBenefit: transportSaving + opportunityValue,
    );
  }

  static int trainingDays(Course course) {
    final skillGain = course.skillDeltas.values.fold<int>(
      0,
      (total, gain) => total + gain,
    );
    final dailyCareerValue =
        (course.knowledge + course.experience + skillGain) * 2;
    return estimateDays(cost: course.cost, dailyBenefit: dailyCareerValue);
  }

  static int companyUpgradeDays(int level) {
    const openedEmployeeSlots = 4;
    const referenceEmployeeNetContribution = 25;
    final dailyBenefit =
        CompanyService.dailyBaseRevenue +
        openedEmployeeSlots * referenceEmployeeNetContribution;
    return estimateDays(
      cost: CompanyService.upgradeCost(level),
      dailyBenefit: dailyBenefit,
    );
  }

  static String summary(InvestmentType type, int estimatedDays) =>
      'Tahmini $estimatedDays gün · hedef ${target(type).label}';
}
