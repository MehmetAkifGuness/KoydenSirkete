import '../entities/company_competition_state.dart';
import '../entities/company_competitor.dart';
import '../entities/company_employee.dart';
import '../entities/company_season_rule.dart';
import '../entities/company_specialty.dart';

class CompanySeasonRuleService {
  const CompanySeasonRuleService();

  static const rules = <CompanySeasonRule>[
    CompanySeasonRule(
      id: 'demand_explosion',
      title: 'Talep patlaması',
      description:
          'Tüketici harcamaları yükseliyor; satış ekipleri pazarı daha hızlı büyütüyor.',
      favoredSpecialty: CompanySpecialty.sales,
      revenuePercent: 10,
      payrollPercent: 2,
      specialtyStrengthBonus: 5,
    ),
    CompanySeasonRule(
      id: 'high_inflation',
      title: 'Yüksek enflasyon',
      description:
          'Gelirler artsa da ücret baskısı daha hızlı büyüyor; finans ekipleri avantajlı.',
      favoredSpecialty: CompanySpecialty.finance,
      revenuePercent: 5,
      payrollPercent: 10,
      specialtyStrengthBonus: 5,
    ),
    CompanySeasonRule(
      id: 'staffing_crisis',
      title: 'Personel krizi',
      description:
          'Nitelikli çalışan maliyeti yükseliyor; liderlik ekipleri düzeni koruyor.',
      favoredSpecialty: CompanySpecialty.leadership,
      revenuePercent: 0,
      payrollPercent: 8,
      specialtyStrengthBonus: 5,
    ),
    CompanySeasonRule(
      id: 'technology_shift',
      title: 'Teknoloji dönüşümü',
      description:
          'Dijital yatırım dalgası geliri artırıyor; teknoloji ekipleri öne çıkıyor.',
      favoredSpecialty: CompanySpecialty.technology,
      revenuePercent: 6,
      payrollPercent: 3,
      specialtyStrengthBonus: 5,
    ),
  ];

  CompanySeasonRule ruleForSeason(int seasonNumber) {
    final season = seasonNumber.clamp(1, 1 << 31).toInt();
    return rules[(season - 1) % rules.length];
  }

  CompanySeasonRule ruleForDay(int day) =>
      ruleForSeason(CompanyCompetitionState.seasonForDay(day));

  int employeeStrengthModifier(
    Iterable<CompanyEmployee> employees,
    CompanySeasonRule rule,
  ) => employees.any((employee) => employee.specialty == rule.favoredSpecialty)
      ? rule.specialtyStrengthBonus
      : 0;

  int competitorStrengthModifier(
    CompanyCompetitor competitor,
    CompanySeasonRule rule,
  ) => competitor.specialty == rule.favoredSpecialty
      ? rule.specialtyStrengthBonus
      : 0;
}
