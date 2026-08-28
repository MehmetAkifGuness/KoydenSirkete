import '../../../game/domain/entities/player_state.dart';
import '../entities/company_trophy_benefit.dart';

abstract final class CompanyTrophyService {
  static const projectSuccessBonusPercent = 3;
  static const branchRevenueBonusPercent = 4;
  static const branchPayrollDiscountPercent = 4;
  static const marketStrengthBonus = 5;

  static const benefits = <CompanyTrophyBenefit>[
    CompanyTrophyBenefit(
      type: CompanyTrophyBenefitType.projectAssurance,
      requiredTrophies: 1,
      title: 'Proje güvencesi',
      description: 'Proje başarı ihtimali +%3',
    ),
    CompanyTrophyBenefit(
      type: CompanyTrophyBenefitType.branchRevenue,
      requiredTrophies: 3,
      title: 'Ulusal bayi ağı',
      description: 'Tüm bayi gelirleri +%4',
    ),
    CompanyTrophyBenefit(
      type: CompanyTrophyBenefitType.branchPayroll,
      requiredTrophies: 5,
      title: 'İşveren itibarı',
      description: 'Tüm bayi maaşları -%4',
    ),
    CompanyTrophyBenefit(
      type: CompanyTrophyBenefitType.marketAuthority,
      requiredTrophies: 8,
      title: 'Pazar otoritesi',
      description: 'Günlük rekabet gücü +5',
    ),
  ];

  static bool isUnlocked(PlayerState state, CompanyTrophyBenefit benefit) =>
      state.companyCompetition.championships >= benefit.requiredTrophies;

  static CompanyTrophyBenefit? benefitUnlockedAt(int trophyCount) {
    for (final benefit in benefits) {
      if (benefit.requiredTrophies == trophyCount) return benefit;
    }
    return null;
  }

  static CompanyTrophyBenefit? nextBenefit(PlayerState state) {
    for (final benefit in benefits) {
      if (!isUnlocked(state, benefit)) return benefit;
    }
    return null;
  }

  static int projectSuccessBonus(PlayerState state) =>
      _bonus(state, 1, projectSuccessBonusPercent);

  static int branchRevenueBonus(PlayerState state) =>
      _bonus(state, 3, branchRevenueBonusPercent);

  static int branchPayrollDiscount(PlayerState state) =>
      _bonus(state, 5, branchPayrollDiscountPercent);

  static int marketScoreBonus(PlayerState state) =>
      _bonus(state, 8, marketStrengthBonus);

  static int _bonus(PlayerState state, int trophies, int value) =>
      state.companyCompetition.championships >= trophies ? value : 0;
}
