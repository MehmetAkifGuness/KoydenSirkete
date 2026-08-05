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
    this.currentJobId,
    this.performance = 0,
    this.workSessionsToday = 0,
    this.careerLevel = 1,
    this.currentCityId = 1,
    this.lastLivingCostDay = 1,
    this.companyLevel = 0,
    this.companyFunds = 0,
    this.employeeCount = 0,
    this.projectProgress = 0,
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
  final int? currentJobId;
  final int performance;
  final int workSessionsToday;
  final int careerLevel;
  final int currentCityId;
  final int lastLivingCostDay;
  final int companyLevel;
  final int companyFunds;
  final int employeeCount;
  final int projectProgress;
  final bool isOnboarded;
}
