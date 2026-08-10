import '../../../skills/domain/entities/skill_id.dart';
import '../../../skills/domain/entities/skill_profile.dart';

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

  Map<SkillId, int> get scaledSkillRequirements => {
        for (final entry in skillRequirements.entries)
          entry.key: ((entry.value * (SkillProfile.maxValue ~/ 100)) * _requirementFactor(level)).round(),
      };

  static double _requirementFactor(int level) {
    return switch (level) {
      1 => .6,
      2 => .65,
      3 => .6,
      4 => .8,
      5 => .9,
      _ => 1,
    };
  }
}
