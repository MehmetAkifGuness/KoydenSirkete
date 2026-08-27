abstract interface class PlayerStateStore {
  Future<PlayerStateRecord?> readPlayerState();

  Future<void> savePlayerState(PlayerStateRecord record);

  Future<void> close();
}

class PlayerStateRecord {
  const PlayerStateRecord({
    required this.id,
    required this.schemaVersion,
    required this.money,
    required this.energy,
    required this.knowledge,
    required this.experience,
    required this.day,
    required this.hour,
    required this.earningSessionsToday,
    this.maxEnergy = 100,
    this.energyRecoveryAt,
    this.negativeMoneyHours = 0,
    this.wheelMajorRewardsToday = 0,
    this.wheelDurationBuffPercent = 0,
    this.wheelDurationBuffTasks = 0,
    this.wheelEnergyBuffPercent = 0,
    this.wheelEnergyBuffTasks = 0,
    this.wheelRewardBuffPercent = 0,
    this.wheelRewardBuffTasks = 0,
    this.activeActivityJson,
    this.activeActivitiesJson,
    this.skillsJson,
    this.employmentJson,
    this.employeesJson,
    this.branchesJson,
    this.ownedHomeIdsJson,
    this.rentedHomeIdsJson,
    this.financeLedgerJson,
    this.ownedCarId,
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

  final int id;
  final int schemaVersion;
  final int money;
  final int energy;
  final int knowledge;
  final int experience;
  final int day;
  final int hour;
  final int earningSessionsToday;
  final int maxEnergy;
  final DateTime? energyRecoveryAt;
  final int negativeMoneyHours;
  final int wheelMajorRewardsToday;
  final int wheelDurationBuffPercent;
  final int wheelDurationBuffTasks;
  final int wheelEnergyBuffPercent;
  final int wheelEnergyBuffTasks;
  final int wheelRewardBuffPercent;
  final int wheelRewardBuffTasks;
  final String? activeActivityJson;
  final String? activeActivitiesJson;
  final String? skillsJson;
  final String? employmentJson;
  final String? employeesJson;
  final String? branchesJson;
  final String? ownedHomeIdsJson;
  final String? rentedHomeIdsJson;
  final String? financeLedgerJson;
  final int? ownedCarId;
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
}
