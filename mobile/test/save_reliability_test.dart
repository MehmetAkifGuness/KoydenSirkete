import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:kariyerden_sirkete/core/database/app_database.dart';
import 'package:kariyerden_sirkete/features/game/data/mappers/player_state_mapper.dart';
import 'package:kariyerden_sirkete/features/game/data/repositories/local_player_state_repository.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  sqfliteFfiInit();

  late Directory temporaryDirectory;
  late String databasePath;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('mudur_save_');
    databasePath = '${temporaryDirectory.path}${Platform.pathSeparator}save.db';
  });

  tearDown(() async {
    await databaseFactoryFfi.deleteDatabase(databasePath);
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'SQLite v1 kaydı tüm migrasyonlardan geçerek güncel sürümde açılır',
    () async {
      final legacy = await databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (database, _) => database.execute('''
          CREATE TABLE player_state (
            id INTEGER PRIMARY KEY NOT NULL,
            schema_version INTEGER NOT NULL,
            money INTEGER NOT NULL,
            energy INTEGER NOT NULL,
            knowledge INTEGER NOT NULL,
            experience INTEGER NOT NULL,
            day INTEGER NOT NULL,
            hour INTEGER NOT NULL,
            earning_sessions_today INTEGER NOT NULL
          )
        '''),
        ),
      );
      await legacy.insert('player_state', {
        'id': 1,
        'schema_version': 1,
        'money': 725,
        'energy': 60,
        'knowledge': 12,
        'experience': 8,
        'day': 4,
        'hour': 9,
        'earning_sessions_today': 1,
      });
      await legacy.close();

      final store = AppDatabase(
        databasePath: databasePath,
        factory: databaseFactoryFfi,
      );
      final state = await _repository(store).load();

      expect(state?.money, 725);
      expect(state?.day, 4);
      expect(state?.tutorialCompleted, isTrue);
      await _repository(store).save(state!);
      await store.close();

      final migrated = await databaseFactoryFfi.openDatabase(databasePath);
      expect(await migrated.getVersion(), 42);
      final columns = (await migrated.rawQuery(
        'PRAGMA table_info(player_state)',
      )).map((row) => row['name']).toSet();
      expect(
        columns,
        isNot(containsAll(['data_checksum', 'save_revision', 'updated_at'])),
      );
      expect(
        await migrated.rawQuery(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'save_metadata'",
        ),
        isEmpty,
      );
      await migrated.close();
    },
  );

  test('tek SQLite kaydı son yazılan ilerlemeyle yeniden açılır', () async {
    var store = AppDatabase(
      databasePath: databasePath,
      factory: databaseFactoryFfi,
    );
    var repository = _repository(store);
    await repository.save(PlayerState.initial.copyWith(money: 100));
    await repository.save(PlayerState.initial.copyWith(money: 200));
    await store.close();

    store = AppDatabase(
      databasePath: databasePath,
      factory: databaseFactoryFfi,
    );
    repository = _repository(store);
    expect((await repository.load())?.money, 200);
    await store.close();

    final raw = await databaseFactoryFfi.openDatabase(databasePath);
    expect(await raw.query('player_state'), hasLength(1));
    expect((await raw.query('player_state', columns: ['id'])).single['id'], 1);
    await raw.close();
  });

  test(
    'yarım kalan atomik işlem ödülü veya satışı ikinci kez uygulamaz',
    () async {
      var store = AppDatabase(
        databasePath: databasePath,
        factory: databaseFactoryFfi,
      );
      var repository = _repository(store);
      await repository.save(PlayerState.initial.copyWith(money: 400));
      await store.close();

      var raw = await databaseFactoryFfi.openDatabase(databasePath);
      await raw.execute('''
      CREATE TRIGGER fail_active_save
      BEFORE INSERT ON player_state
      WHEN NEW.id = 1
      BEGIN
        SELECT RAISE(ABORT, 'simulated interruption');
      END
    ''');
      await raw.close();

      store = AppDatabase(
        databasePath: databasePath,
        factory: databaseFactoryFfi,
      );
      repository = _repository(store);
      await expectLater(
        repository.save(PlayerState.initial.copyWith(money: 900)),
        throwsA(anything),
      );
      await store.close();

      raw = await databaseFactoryFfi.openDatabase(databasePath);
      await raw.execute('DROP TRIGGER fail_active_save');
      await raw.close();

      store = AppDatabase(
        databasePath: databasePath,
        factory: databaseFactoryFfi,
      );
      repository = _repository(store);
      expect((await repository.load())?.money, 400);
      await repository.save(PlayerState.initial.copyWith(money: 900));
      expect((await repository.load())?.money, 900);
      await store.close();
    },
  );

  test('eski kayıt kalıntıları tek SQLite satırına indirilir', () async {
    var store = AppDatabase(
      databasePath: databasePath,
      factory: databaseFactoryFfi,
    );
    await _repository(
      store,
    ).save(PlayerState.initial.copyWith(money: 321, day: 7));
    await store.close();

    final legacy = await databaseFactoryFfi.openDatabase(databasePath);
    await legacy.execute('''
        CREATE TABLE save_metadata (
          key TEXT PRIMARY KEY NOT NULL,
          value TEXT NOT NULL
        )
      ''');
    await legacy.insert('save_metadata', {'key': 'active_slot', 'value': '3'});
    final selected =
        Map<String, Object?>.from(
            (await legacy.query('player_state', where: 'id = 1')).single,
          )
          ..['id'] = 3
          ..['money'] = 987
          ..['day'] = 12;
    await legacy.insert('player_state', selected);
    await legacy.setVersion(40);
    await legacy.close();

    store = AppDatabase(
      databasePath: databasePath,
      factory: databaseFactoryFfi,
    );
    final state = await _repository(store).load();
    expect(state?.money, 987);
    expect(state?.day, 12);
    await store.close();

    final migrated = await databaseFactoryFfi.openDatabase(databasePath);
    expect(await migrated.query('player_state'), hasLength(1));
    expect(
      await migrated.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'save_metadata'",
      ),
      isEmpty,
    );
    await migrated.close();
  });
}

LocalPlayerStateRepository _repository(AppDatabase store) =>
    LocalPlayerStateRepository(database: store, mapper: PlayerStateMapper());
