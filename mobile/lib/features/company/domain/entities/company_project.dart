import 'company_specialty.dart';

enum CompanyProjectCategory {
  shortTerm('Kısa sözleşme'),
  mediumTerm('Orta sözleşme'),
  large('Büyük sözleşme'),
  strategic('Stratejik sözleşme');

  const CompanyProjectCategory(this.label);

  final String label;
}

class CompanyProject {
  const CompanyProject({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.reward,
    required this.progressPerEmployee,
    required this.experienceReward,
    required this.riskPercent,
    required this.recommendedCompanyLevel,
    required this.specialty,
    required this.category,
    this.requiresSeasonInvitation = false,
  });

  final int id;
  final String name;
  final String description;
  final int cost;
  final int reward;
  final int progressPerEmployee;
  final int experienceReward;
  final int riskPercent;
  final int recommendedCompanyLevel;
  final CompanySpecialty specialty;
  final CompanyProjectCategory category;
  final bool requiresSeasonInvitation;
}
