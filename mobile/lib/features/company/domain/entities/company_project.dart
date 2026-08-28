import 'company_specialty.dart';

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
  final bool requiresSeasonInvitation;
}
