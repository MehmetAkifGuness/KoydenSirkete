import '../../../../core/database/player_state_store.dart';
import '../../domain/entities/player_state.dart';
import '../../domain/repositories/player_state_repository.dart';
import '../mappers/player_state_mapper.dart';
import '../models/player_state_model.dart';

class LocalPlayerStateRepository implements PlayerStateRepository {
  LocalPlayerStateRepository({
    required PlayerStateStore database,
    required PlayerStateMapper mapper,
  })  : _database = database,
        _mapper = mapper;

  final PlayerStateStore _database;
  final PlayerStateMapper _mapper;

  @override
  Future<PlayerState?> load() async {
    final record = await _database.readPlayerState();
    if (record == null) {
      return null;
    }
    return _mapper.toEntity(PlayerStateModel.fromRecord(record));
  }

  @override
  Future<void> save(PlayerState state) async {
    final model = _mapper.toModel(state);
    await _database.savePlayerState(
      PlayerStateRecord(
        id: 1,
        schemaVersion: model.schemaVersion,
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
      ),
    );
  }
}
