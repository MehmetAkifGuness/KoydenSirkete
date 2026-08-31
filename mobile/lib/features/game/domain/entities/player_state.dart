import 'active_activity.dart';
import '../../../skills/domain/entities/skill_profile.dart';
import '../../../employment/domain/entities/employment.dart';
import '../../../company/domain/entities/company_employee.dart';
import '../../../company/domain/entities/company_branch.dart';
import '../../../company/domain/entities/company_competition_state.dart';
import '../../../company/domain/entities/company_expansion_state.dart';
import '../../../company/domain/entities/company_project_outcome.dart';
import '../../../company/domain/entities/company_project_team_state.dart';
import '../../../company/domain/entities/company_budget_state.dart';
import '../../../finance/domain/entities/finance_ledger.dart';
import '../../../finance/domain/entities/personal_finance_state.dart';
import '../../../economy/domain/entities/economy_difficulty.dart';

const _unset = Object();

class PlayerState {
  static const bankruptcyDurationHours = 24;
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
    ActiveActivity? activeActivity,
    this.activeActivities = const <ActiveActivity>[],
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
    this.employees = const <CompanyEmployee>[],
    this.branches = const <CompanyBranch>[],
    this.ownedHomeIds = const <int>[],
    this.rentedHomeIds = const <int>[],
    this.financeLedger = const FinanceLedger(),
    this.personalFinance = const PersonalFinanceState(),
    this.ownedCarId,
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
    this.firstCompanyDay = 0,
    this.lateGameReachedDay = 0,
    this.pendingPersonalEventId,
    this.lastPersonalEventDay = 0,
    this.isOnboarded = false,
    this.tutorialCompleted = false,
    this.tutorialStep = 0,
    this.economyDifficulty = EconomyDifficulty.normal,
    this.soundEffectsEnabled = true,
    this.hapticsEnabled = true,
  }) : _legacyActiveActivity = activeActivity;
  static const initial = PlayerState(
    schemaVersion: 41,
    money: 240,
    energy: 100,
    knowledge: 0,
    experience: 0,
    day: 1,
    hour: 8,
    earningSessionsToday: 0,
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
  final ActiveActivity? _legacyActiveActivity;
  final List<ActiveActivity> activeActivities;
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
  final List<CompanyEmployee> employees;
  final List<CompanyBranch> branches;
  final List<int> ownedHomeIds;
  final List<int> rentedHomeIds;
  final FinanceLedger financeLedger;
  final PersonalFinanceState personalFinance;
  final int? ownedCarId;
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
  final int firstCompanyDay;
  final int lateGameReachedDay;
  final int? pendingPersonalEventId;
  final int lastPersonalEventDay;
  final bool isOnboarded;
  final bool tutorialCompleted;
  final int tutorialStep;
  final EconomyDifficulty economyDifficulty;
  final bool soundEffectsEnabled;
  final bool hapticsEnabled;

  bool get isBankrupt =>
      negativeMoneyHours >= PlayerState.bankruptcyDurationHours;
  ActiveActivity? get activeActivity => activeActivities.isNotEmpty
      ? activeActivities.first
      : _legacyActiveActivity;
  List<ActiveActivity> get activities {
    if (activeActivities.isNotEmpty) return List.unmodifiable(activeActivities);
    final legacy = _legacyActiveActivity;
    return legacy == null ? const [] : List.unmodifiable([legacy]);
  }

  int get activityCapacity => careerLevel < 1 ? 1 : careerLevel;
  bool get hasActivityCapacity => activities.length < activityCapacity;
}

extension PlayerStateCopy on PlayerState {
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
    DateTime? energyRecoveryAt,
    int? negativeMoneyHours,
    int? wheelMajorRewardsToday,
    int? wheelDurationBuffPercent,
    int? wheelDurationBuffTasks,
    int? wheelEnergyBuffPercent,
    int? wheelEnergyBuffTasks,
    int? wheelRewardBuffPercent,
    int? wheelRewardBuffTasks,
    int? randomSeed,
    Object? activeActivity = _unset,
    Object? activeActivities = _unset,
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
    Object? employees = _unset,
    Object? branches = _unset,
    Object? ownedHomeIds = _unset,
    Object? rentedHomeIds = _unset,
    FinanceLedger? financeLedger,
    PersonalFinanceState? personalFinance,
    Object? ownedCarId = _unset,
    int? projectProgress,
    int? projectElapsedDays,
    Object? lastProjectOutcome = _unset,
    CompanyProjectTeamState? companyProjectTeams,
    CompanyBudgetState? companyBudget,
    int? totalEarned,
    int? totalWorkSessions,
    int? totalTrainingSessions,
    int? unlockedAchievementsMask,
    int? activeProjectId,
    int? completedProjects,
    CompanyCompetitionState? companyCompetition,
    CompanyExpansionState? companyExpansion,
    int? companyStageIndex,
    int? firstCompanyDay,
    int? lateGameReachedDay,
    Object? pendingPersonalEventId = _unset,
    int? lastPersonalEventDay,
    bool? isOnboarded,
    bool? tutorialCompleted,
    int? tutorialStep,
    EconomyDifficulty? economyDifficulty,
    bool? soundEffectsEnabled,
    bool? hapticsEnabled,
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
      energyRecoveryAt: energyRecoveryAt ?? this.energyRecoveryAt,
      negativeMoneyHours: negativeMoneyHours ?? this.negativeMoneyHours,
      wheelMajorRewardsToday:
          wheelMajorRewardsToday ?? this.wheelMajorRewardsToday,
      wheelDurationBuffPercent:
          wheelDurationBuffPercent ?? this.wheelDurationBuffPercent,
      wheelDurationBuffTasks:
          wheelDurationBuffTasks ?? this.wheelDurationBuffTasks,
      wheelEnergyBuffPercent:
          wheelEnergyBuffPercent ?? this.wheelEnergyBuffPercent,
      wheelEnergyBuffTasks: wheelEnergyBuffTasks ?? this.wheelEnergyBuffTasks,
      wheelRewardBuffPercent:
          wheelRewardBuffPercent ?? this.wheelRewardBuffPercent,
      wheelRewardBuffTasks: wheelRewardBuffTasks ?? this.wheelRewardBuffTasks,
      randomSeed: randomSeed ?? this.randomSeed,
      activeActivity: identical(activeActivities, _unset)
          ? (identical(activeActivity, _unset)
                ? _legacyActiveActivity
                : activeActivity as ActiveActivity?)
          : null,
      activeActivities: identical(activeActivities, _unset)
          ? (identical(activeActivity, _unset)
                ? this.activeActivities
                : const <ActiveActivity>[])
          : List<ActiveActivity>.unmodifiable(
              activeActivities as List<ActiveActivity>,
            ),
      skills: skills ?? this.skills,
      employment: identical(employment, _unset)
          ? this.employment
          : employment as Employment?,
      applicationBlockedJobId: identical(applicationBlockedJobId, _unset)
          ? this.applicationBlockedJobId
          : applicationBlockedJobId as int?,
      applicationBlockedUntilDay:
          applicationBlockedUntilDay ?? this.applicationBlockedUntilDay,
      lastJobEvent: identical(lastJobEvent, _unset)
          ? this.lastJobEvent
          : lastJobEvent as String?,
      jobDataVersion: jobDataVersion ?? this.jobDataVersion,
      taskDataVersion: taskDataVersion ?? this.taskDataVersion,
      dismissedDay: dismissedDay ?? this.dismissedDay,
      currentJobId: identical(currentJobId, _unset)
          ? this.currentJobId
          : currentJobId as int?,
      performance: performance ?? this.performance,
      workSessionsToday: workSessionsToday ?? this.workSessionsToday,
      trainingSessionsToday:
          trainingSessionsToday ?? this.trainingSessionsToday,
      dailyGoalClaimedDay: dailyGoalClaimedDay ?? this.dailyGoalClaimedDay,
      careerLevel: careerLevel ?? this.careerLevel,
      currentCityId: currentCityId ?? this.currentCityId,
      lastLivingCostDay: lastLivingCostDay ?? this.lastLivingCostDay,
      companyLevel: companyLevel ?? this.companyLevel,
      companyFunds: companyFunds ?? this.companyFunds,
      employeeCount: employeeCount ?? this.employeeCount,
      employees: identical(employees, _unset)
          ? this.employees
          : List<CompanyEmployee>.unmodifiable(
              employees as List<CompanyEmployee>,
            ),
      branches: identical(branches, _unset)
          ? this.branches
          : List<CompanyBranch>.unmodifiable(branches as List<CompanyBranch>),
      ownedHomeIds: identical(ownedHomeIds, _unset)
          ? this.ownedHomeIds
          : List<int>.unmodifiable(ownedHomeIds as List<int>),
      rentedHomeIds: identical(rentedHomeIds, _unset)
          ? this.rentedHomeIds
          : List<int>.unmodifiable(rentedHomeIds as List<int>),
      financeLedger: financeLedger ?? this.financeLedger,
      personalFinance: personalFinance ?? this.personalFinance,
      ownedCarId: identical(ownedCarId, _unset)
          ? this.ownedCarId
          : ownedCarId as int?,
      projectProgress: projectProgress ?? this.projectProgress,
      projectElapsedDays: projectElapsedDays ?? this.projectElapsedDays,
      lastProjectOutcome: identical(lastProjectOutcome, _unset)
          ? this.lastProjectOutcome
          : lastProjectOutcome as CompanyProjectOutcome?,
      companyProjectTeams: companyProjectTeams ?? this.companyProjectTeams,
      companyBudget: companyBudget ?? this.companyBudget,
      totalEarned: totalEarned ?? this.totalEarned,
      totalWorkSessions: totalWorkSessions ?? this.totalWorkSessions,
      totalTrainingSessions:
          totalTrainingSessions ?? this.totalTrainingSessions,
      unlockedAchievementsMask:
          unlockedAchievementsMask ?? this.unlockedAchievementsMask,
      activeProjectId: activeProjectId ?? this.activeProjectId,
      completedProjects: completedProjects ?? this.completedProjects,
      companyCompetition: companyCompetition ?? this.companyCompetition,
      companyExpansion: companyExpansion ?? this.companyExpansion,
      companyStageIndex: companyStageIndex ?? this.companyStageIndex,
      firstCompanyDay: firstCompanyDay ?? this.firstCompanyDay,
      lateGameReachedDay: lateGameReachedDay ?? this.lateGameReachedDay,
      pendingPersonalEventId: identical(pendingPersonalEventId, _unset)
          ? this.pendingPersonalEventId
          : pendingPersonalEventId as int?,
      lastPersonalEventDay: lastPersonalEventDay ?? this.lastPersonalEventDay,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      tutorialStep: tutorialStep ?? this.tutorialStep,
      economyDifficulty: economyDifficulty ?? this.economyDifficulty,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}
