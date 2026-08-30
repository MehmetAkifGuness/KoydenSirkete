import '../../domain/entities/player_state.dart';
import '../../domain/entities/active_activity.dart';
import '../../../../core/database/player_state_store.dart';
import '../mappers/active_activity_codec.dart';
import '../mappers/skill_profile_codec.dart';
import '../../../skills/domain/entities/skill_profile.dart';
import '../../../employment/domain/entities/employment.dart';
import '../mappers/employment_codec.dart';
import '../../../company/domain/entities/company_employee.dart';
import '../mappers/company_employee_codec.dart';
import '../mappers/company_branch_codec.dart';
import '../mappers/owned_asset_ids_codec.dart';
import '../mappers/finance_ledger_codec.dart';
import '../mappers/company_competition_codec.dart';
import '../mappers/company_expansion_codec.dart';
import '../mappers/company_project_outcome_codec.dart';
import '../mappers/company_project_team_codec.dart';
import '../mappers/company_budget_codec.dart';
import '../../../company/domain/entities/company_branch.dart';
import '../../../company/domain/entities/company_competition_state.dart';
import '../../../company/domain/entities/company_expansion_state.dart';
import '../../../company/domain/entities/company_project_outcome.dart';
import '../../../company/domain/entities/company_project_team_state.dart';
import '../../../company/domain/entities/company_budget_state.dart';
import '../../../finance/domain/entities/finance_ledger.dart';
import '../../../finance/domain/entities/personal_finance_state.dart';
import '../mappers/personal_finance_codec.dart';
import '../../../economy/domain/entities/economy_difficulty.dart';

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
    this.randomSeed = 1592594996,
    this.activeActivity,
    this.activeActivities = const <ActiveActivity>[],
    this.skills = const SkillProfile(),
    this.employment,
    this.employees = const <CompanyEmployee>[],
    this.branches = const <CompanyBranch>[],
    this.ownedHomeIds = const <int>[],
    this.rentedHomeIds = const <int>[],
    this.financeLedger = const FinanceLedger(),
    this.personalFinance = const PersonalFinanceState(),
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
    this.projectElapsedDays = 0,
    this.lastProjectOutcome,
    this.companyProjectTeams = const CompanyProjectTeamState(),
    this.companyBudget = const CompanyBudgetState(),
    this.totalEarned = 0,
    this.totalWorkSessions = 0,
    this.totalTrainingSessions = 0,
    this.unlockedAchievementsMask = 0,
    this.activeProjectId = 1,
    this.completedProjects = 0,
    this.companyCompetition = const CompanyCompetitionState(),
    this.companyExpansion = const CompanyExpansionState(),
    this.companyStageIndex = 0,
    this.pendingPersonalEventId,
    this.lastPersonalEventDay = 0,
    this.isOnboarded = false,
    this.economyDifficulty = EconomyDifficulty.normal,
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
      maxEnergy: record.maxEnergy,
      energyRecoveryAt: record.energyRecoveryAt,
      negativeMoneyHours: record.negativeMoneyHours,
      wheelMajorRewardsToday: record.wheelMajorRewardsToday,
      wheelDurationBuffPercent: record.wheelDurationBuffPercent,
      wheelDurationBuffTasks: record.wheelDurationBuffTasks,
      wheelEnergyBuffPercent: record.wheelEnergyBuffPercent,
      wheelEnergyBuffTasks: record.wheelEnergyBuffTasks,
      wheelRewardBuffPercent: record.wheelRewardBuffPercent,
      wheelRewardBuffTasks: record.wheelRewardBuffTasks,
      randomSeed: record.randomSeed,
      activeActivity: ActiveActivityCodec().decode(record.activeActivityJson),
      activeActivities: ActiveActivityCodec().decodeList(
        record.activeActivitiesJson,
        legacyValue: record.activeActivityJson,
      ),
      skills: SkillProfileCodec().decode(
        record.skillsJson,
        scale: record.schemaVersion < 18 ? 10 : 1,
      ),
      employment: EmploymentCodec().decode(record.employmentJson),
      employees: CompanyEmployeeCodec().decodeList(
        record.employeesJson,
        legacyCount: record.employeeCount,
      ),
      branches: CompanyBranchCodec().decodeList(record.branchesJson),
      ownedHomeIds: OwnedAssetIdsCodec().decode(record.ownedHomeIdsJson),
      rentedHomeIds: OwnedAssetIdsCodec().decode(record.rentedHomeIdsJson),
      financeLedger: FinanceLedgerCodec().decode(record.financeLedgerJson),
      personalFinance: const PersonalFinanceCodec().decode(
        record.personalFinanceJson,
      ),
      ownedCarId: record.ownedCarId,
      applicationBlockedJobId: record.applicationBlockedJobId,
      applicationBlockedUntilDay: record.applicationBlockedUntilDay,
      lastJobEvent: record.lastJobEvent,
      jobDataVersion: record.jobDataVersion,
      taskDataVersion: record.taskDataVersion,
      dismissedDay: record.dismissedDay,
      currentJobId: record.currentJobId,
      performance: record.performance,
      workSessionsToday: record.workSessionsToday,
      trainingSessionsToday: record.trainingSessionsToday,
      dailyGoalClaimedDay: record.dailyGoalClaimedDay,
      careerLevel: record.careerLevel,
      currentCityId: record.currentCityId,
      lastLivingCostDay: record.lastLivingCostDay,
      companyLevel: record.companyLevel,
      companyFunds: record.companyFunds,
      employeeCount: record.employeeCount,
      projectProgress: record.projectProgress,
      projectElapsedDays: record.projectElapsedDays,
      lastProjectOutcome: CompanyProjectOutcomeCodec().decode(
        record.lastProjectOutcomeJson,
      ),
      companyProjectTeams: const CompanyProjectTeamCodec().decode(
        record.companyProjectTeamsJson,
      ),
      companyBudget: const CompanyBudgetCodec().decode(
        record.companyBudgetJson,
      ),
      totalEarned: record.totalEarned,
      totalWorkSessions: record.totalWorkSessions,
      totalTrainingSessions: record.totalTrainingSessions,
      unlockedAchievementsMask: record.unlockedAchievementsMask,
      activeProjectId: record.activeProjectId,
      completedProjects: record.completedProjects,
      companyCompetition: CompanyCompetitionCodec().decode(
        record.companyCompetitionJson,
        day: record.day,
      ),
      companyExpansion: CompanyExpansionCodec().decode(
        record.companyExpansionJson,
      ),
      companyStageIndex: record.companyStageIndex,
      pendingPersonalEventId: record.pendingPersonalEventId,
      lastPersonalEventDay: record.lastPersonalEventDay,
      isOnboarded: record.isOnboarded,
      economyDifficulty: EconomyDifficulty.fromName(record.economyDifficulty),
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
  final int randomSeed;
  final ActiveActivity? activeActivity;
  final List<ActiveActivity> activeActivities;
  final SkillProfile skills;
  final Employment? employment;
  final List<CompanyEmployee> employees;
  final List<CompanyBranch> branches;
  final List<int> ownedHomeIds;
  final List<int> rentedHomeIds;
  final FinanceLedger financeLedger;
  final PersonalFinanceState personalFinance;
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
  final int projectElapsedDays;
  final CompanyProjectOutcome? lastProjectOutcome;
  final CompanyProjectTeamState companyProjectTeams;
  final CompanyBudgetState companyBudget;
  final int totalEarned;
  final int totalWorkSessions;
  final int totalTrainingSessions;
  final int unlockedAchievementsMask;
  final int activeProjectId;
  final int completedProjects;
  final CompanyCompetitionState companyCompetition;
  final CompanyExpansionState companyExpansion;
  final int companyStageIndex;
  final int? pendingPersonalEventId;
  final int lastPersonalEventDay;
  final bool isOnboarded;
  final EconomyDifficulty economyDifficulty;

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
      maxEnergy: entity.maxEnergy,
      energyRecoveryAt: entity.energyRecoveryAt,
      negativeMoneyHours: entity.negativeMoneyHours,
      wheelMajorRewardsToday: entity.wheelMajorRewardsToday,
      wheelDurationBuffPercent: entity.wheelDurationBuffPercent,
      wheelDurationBuffTasks: entity.wheelDurationBuffTasks,
      wheelEnergyBuffPercent: entity.wheelEnergyBuffPercent,
      wheelEnergyBuffTasks: entity.wheelEnergyBuffTasks,
      wheelRewardBuffPercent: entity.wheelRewardBuffPercent,
      wheelRewardBuffTasks: entity.wheelRewardBuffTasks,
      randomSeed: entity.randomSeed,
      activeActivity: entity.activeActivity,
      activeActivities: entity.activities,
      skills: entity.skills,
      employment: entity.employment,
      employees: entity.employees,
      branches: entity.branches,
      ownedHomeIds: entity.ownedHomeIds,
      rentedHomeIds: entity.rentedHomeIds,
      financeLedger: entity.financeLedger,
      personalFinance: entity.personalFinance,
      ownedCarId: entity.ownedCarId,
      applicationBlockedJobId: entity.applicationBlockedJobId,
      applicationBlockedUntilDay: entity.applicationBlockedUntilDay,
      lastJobEvent: entity.lastJobEvent,
      jobDataVersion: entity.jobDataVersion,
      taskDataVersion: entity.taskDataVersion,
      dismissedDay: entity.dismissedDay,
      currentJobId: entity.currentJobId,
      performance: entity.performance,
      workSessionsToday: entity.workSessionsToday,
      trainingSessionsToday: entity.trainingSessionsToday,
      dailyGoalClaimedDay: entity.dailyGoalClaimedDay,
      careerLevel: entity.careerLevel,
      currentCityId: entity.currentCityId,
      lastLivingCostDay: entity.lastLivingCostDay,
      companyLevel: entity.companyLevel,
      companyFunds: entity.companyFunds,
      employeeCount: entity.employeeCount,
      projectProgress: entity.projectProgress,
      projectElapsedDays: entity.projectElapsedDays,
      lastProjectOutcome: entity.lastProjectOutcome,
      companyProjectTeams: entity.companyProjectTeams,
      companyBudget: entity.companyBudget,
      totalEarned: entity.totalEarned,
      totalWorkSessions: entity.totalWorkSessions,
      totalTrainingSessions: entity.totalTrainingSessions,
      unlockedAchievementsMask: entity.unlockedAchievementsMask,
      activeProjectId: entity.activeProjectId,
      completedProjects: entity.completedProjects,
      companyCompetition: entity.companyCompetition,
      companyExpansion: entity.companyExpansion,
      companyStageIndex: entity.companyStageIndex,
      pendingPersonalEventId: entity.pendingPersonalEventId,
      lastPersonalEventDay: entity.lastPersonalEventDay,
      isOnboarded: entity.isOnboarded,
      economyDifficulty: entity.economyDifficulty,
    );
  }
}
