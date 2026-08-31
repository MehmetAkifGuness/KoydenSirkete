import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'player_state_store.dart';

const _databaseName = 'career_to_company.db';
const _tableName = 'player_state';
const _currentDatabaseVersion = 42;

class AppDatabase extends SqlitePlayerStateStore {
  AppDatabase({String? databasePath, DatabaseFactory? factory})
    : _databasePath = databasePath,
      _factory = factory;

  final String? _databasePath;
  final DatabaseFactory? _factory;
  Database? _database;

  @override
  Future<Database> get database => _open();

  @override
  Future<void> close() async {
    final database = _database;
    _database = null;
    await database?.close();
  }
}

extension _AppDatabaseOpening on AppDatabase {
  Future<Database> _open() async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }
    final selectedFactory = _factory ?? databaseFactory;
    final databasePath =
        _databasePath ??
        join(await selectedFactory.getDatabasesPath(), _databaseName);
    return _database = await selectedFactory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: _currentDatabaseVersion,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON');
          await database.execute('PRAGMA synchronous = FULL');
        },
        onCreate: (database, _) async {
          await database.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY NOT NULL,
            schema_version INTEGER NOT NULL,
            money INTEGER NOT NULL,
            energy INTEGER NOT NULL,
            max_energy INTEGER NOT NULL DEFAULT 100,
            energy_recovery_at INTEGER,
            negative_money_hours INTEGER NOT NULL DEFAULT 0,
            wheel_major_rewards_today INTEGER NOT NULL DEFAULT 0,
            wheel_duration_buff_percent INTEGER NOT NULL DEFAULT 0,
            wheel_duration_buff_tasks INTEGER NOT NULL DEFAULT 0,
            wheel_energy_buff_percent INTEGER NOT NULL DEFAULT 0,
            wheel_energy_buff_tasks INTEGER NOT NULL DEFAULT 0,
            wheel_reward_buff_percent INTEGER NOT NULL DEFAULT 0,
            wheel_reward_buff_tasks INTEGER NOT NULL DEFAULT 0,
            random_seed INTEGER NOT NULL DEFAULT 1592594996,
            active_activity_json TEXT,
            active_activities_json TEXT,
            skills_json TEXT,
            employment_json TEXT,
            employees_json TEXT,
            branches_json TEXT,
            owned_home_ids_json TEXT,
            rented_home_ids_json TEXT,
            finance_ledger_json TEXT,
            personal_finance_json TEXT,
            company_competition_json TEXT,
            company_expansion_json TEXT,
            company_stage_index INTEGER NOT NULL DEFAULT 0,
            first_company_day INTEGER NOT NULL DEFAULT 0,
            late_game_reached_day INTEGER NOT NULL DEFAULT 0,
            career_completed_day INTEGER NOT NULL DEFAULT 0,
            career_final_seen INTEGER NOT NULL DEFAULT 0,
            pending_personal_event_id INTEGER,
            last_personal_event_day INTEGER NOT NULL DEFAULT 0,
            owned_car_id INTEGER,
            application_blocked_job_id INTEGER,
            application_blocked_until_day INTEGER NOT NULL DEFAULT 0,
            last_job_event TEXT,
            job_data_version INTEGER NOT NULL DEFAULT 3,
            task_data_version INTEGER NOT NULL DEFAULT 2,
            dismissed_day INTEGER NOT NULL DEFAULT 0,
            knowledge INTEGER NOT NULL,
            experience INTEGER NOT NULL,
            day INTEGER NOT NULL,
            hour INTEGER NOT NULL,
            earning_sessions_today INTEGER NOT NULL,
            current_job_id INTEGER,
            performance INTEGER NOT NULL DEFAULT 0,
            work_sessions_today INTEGER NOT NULL DEFAULT 0,
            training_sessions_today INTEGER NOT NULL DEFAULT 0,
            daily_goal_claimed_day INTEGER NOT NULL DEFAULT 0,
            career_level INTEGER NOT NULL DEFAULT 1,
            current_city_id INTEGER NOT NULL DEFAULT 1,
            last_living_cost_day INTEGER NOT NULL DEFAULT 1,
            company_level INTEGER NOT NULL DEFAULT 0,
            company_funds INTEGER NOT NULL DEFAULT 0,
            employee_count INTEGER NOT NULL DEFAULT 0,
            project_progress INTEGER NOT NULL DEFAULT 0,
            project_elapsed_days INTEGER NOT NULL DEFAULT 0,
            last_project_outcome_json TEXT,
            company_project_teams_json TEXT,
            company_budget_json TEXT,
            total_earned INTEGER NOT NULL DEFAULT 0,
            total_work_sessions INTEGER NOT NULL DEFAULT 0,
            total_training_sessions INTEGER NOT NULL DEFAULT 0,
            unlocked_achievements_mask INTEGER NOT NULL DEFAULT 0,
            active_project_id INTEGER NOT NULL DEFAULT 1,
            completed_projects INTEGER NOT NULL DEFAULT 0,
            is_onboarded INTEGER NOT NULL DEFAULT 0,
            tutorial_completed INTEGER NOT NULL DEFAULT 0,
            tutorial_step INTEGER NOT NULL DEFAULT 0,
            economy_difficulty TEXT NOT NULL DEFAULT 'normal',
            sound_effects_enabled INTEGER NOT NULL DEFAULT 1,
            haptics_enabled INTEGER NOT NULL DEFAULT 1
          )
        ''');
        },
        onUpgrade: (database, oldVersion, _) async {
          if (oldVersion < 2) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN current_job_id INTEGER',
            );
          }
          if (oldVersion < 3) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN performance INTEGER NOT NULL DEFAULT 0',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN work_sessions_today INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (oldVersion < 4) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN career_level INTEGER NOT NULL DEFAULT 1',
            );
          }
          if (oldVersion < 5) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN current_city_id INTEGER NOT NULL DEFAULT 1',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN last_living_cost_day INTEGER NOT NULL DEFAULT 1',
            );
          }
          if (oldVersion < 6) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN company_level INTEGER NOT NULL DEFAULT 0',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN company_funds INTEGER NOT NULL DEFAULT 0',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN employee_count INTEGER NOT NULL DEFAULT 0',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN project_progress INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (oldVersion < 7) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN is_onboarded INTEGER NOT NULL DEFAULT 1',
            );
          }
          if (oldVersion < 8) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN training_sessions_today INTEGER NOT NULL DEFAULT 0',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN daily_goal_claimed_day INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (oldVersion < 9) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN total_earned INTEGER NOT NULL DEFAULT 0',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN total_work_sessions INTEGER NOT NULL DEFAULT 0',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN total_training_sessions INTEGER NOT NULL DEFAULT 0',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN unlocked_achievements_mask INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (oldVersion < 10) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN active_project_id INTEGER NOT NULL DEFAULT 1',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN completed_projects INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (oldVersion < 11) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN max_energy INTEGER NOT NULL DEFAULT 100',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN active_activity_json TEXT',
            );
          }
          if (oldVersion < 12) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN skills_json TEXT',
            );
          }
          if (oldVersion < 13) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN employment_json TEXT',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN application_blocked_job_id INTEGER',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN application_blocked_until_day INTEGER NOT NULL DEFAULT 0',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN last_job_event TEXT',
            );
          }
          if (oldVersion < 14) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN job_data_version INTEGER NOT NULL DEFAULT 3',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN task_data_version INTEGER NOT NULL DEFAULT 2',
            );
          }
          if (oldVersion < 15) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN dismissed_day INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (oldVersion < 16) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN negative_money_hours INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (oldVersion < 17) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN wheel_major_rewards_today INTEGER NOT NULL DEFAULT 0',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN wheel_duration_buff_percent INTEGER NOT NULL DEFAULT 0',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN wheel_duration_buff_tasks INTEGER NOT NULL DEFAULT 0',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN wheel_energy_buff_percent INTEGER NOT NULL DEFAULT 0',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN wheel_energy_buff_tasks INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (oldVersion < 18) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN energy_recovery_at INTEGER',
            );
          }
          if (oldVersion < 19) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN active_activities_json TEXT',
            );
          }
          if (oldVersion < 20) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN employees_json TEXT',
            );
          }
          if (oldVersion < 21) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN wheel_reward_buff_percent INTEGER NOT NULL DEFAULT 0',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN wheel_reward_buff_tasks INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (oldVersion < 23) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN branches_json TEXT',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN owned_home_ids_json TEXT',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN owned_car_id INTEGER',
            );
          }
          if (oldVersion < 24) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN rented_home_ids_json TEXT',
            );
          }
          if (oldVersion < 25) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN finance_ledger_json TEXT',
            );
          }
          if (oldVersion < 26) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN company_competition_json TEXT',
            );
          }
          if (oldVersion < 27) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN company_stage_index INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (oldVersion < 28) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN company_expansion_json TEXT',
            );
          }
          if (oldVersion < 29) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN project_elapsed_days INTEGER NOT NULL DEFAULT 0',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN last_project_outcome_json TEXT',
            );
          }
          if (oldVersion < 30) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN company_project_teams_json TEXT',
            );
          }
          if (oldVersion < 31) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN company_budget_json TEXT',
            );
          }
          if (oldVersion < 32) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN pending_personal_event_id INTEGER',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN last_personal_event_day INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (oldVersion < 33) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN personal_finance_json TEXT',
            );
          }
          if (oldVersion < 34) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN random_seed INTEGER NOT NULL DEFAULT 1592594996',
            );
          }
          if (oldVersion < 35) {
            await database.execute(
              "ALTER TABLE $_tableName ADD COLUMN economy_difficulty TEXT NOT NULL DEFAULT 'normal'",
            );
          }
          if (oldVersion < 36) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN first_company_day INTEGER NOT NULL DEFAULT 0',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN late_game_reached_day INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (oldVersion < 37) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN sound_effects_enabled INTEGER NOT NULL DEFAULT 1',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN haptics_enabled INTEGER NOT NULL DEFAULT 1',
            );
          }
          if (oldVersion < 38) {
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN tutorial_completed INTEGER NOT NULL DEFAULT 1',
            );
            await database.execute(
              'ALTER TABLE $_tableName ADD COLUMN tutorial_step INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (oldVersion < 41) {
            await _restoreSinglePlayerState(database);
          }
          if (oldVersion < 42) {
            await _addColumnIfMissing(
              database,
              'career_completed_day',
              'INTEGER NOT NULL DEFAULT 0',
            );
            await _addColumnIfMissing(
              database,
              'career_final_seen',
              'INTEGER NOT NULL DEFAULT 0',
            );
          }
        },
      ),
    );
  }
}

Future<void> _addColumnIfMissing(
  Database database,
  String name,
  String definition,
) async {
  final columns = await database.rawQuery('PRAGMA table_info($_tableName)');
  if (columns.any((column) => column['name'] == name)) return;
  await database.execute(
    'ALTER TABLE $_tableName ADD COLUMN $name $definition',
  );
}

Future<void> _restoreSinglePlayerState(Database database) async {
  final metadataTable = await database.rawQuery(
    "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'save_metadata'",
  );
  if (metadataTable.isNotEmpty) {
    final metadata = await database.query(
      'save_metadata',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['active_slot'],
      limit: 1,
    );
    final selectedId = metadata.isEmpty
        ? 1
        : int.tryParse(metadata.first['value'] as String? ?? '') ?? 1;
    if (selectedId != 1) {
      final selected = await database.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [selectedId],
        limit: 1,
      );
      if (selected.isNotEmpty) {
        await database.insert(
          _tableName,
          Map<String, Object?>.from(selected.first)..['id'] = 1,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }
  await database.delete(_tableName, where: 'id <> 1');
  await database.execute('DROP TABLE IF EXISTS save_metadata');
}

abstract class SqlitePlayerStateStore implements PlayerStateStore {
  Future<Database> get database;

  @override
  Future<PlayerStateRecord?> readPlayerState() async {
    final rows = await (await database).query(
      _tableName,
      where: 'id = 1',
      limit: 1,
    );
    return rows.isEmpty ? null : _recordFromRow(rows.first);
  }

  PlayerStateRecord _recordFromRow(Map<String, Object?> row) {
    return PlayerStateRecord(
      id: row['id']! as int,
      schemaVersion: row['schema_version']! as int,
      money: row['money']! as int,
      energy: row['energy']! as int,
      maxEnergy: row['max_energy'] as int? ?? 100,
      energyRecoveryAt: _dateTimeFromMillis(row['energy_recovery_at'] as int?),
      negativeMoneyHours: row['negative_money_hours'] as int? ?? 0,
      wheelMajorRewardsToday: row['wheel_major_rewards_today'] as int? ?? 0,
      wheelDurationBuffPercent: row['wheel_duration_buff_percent'] as int? ?? 0,
      wheelDurationBuffTasks: row['wheel_duration_buff_tasks'] as int? ?? 0,
      wheelEnergyBuffPercent: row['wheel_energy_buff_percent'] as int? ?? 0,
      wheelEnergyBuffTasks: row['wheel_energy_buff_tasks'] as int? ?? 0,
      wheelRewardBuffPercent: row['wheel_reward_buff_percent'] as int? ?? 0,
      wheelRewardBuffTasks: row['wheel_reward_buff_tasks'] as int? ?? 0,
      randomSeed: row['random_seed'] as int? ?? 1592594996,
      activeActivityJson: row['active_activity_json'] as String?,
      activeActivitiesJson: row['active_activities_json'] as String?,
      skillsJson: row['skills_json'] as String?,
      employmentJson: row['employment_json'] as String?,
      employeesJson: row['employees_json'] as String?,
      branchesJson: row['branches_json'] as String?,
      ownedHomeIdsJson: row['owned_home_ids_json'] as String?,
      rentedHomeIdsJson: row['rented_home_ids_json'] as String?,
      financeLedgerJson: row['finance_ledger_json'] as String?,
      personalFinanceJson: row['personal_finance_json'] as String?,
      companyCompetitionJson: row['company_competition_json'] as String?,
      companyExpansionJson: row['company_expansion_json'] as String?,
      companyStageIndex: row['company_stage_index'] as int? ?? 0,
      firstCompanyDay: row['first_company_day'] as int? ?? 0,
      lateGameReachedDay: row['late_game_reached_day'] as int? ?? 0,
      careerCompletedDay: row['career_completed_day'] as int? ?? 0,
      careerFinalSeen: (row['career_final_seen'] as int? ?? 0) == 1,
      pendingPersonalEventId: row['pending_personal_event_id'] as int?,
      lastPersonalEventDay: row['last_personal_event_day'] as int? ?? 0,
      ownedCarId: row['owned_car_id'] as int?,
      applicationBlockedJobId: row['application_blocked_job_id'] as int?,
      applicationBlockedUntilDay:
          row['application_blocked_until_day'] as int? ?? 0,
      lastJobEvent: row['last_job_event'] as String?,
      jobDataVersion: row['job_data_version'] as int? ?? 3,
      taskDataVersion: row['task_data_version'] as int? ?? 2,
      dismissedDay: row['dismissed_day'] as int? ?? 0,
      knowledge: row['knowledge']! as int,
      experience: row['experience']! as int,
      day: row['day']! as int,
      hour: row['hour']! as int,
      earningSessionsToday: row['earning_sessions_today']! as int,
      currentJobId: row['current_job_id'] as int?,
      performance: row['performance'] as int? ?? 0,
      workSessionsToday: row['work_sessions_today'] as int? ?? 0,
      trainingSessionsToday: row['training_sessions_today'] as int? ?? 0,
      dailyGoalClaimedDay: row['daily_goal_claimed_day'] as int? ?? 0,
      careerLevel: row['career_level'] as int? ?? 1,
      currentCityId: row['current_city_id'] as int? ?? 1,
      lastLivingCostDay: row['last_living_cost_day'] as int? ?? 1,
      companyLevel: row['company_level'] as int? ?? 0,
      companyFunds: row['company_funds'] as int? ?? 0,
      employeeCount: row['employee_count'] as int? ?? 0,
      projectProgress: row['project_progress'] as int? ?? 0,
      projectElapsedDays: row['project_elapsed_days'] as int? ?? 0,
      lastProjectOutcomeJson: row['last_project_outcome_json'] as String?,
      companyProjectTeamsJson: row['company_project_teams_json'] as String?,
      companyBudgetJson: row['company_budget_json'] as String?,
      totalEarned: row['total_earned'] as int? ?? 0,
      totalWorkSessions: row['total_work_sessions'] as int? ?? 0,
      totalTrainingSessions: row['total_training_sessions'] as int? ?? 0,
      unlockedAchievementsMask: row['unlocked_achievements_mask'] as int? ?? 0,
      activeProjectId: row['active_project_id'] as int? ?? 1,
      completedProjects: row['completed_projects'] as int? ?? 0,
      isOnboarded: (row['is_onboarded'] as int? ?? 0) == 1,
      tutorialCompleted: (row['tutorial_completed'] as int? ?? 0) == 1,
      tutorialStep: row['tutorial_step'] as int? ?? 0,
      economyDifficulty: row['economy_difficulty'] as String? ?? 'normal',
      soundEffectsEnabled: (row['sound_effects_enabled'] as int? ?? 1) == 1,
      hapticsEnabled: (row['haptics_enabled'] as int? ?? 1) == 1,
    );
  }

  @override
  Future<void> savePlayerState(PlayerStateRecord record) async {
    await (await database).insert(
      _tableName,
      _rowFromRecord(record)..['id'] = 1,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Map<String, Object?> _rowFromRecord(PlayerStateRecord record) => {
    'id': record.id,
    'schema_version': record.schemaVersion,
    'money': record.money,
    'energy': record.energy,
    'max_energy': record.maxEnergy,
    'energy_recovery_at': record.energyRecoveryAt?.millisecondsSinceEpoch,
    'negative_money_hours': record.negativeMoneyHours,
    'wheel_major_rewards_today': record.wheelMajorRewardsToday,
    'wheel_duration_buff_percent': record.wheelDurationBuffPercent,
    'wheel_duration_buff_tasks': record.wheelDurationBuffTasks,
    'wheel_energy_buff_percent': record.wheelEnergyBuffPercent,
    'wheel_energy_buff_tasks': record.wheelEnergyBuffTasks,
    'wheel_reward_buff_percent': record.wheelRewardBuffPercent,
    'wheel_reward_buff_tasks': record.wheelRewardBuffTasks,
    'random_seed': record.randomSeed,
    'active_activity_json': record.activeActivityJson,
    'active_activities_json': record.activeActivitiesJson,
    'skills_json': record.skillsJson,
    'employment_json': record.employmentJson,
    'employees_json': record.employeesJson,
    'branches_json': record.branchesJson,
    'owned_home_ids_json': record.ownedHomeIdsJson,
    'rented_home_ids_json': record.rentedHomeIdsJson,
    'finance_ledger_json': record.financeLedgerJson,
    'personal_finance_json': record.personalFinanceJson,
    'company_competition_json': record.companyCompetitionJson,
    'company_expansion_json': record.companyExpansionJson,
    'company_stage_index': record.companyStageIndex,
    'first_company_day': record.firstCompanyDay,
    'late_game_reached_day': record.lateGameReachedDay,
    'career_completed_day': record.careerCompletedDay,
    'career_final_seen': record.careerFinalSeen ? 1 : 0,
    'pending_personal_event_id': record.pendingPersonalEventId,
    'last_personal_event_day': record.lastPersonalEventDay,
    'owned_car_id': record.ownedCarId,
    'application_blocked_job_id': record.applicationBlockedJobId,
    'application_blocked_until_day': record.applicationBlockedUntilDay,
    'last_job_event': record.lastJobEvent,
    'job_data_version': record.jobDataVersion,
    'task_data_version': record.taskDataVersion,
    'dismissed_day': record.dismissedDay,
    'knowledge': record.knowledge,
    'experience': record.experience,
    'day': record.day,
    'hour': record.hour,
    'earning_sessions_today': record.earningSessionsToday,
    'current_job_id': record.currentJobId,
    'performance': record.performance,
    'work_sessions_today': record.workSessionsToday,
    'training_sessions_today': record.trainingSessionsToday,
    'daily_goal_claimed_day': record.dailyGoalClaimedDay,
    'career_level': record.careerLevel,
    'current_city_id': record.currentCityId,
    'last_living_cost_day': record.lastLivingCostDay,
    'company_level': record.companyLevel,
    'company_funds': record.companyFunds,
    'employee_count': record.employeeCount,
    'project_progress': record.projectProgress,
    'project_elapsed_days': record.projectElapsedDays,
    'last_project_outcome_json': record.lastProjectOutcomeJson,
    'company_project_teams_json': record.companyProjectTeamsJson,
    'company_budget_json': record.companyBudgetJson,
    'total_earned': record.totalEarned,
    'total_work_sessions': record.totalWorkSessions,
    'total_training_sessions': record.totalTrainingSessions,
    'unlocked_achievements_mask': record.unlockedAchievementsMask,
    'active_project_id': record.activeProjectId,
    'completed_projects': record.completedProjects,
    'is_onboarded': record.isOnboarded ? 1 : 0,
    'tutorial_completed': record.tutorialCompleted ? 1 : 0,
    'tutorial_step': record.tutorialStep,
    'economy_difficulty': record.economyDifficulty,
    'sound_effects_enabled': record.soundEffectsEnabled ? 1 : 0,
    'haptics_enabled': record.hapticsEnabled ? 1 : 0,
  };

  DateTime? _dateTimeFromMillis(int? value) => value == null || value <= 0
      ? null
      : DateTime.fromMillisecondsSinceEpoch(value);
}
