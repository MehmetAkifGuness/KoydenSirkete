import '../../../../core/database/player_state_store.dart';
import '../../domain/entities/player_state.dart';
import '../../domain/repositories/player_state_repository.dart';
import '../mappers/player_state_mapper.dart';
import '../models/player_state_model.dart';
import '../mappers/active_activity_codec.dart';
import '../mappers/skill_profile_codec.dart';
import '../mappers/employment_codec.dart';
import '../mappers/company_employee_codec.dart';
import '../mappers/company_branch_codec.dart';
import '../mappers/owned_asset_ids_codec.dart';
import '../mappers/finance_ledger_codec.dart';
import '../mappers/company_competition_codec.dart';
import '../mappers/company_expansion_codec.dart';
import '../mappers/company_project_outcome_codec.dart';
import '../mappers/company_project_team_codec.dart';
import '../mappers/company_budget_codec.dart';
import '../mappers/personal_finance_codec.dart';

class LocalPlayerStateRepository implements PlayerStateRepository {
  LocalPlayerStateRepository({
    required PlayerStateStore database,
    required PlayerStateMapper mapper,
  }) : _database = database,
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
        maxEnergy: model.maxEnergy,
        energyRecoveryAt: model.energyRecoveryAt,
        negativeMoneyHours: model.negativeMoneyHours,
        wheelMajorRewardsToday: model.wheelMajorRewardsToday,
        wheelDurationBuffPercent: model.wheelDurationBuffPercent,
        wheelDurationBuffTasks: model.wheelDurationBuffTasks,
        wheelEnergyBuffPercent: model.wheelEnergyBuffPercent,
        wheelEnergyBuffTasks: model.wheelEnergyBuffTasks,
        wheelRewardBuffPercent: model.wheelRewardBuffPercent,
        wheelRewardBuffTasks: model.wheelRewardBuffTasks,
        randomSeed: model.randomSeed,
        activeActivityJson: ActiveActivityCodec().encode(model.activeActivity),
        activeActivitiesJson: ActiveActivityCodec().encodeList(
          model.activeActivities,
        ),
        skillsJson: SkillProfileCodec().encode(model.skills),
        employmentJson: EmploymentCodec().encode(model.employment),
        employeesJson: CompanyEmployeeCodec().encodeList(model.employees),
        branchesJson: CompanyBranchCodec().encodeList(model.branches),
        ownedHomeIdsJson: OwnedAssetIdsCodec().encode(model.ownedHomeIds),
        rentedHomeIdsJson: OwnedAssetIdsCodec().encode(model.rentedHomeIds),
        financeLedgerJson: FinanceLedgerCodec().encode(model.financeLedger),
        personalFinanceJson: const PersonalFinanceCodec().encode(
          model.personalFinance,
        ),
        companyCompetitionJson: CompanyCompetitionCodec().encode(
          model.companyCompetition,
        ),
        companyExpansionJson: CompanyExpansionCodec().encode(
          model.companyExpansion,
        ),
        companyStageIndex: model.companyStageIndex,
        firstCompanyDay: model.firstCompanyDay,
        lateGameReachedDay: model.lateGameReachedDay,
        pendingPersonalEventId: model.pendingPersonalEventId,
        lastPersonalEventDay: model.lastPersonalEventDay,
        ownedCarId: model.ownedCarId,
        applicationBlockedJobId: model.applicationBlockedJobId,
        applicationBlockedUntilDay: model.applicationBlockedUntilDay,
        lastJobEvent: model.lastJobEvent,
        jobDataVersion: model.jobDataVersion,
        taskDataVersion: model.taskDataVersion,
        dismissedDay: model.dismissedDay,
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
        projectElapsedDays: model.projectElapsedDays,
        lastProjectOutcomeJson: CompanyProjectOutcomeCodec().encode(
          model.lastProjectOutcome,
        ),
        companyProjectTeamsJson: const CompanyProjectTeamCodec().encode(
          model.companyProjectTeams,
        ),
        companyBudgetJson: const CompanyBudgetCodec().encode(
          model.companyBudget,
        ),
        totalEarned: model.totalEarned,
        totalWorkSessions: model.totalWorkSessions,
        totalTrainingSessions: model.totalTrainingSessions,
        unlockedAchievementsMask: model.unlockedAchievementsMask,
        activeProjectId: model.activeProjectId,
        completedProjects: model.completedProjects,
        isOnboarded: model.isOnboarded,
        tutorialCompleted: model.tutorialCompleted,
        tutorialStep: model.tutorialStep,
        economyDifficulty: model.economyDifficulty.name,
        soundEffectsEnabled: model.soundEffectsEnabled,
        hapticsEnabled: model.hapticsEnabled,
      ),
    );
  }
}
