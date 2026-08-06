import '../../../skills/domain/entities/skill_id.dart';

class Job {
  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    required this.salary,
    required this.minimumKnowledge,
    required this.minimumExperience,
    this.careerTrack = 'genel',
    this.level = 1,
    this.nextJobId,
    this.cityId,
    this.opportunityWeight = 1,
    this.skillRequirements = const {},
  });

  final int id;
  final String title;
  final String company;
  final String description;
  final int salary;
  final int minimumKnowledge;
  final int minimumExperience;
  final String careerTrack;
  final int level;
  final int? nextJobId;
  final int? cityId;
  final int opportunityWeight;
  final Map<SkillId, int> skillRequirements;
}
