import '../../../skills/domain/entities/skill_id.dart';

class WorkTask {
  const WorkTask({
    required this.id,
    required this.jobId,
    required this.title,
    required this.description,
    required this.energyCost,
    required this.durationHours,
    required this.salaryMultiplier,
    required this.performanceGain,
    required this.experienceGain,
    this.skillRequirements = const {},
    this.contextLabel,
  });

  final int id;
  final int jobId;
  final String title;
  final String description;
  final int energyCost;
  final int durationHours;
  final double salaryMultiplier;
  final int performanceGain;
  final int experienceGain;
  final Map<SkillId, int> skillRequirements;
  final String? contextLabel;
}
