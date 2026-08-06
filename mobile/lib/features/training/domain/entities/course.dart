import '../../../skills/domain/entities/skill_id.dart';

class Course {
  const Course({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.durationHours,
    required this.energyCost,
    required this.knowledge,
    required this.experience,
    this.skillDeltas = const {},
  });

  final String id;
  final String name;
  final String description;
  final int cost;
  final int durationHours;
  final int energyCost;
  final int knowledge;
  final int experience;
  final Map<SkillId, int> skillDeltas;
}
