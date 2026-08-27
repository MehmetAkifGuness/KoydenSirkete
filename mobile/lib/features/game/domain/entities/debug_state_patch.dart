import '../../../skills/domain/entities/skill_id.dart';

class DebugStatePatch {
  const DebugStatePatch({
    this.money,
    this.energy,
    this.maxEnergy,
    this.knowledge,
    this.experience,
    this.day,
    this.hour,
    this.careerLevel,
    this.companyFunds,
    this.performance,
    this.skills,
  });

  final int? money;
  final int? energy;
  final int? maxEnergy;
  final int? knowledge;
  final int? experience;
  final int? day;
  final int? hour;
  final int? careerLevel;
  final int? companyFunds;
  final int? performance;
  final Map<SkillId, int>? skills;
}
