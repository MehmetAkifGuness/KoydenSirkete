import 'active_activity.dart';
import '../../../skills/domain/entities/skill_profile.dart';
import '../../../employment/domain/entities/employment.dart';

class PlayerState {
  static const _unset = Object();

  const PlayerState({
    required this.schemaVersion,
    required this.money,
    required this.energy,
    required this.knowledge,
    required this.experience,
    required this.day,
    required this.hour,
    required this.earningSessionsToday,
    this.maxEnergy = 100,
    this.energyRecoveryRemainder = 0,
    this.activeActivity,
    this.skills = const SkillProfile(),
    this.employment,
    this.applicationBlockedJobId,
    this.applicationBlockedUntilDay = 0,
    this.lastJobEvent,
    this.jobDataVersion = 3,
    this.taskDataVersion = 2,
    this.dismissedDay = 0,
    this.currentJobId,
    this.performance = 0,
    this.workSessionsToday = 0,
    this.trainingSessionsToday = 0,
    this.dailyGoalClaimedDay = 0,
    this.careerLevel = 1,
    this.currentCityId = 1,
    this.lastLivingCostDay = 1,
    this.companyLevel = 0,
    this.companyFunds = 0,
    this.employeeCount = 0,
    this.projectProgress = 0,
    this.totalEarned = 0,
    this.totalWorkSessions = 0,
    this.totalTrainingSessions = 0,
    this.unlockedAchievementsMask = 0,
    this.activeProjectId = 1,
    this.completedProjects = 0,
    this.isOnboarded = false,
  });

  static const initial = PlayerState(
    schemaVersion: 15,
    money: 240,
    energy: 100,
    knowledge: 0,
    experience: 0,
    day: 1,
    hour: 8,
    earningSessionsToday: 0,
    maxEnergy: 100,
    energyRecoveryRemainder: 0,
    activeActivity: null,
    skills: SkillProfile.empty,
    employment: null,
    jobDataVersion: 3,
    taskDataVersion: 2,
    dismissedDay: 0,
    currentJobId: null,
    performance: 0,
    workSessionsToday: 0,
    trainingSessionsToday: 0,
    dailyGoalClaimedDay: 0,
    careerLevel: 1,
    currentCityId: 1,
    lastLivingCostDay: 1,
    companyLevel: 0,
    companyFunds: 0,
    employeeCount: 0,
    projectProgress: 0,
    totalEarned: 0,
    totalWorkSessions: 0,
    totalTrainingSessions: 0,
    unlockedAchievementsMask: 0,
    activeProjectId: 1,
    completedProjects: 0,
    isOnboarded: false,
  );

  final int schemaVersion;
  final int money;
  final int energy;
  final int knowledge;
  final int experience;
  final int day;
  final int hour;
  final int earningSessionsToday;
  final int maxEnergy;
  final int energyRecoveryRemainder;
  final ActiveActivity? activeActivity;
  final SkillProfile skills;
  final Employment? employment;
  final int? applicationBlockedJobId;
  final int applicationBlockedUntilDay;
  final String? lastJobEvent;
  final int jobDataVersion;
  final int taskDataVersion;
  final int dismissedDay;
  final int? currentJobId;
  final int performance;
  final int workSessionsToday;
  final int trainingSessionsToday;
  final int dailyGoalClaimedDay;
  final int careerLevel;
  final int currentCityId;
  final int lastLivingCostDay;
  final int companyLevel;
  final int companyFunds;
  final int employeeCount;
  final int projectProgress;
  final int totalEarned;
  final int totalWorkSessions;
  final int totalTrainingSessions;
  final int unlockedAchievementsMask;
  final int activeProjectId;
  final int completedProjects;
  final bool isOnboarded;

  PlayerState copyWith({
    int? schemaVersion,
    int? money,
    int? energy,
    int? knowledge,
    int? experience,
    int? day,
    int? hour,
    int? earningSessionsToday,
    int? maxEnergy,
    int? energyRecoveryRemainder,
    Object? activeActivity = _unset,
    SkillProfile? skills,
    Object? employment = _unset,
    Object? applicationBlockedJobId = _unset,
    int? applicationBlockedUntilDay,
    Object? lastJobEvent = _unset,
    int? jobDataVersion,
    int? taskDataVersion,
    int? dismissedDay,
    Object? currentJobId = _unset,
    int? performance,
    int? workSessionsToday,
    int? trainingSessionsToday,
    int? dailyGoalClaimedDay,
    int? careerLevel,
    int? currentCityId,
    int? lastLivingCostDay,
    int? companyLevel,
    int? companyFunds,
    int? employeeCount,
    int? projectProgress,
    int? totalEarned,
    int? totalWorkSessions,
    int? totalTrainingSessions,
    int? unlockedAchievementsMask,
    int? activeProjectId,
    int? completedProjects,
    bool? isOnboarded,
  }) {
    return PlayerState(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      money: money ?? this.money,
      energy: energy ?? this.energy,
      knowledge: knowledge ?? this.knowledge,
      experience: experience ?? this.experience,
      day: day ?? this.day,
      hour: hour ?? this.hour,
      earningSessionsToday: earningSessionsToday ?? this.earningSessionsToday,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      energyRecoveryRemainder: energyRecoveryRemainder ?? this.energyRecoveryRemainder,
      activeActivity: identical(activeActivity, _unset) ? this.activeActivity : activeActivity as ActiveActivity?,
      skills: skills ?? this.skills,
      employment: identical(employment, _unset) ? this.employment : employment as Employment?,
      applicationBlockedJobId: identical(applicationBlockedJobId, _unset) ? this.applicationBlockedJobId : applicationBlockedJobId as int?,
      applicationBlockedUntilDay: applicationBlockedUntilDay ?? this.applicationBlockedUntilDay,
      lastJobEvent: identical(lastJobEvent, _unset) ? this.lastJobEvent : lastJobEvent as String?,
      jobDataVersion: jobDataVersion ?? this.jobDataVersion,
      taskDataVersion: taskDataVersion ?? this.taskDataVersion,
      dismissedDay: dismissedDay ?? this.dismissedDay,
      currentJobId: identical(currentJobId, _unset) ? this.currentJobId : currentJobId as int?,
      performance: performance ?? this.performance,
      workSessionsToday: workSessionsToday ?? this.workSessionsToday,
      trainingSessionsToday: trainingSessionsToday ?? this.trainingSessionsToday,
      dailyGoalClaimedDay: dailyGoalClaimedDay ?? this.dailyGoalClaimedDay,
      careerLevel: careerLevel ?? this.careerLevel,
      currentCityId: currentCityId ?? this.currentCityId,
      lastLivingCostDay: lastLivingCostDay ?? this.lastLivingCostDay,
      companyLevel: companyLevel ?? this.companyLevel,
      companyFunds: companyFunds ?? this.companyFunds,
      employeeCount: employeeCount ?? this.employeeCount,
      projectProgress: projectProgress ?? this.projectProgress,
      totalEarned: totalEarned ?? this.totalEarned,
      totalWorkSessions: totalWorkSessions ?? this.totalWorkSessions,
      totalTrainingSessions: totalTrainingSessions ?? this.totalTrainingSessions,
      unlockedAchievementsMask: unlockedAchievementsMask ?? this.unlockedAchievementsMask,
      activeProjectId: activeProjectId ?? this.activeProjectId,
      completedProjects: completedProjects ?? this.completedProjects,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }

  PlayerState advanceGameHour() {
    final absoluteHour = (day - 1) * 24 + hour + 1;
    final nextDay = absoluteHour ~/ 24 + 1;
    final nextHour = absoluteHour % 24;
    return copyWith(
      day: nextDay,
      hour: nextHour,
      earningSessionsToday: nextDay == day ? earningSessionsToday : 0,
      workSessionsToday: nextDay == day ? workSessionsToday : 0,
      trainingSessionsToday: nextDay == day ? trainingSessionsToday : 0,
    );
  }
}
