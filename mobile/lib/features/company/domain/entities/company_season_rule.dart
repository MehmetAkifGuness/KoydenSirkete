import 'company_specialty.dart';

class CompanySeasonRule {
  const CompanySeasonRule({
    required this.id,
    required this.title,
    required this.description,
    required this.favoredSpecialty,
    required this.revenuePercent,
    required this.payrollPercent,
    required this.specialtyStrengthBonus,
  });

  const CompanySeasonRule.neutral()
    : id = 'neutral',
      title = 'Standart sezon',
      description = 'Sezon genelinde ek piyasa etkisi yok.',
      favoredSpecialty = CompanySpecialty.operations,
      revenuePercent = 0,
      payrollPercent = 0,
      specialtyStrengthBonus = 0;

  final String id;
  final String title;
  final String description;
  final CompanySpecialty favoredSpecialty;
  final int revenuePercent;
  final int payrollPercent;
  final int specialtyStrengthBonus;
}
