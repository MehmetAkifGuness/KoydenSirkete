import 'company_specialty.dart';

class CompanyCompetitionStrategy {
  const CompanyCompetitionStrategy({
    required this.id,
    required this.title,
    required this.description,
    required this.counteredSpecialty,
    required this.baseStrengthBonus,
    required this.counterStrengthBonus,
    required this.revenuePercent,
    required this.payrollPercent,
  });

  const CompanyCompetitionStrategy.neutral()
    : id = '',
      title = 'Strateji seçilmedi',
      description = 'Bu sezon için henüz rekabet stratejisi belirlenmedi.',
      counteredSpecialty = CompanySpecialty.operations,
      baseStrengthBonus = 0,
      counterStrengthBonus = 0,
      revenuePercent = 0,
      payrollPercent = 0;

  final String id;
  final String title;
  final String description;
  final CompanySpecialty counteredSpecialty;
  final int baseStrengthBonus;
  final int counterStrengthBonus;
  final int revenuePercent;
  final int payrollPercent;

  bool get isSelected => id.isNotEmpty;
}

class CompanyStrategyEffect {
  const CompanyStrategyEffect({
    required this.strategy,
    required this.strengthModifier,
    required this.reason,
  });

  final CompanyCompetitionStrategy strategy;
  final int strengthModifier;
  final String reason;
}
