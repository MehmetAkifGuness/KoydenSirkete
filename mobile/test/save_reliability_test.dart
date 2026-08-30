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
      expect(
        (await store.listSlots()).singleWhere((slot) => slot.slot == 1).hasSave,
        isTrue,
      );
      await _repository(store).save(state!);
      await store.close();

      final migrated = await databaseFactoryFfi.openDatabase(databasePath);
      expect(await migrated.getVersion(), 39);
      final columns =
          (await migrated.rawQuery('PRAGMA table_info(player_state)'))
              .map((row) => row['name'])
              .toSet();
      expect(
        columns,
        containsAll(['data_checksum', 'save_revision', 'updated_at']),
      );
      expect(
        await migrated.rawQuery(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'save_metadata'",
        ),
        isNotEmpty,
      );
      await migrated.close();
    },
  );

  test(
    'bozulan son kayıt otomatik olarak son sağlam yerel yedekten açılır',
    () async {
      var store = AppDatabase(
        databasePath: databasePath,
        factory: databaseFactoryFfi,
      );
      var repository = _repository(store);
      await repository.save(PlayerState.initial.copyWith(money: 100));
      await repository.save(PlayerState.initial.copyWith(money: 200));
      await store.close();

      final raw = await databaseFactoryFfi.openDatabase(databasePath);
      await raw.update('player_state', {'money': 999}, where: 'id = 1');
      await raw.close();

      store = AppDatabase(
        databasePath: databasePath,
        factory: databaseFactoryFfi,
      );
      repository = _repository(store);
      expect((await repository.load())?.money, 100);
      expect((await repository.load())?.money, 100);
      await store.close();
    },
  );

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

  test(
    'üç yuva bağımsızdır ve dışa/içe aktarma bütünlüğü doğrulanır',
    () async {
      final store = AppDatabase(
        databasePath: databasePath,
        factory: databaseFactoryFfi,
      );
      final repository = _repository(store);
      await repository.save(PlayerState.initial.copyWith(money: 321, day: 7));
      final exported = await store.exportSlot(1);

      await store.switchSlot(3);
      await repository.save(PlayerState.initial.copyWith(money: 987, day: 12));
      await store.importSlot(exported, slot: 2);

      expect(store.activeSlot, 2);
      expect((await repository.load())?.money, 321);
      await store.switchSlot(3);
      expect((await repository.load())?.money, 987);
      expect(
        (await store.listSlots()).where((slot) => slot.hasSave),
        hasLength(3),
      );
      await store.close();
    },
  );
}

LocalPlayerStateRepository _repository(AppDatabase store) =>
    LocalPlayerStateRepository(database: store, mapper: PlayerStateMapper());
