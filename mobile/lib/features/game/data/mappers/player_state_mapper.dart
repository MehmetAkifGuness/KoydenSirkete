import '../../domain/entities/player_state.dart';
import '../models/player_state_model.dart';

class PlayerStateMapper {
  PlayerState toEntity(PlayerStateModel model) {
    return PlayerState(
      schemaVersion: PlayerState.initial.schemaVersion,
      money: model.money,
      energy: model.energy,
      knowledge: model.knowledge,
      experience: model.experience,
      day: model.day,
      hour: model.hour,
      earningSessionsToday: model.earningSessionsToday,
      currentJobId: model.currentJobId,
      performance: model.performance,
      workSessionsToday: model.workSessionsToday,
      trainingSessionsToday: model.trainingSessionsToday,
      dailyGoalClaimedDay: model.dailyGoalClaimedDay,
      careerLevel: model.careerLevel,
      currentCityId: model.currentCityId,
      lastLivingCostDay: model.lastLivingCostDay,
      companyLevel: model.companyLevel,
      companyFunds: model.companyFunds,
      employeeCount: model.employeeCount,
      projectProgress: model.projectProgress,
      totalEarned: model.totalEarned,
      totalWorkSessions: model.totalWorkSessions,
      totalTrainingSessions: model.totalTrainingSessions,
      unlockedAchievementsMask: model.unlockedAchievementsMask,
      activeProjectId: model.activeProjectId,
      completedProjects: model.completedProjects,
      isOnboarded: model.isOnboarded,
    );
  }

  PlayerStateModel toModel(PlayerState entity) => PlayerStateModel.fromEntity(entity);
}
