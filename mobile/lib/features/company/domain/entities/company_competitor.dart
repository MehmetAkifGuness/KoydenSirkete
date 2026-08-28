import 'company_specialty.dart';

class CompanyCompetitor {
  const CompanyCompetitor({
    required this.id,
    required this.name,
    required this.leaderName,
    required this.personality,
    required this.specialty,
    required this.baseStrength,
    required this.growthFocus,
    required this.branchIntervalDays,
    required this.hiringIntervalDays,
    required this.dailyFinanceGrowth,
    required this.dailyProjectProgress,
    required this.strengthTitle,
    required this.strengthDescription,
    required this.strongEventId,
    required this.strongEventBonus,
    required this.weaknessTitle,
    required this.weaknessDescription,
    required this.weakEventId,
    required this.weakEventPenalty,
  });

  final String id;
  final String name;
  final String leaderName;
  final String personality;
  final CompanySpecialty specialty;
  final int baseStrength;
  final String growthFocus;
  final int branchIntervalDays;
  final int hiringIntervalDays;
  final int dailyFinanceGrowth;
  final int dailyProjectProgress;
  final String strengthTitle;
  final String strengthDescription;
  final String strongEventId;
  final int strongEventBonus;
  final String weaknessTitle;
  final String weaknessDescription;
  final String weakEventId;
  final int weakEventPenalty;
}
