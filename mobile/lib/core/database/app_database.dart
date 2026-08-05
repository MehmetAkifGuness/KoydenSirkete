import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'player_state_store.dart';

class AppDatabase implements PlayerStateStore {
  static const _databaseName = 'career_to_company.db';
  static const _tableName = 'player_state';

  Database? _database;

  Future<Database> _open() async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }
    final databasePath = join(await getDatabasesPath(), _databaseName);
    return _database = await openDatabase(
      databasePath,
      version: 7,
      onCreate: (database, _) async {
        await database.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY NOT NULL,
            schema_version INTEGER NOT NULL,
            money INTEGER NOT NULL,
            energy INTEGER NOT NULL,
            knowledge INTEGER NOT NULL,
            experience INTEGER NOT NULL,
            day INTEGER NOT NULL,
            hour INTEGER NOT NULL,
            earning_sessions_today INTEGER NOT NULL,
            current_job_id INTEGER,
            performance INTEGER NOT NULL DEFAULT 0,
            work_sessions_today INTEGER NOT NULL DEFAULT 0,
            career_level INTEGER NOT NULL DEFAULT 1,
            current_city_id INTEGER NOT NULL DEFAULT 1,
            last_living_cost_day INTEGER NOT NULL DEFAULT 1,
            company_level INTEGER NOT NULL DEFAULT 0,
            company_funds INTEGER NOT NULL DEFAULT 0,
            employee_count INTEGER NOT NULL DEFAULT 0,
            project_progress INTEGER NOT NULL DEFAULT 0,
            is_onboarded INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (database, oldVersion, _) async {
        if (oldVersion < 2) {
          await database.execute('ALTER TABLE $_tableName ADD COLUMN current_job_id INTEGER');
        }
        if (oldVersion < 3) {
          await database.execute('ALTER TABLE $_tableName ADD COLUMN performance INTEGER NOT NULL DEFAULT 0');
          await database.execute('ALTER TABLE $_tableName ADD COLUMN work_sessions_today INTEGER NOT NULL DEFAULT 0');
        }
        if (oldVersion < 4) {
          await database.execute('ALTER TABLE $_tableName ADD COLUMN career_level INTEGER NOT NULL DEFAULT 1');
        }
        if (oldVersion < 5) {
          await database.execute('ALTER TABLE $_tableName ADD COLUMN current_city_id INTEGER NOT NULL DEFAULT 1');
          await database.execute('ALTER TABLE $_tableName ADD COLUMN last_living_cost_day INTEGER NOT NULL DEFAULT 1');
        }
        if (oldVersion < 6) {
          await database.execute('ALTER TABLE $_tableName ADD COLUMN company_level INTEGER NOT NULL DEFAULT 0');
          await database.execute('ALTER TABLE $_tableName ADD COLUMN company_funds INTEGER NOT NULL DEFAULT 0');
          await database.execute('ALTER TABLE $_tableName ADD COLUMN employee_count INTEGER NOT NULL DEFAULT 0');
          await database.execute('ALTER TABLE $_tableName ADD COLUMN project_progress INTEGER NOT NULL DEFAULT 0');
        }
        if (oldVersion < 7) {
          await database.execute('ALTER TABLE $_tableName ADD COLUMN is_onboarded INTEGER NOT NULL DEFAULT 1');
        }
      },
    );
  }

  @override
  Future<PlayerStateRecord?> readPlayerState() async {
    final rows = await (await _open()).query(_tableName, limit: 1);
    if (rows.isEmpty) {
      return null;
    }
    final row = rows.first;
    return PlayerStateRecord(
      id: row['id']! as int,
      schemaVersion: row['schema_version']! as int,
      money: row['money']! as int,
      energy: row['energy']! as int,
      knowledge: row['knowledge']! as int,
      experience: row['experience']! as int,
      day: row['day']! as int,
      hour: row['hour']! as int,
      earningSessionsToday: row['earning_sessions_today']! as int,
      currentJobId: row['current_job_id'] as int?,
      performance: row['performance'] as int? ?? 0,
      workSessionsToday: row['work_sessions_today'] as int? ?? 0,
      careerLevel: row['career_level'] as int? ?? 1,
      currentCityId: row['current_city_id'] as int? ?? 1,
      lastLivingCostDay: row['last_living_cost_day'] as int? ?? 1,
      companyLevel: row['company_level'] as int? ?? 0,
      companyFunds: row['company_funds'] as int? ?? 0,
      employeeCount: row['employee_count'] as int? ?? 0,
      projectProgress: row['project_progress'] as int? ?? 0,
      isOnboarded: (row['is_onboarded'] as int? ?? 0) == 1,
    );
  }

  @override
  Future<void> savePlayerState(PlayerStateRecord record) async {
    await (await _open()).insert(
      _tableName,
      {
        'id': record.id,
        'schema_version': record.schemaVersion,
        'money': record.money,
        'energy': record.energy,
        'knowledge': record.knowledge,
        'experience': record.experience,
        'day': record.day,
        'hour': record.hour,
        'earning_sessions_today': record.earningSessionsToday,
        'current_job_id': record.currentJobId,
        'performance': record.performance,
        'work_sessions_today': record.workSessionsToday,
        'career_level': record.careerLevel,
        'current_city_id': record.currentCityId,
        'last_living_cost_day': record.lastLivingCostDay,
        'company_level': record.companyLevel,
        'company_funds': record.companyFunds,
        'employee_count': record.employeeCount,
        'project_progress': record.projectProgress,
        'is_onboarded': record.isOnboarded ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> close() async {
    final database = _database;
    _database = null;
    await database?.close();
  }
}
