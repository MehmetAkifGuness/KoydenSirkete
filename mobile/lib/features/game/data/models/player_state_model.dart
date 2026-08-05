import '../../domain/entities/player_state.dart';
import '../../../../core/database/player_state_store.dart';

class PlayerStateModel {
  const PlayerStateModel({
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

  factory PlayerStateModel.fromRecord(PlayerStateRecord record) {
    return PlayerStateModel(
      schemaVersion: record.schemaVersion,
      money: record.money,
      energy: record.energy,
      knowledge: record.knowledge,
      experience: record.experience,
      day: record.day,
      hour: record.hour,
      earningSessionsToday: record.earningSessionsToday,
      currentJobId: record.currentJobId,
      performance: record.performance,
      workSessionsToday: record.workSessionsToday,
      careerLevel: record.careerLevel,
      currentCityId: record.currentCityId,
      lastLivingCostDay: record.lastLivingCostDay,
      companyLevel: record.companyLevel,
      companyFunds: record.companyFunds,
      employeeCount: record.employeeCount,
      projectProgress: record.projectProgress,
      isOnboarded: record.isOnboarded,
    );
  }

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

  factory PlayerStateModel.fromEntity(PlayerState entity) {
    return PlayerStateModel(
      schemaVersion: entity.schemaVersion,
      money: entity.money,
      energy: entity.energy,
      knowledge: entity.knowledge,
      experience: entity.experience,
      day: entity.day,
      hour: entity.hour,
      earningSessionsToday: entity.earningSessionsToday,
      currentJobId: entity.currentJobId,
      performance: entity.performance,
      workSessionsToday: entity.workSessionsToday,
      careerLevel: entity.careerLevel,
      currentCityId: entity.currentCityId,
      lastLivingCostDay: entity.lastLivingCostDay,
      companyLevel: entity.companyLevel,
      companyFunds: entity.companyFunds,
      employeeCount: entity.employeeCount,
      projectProgress: entity.projectProgress,
      isOnboarded: entity.isOnboarded,
    );
  }

}
