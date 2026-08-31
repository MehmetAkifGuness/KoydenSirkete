import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:kariyerden_sirkete/core/database/app_database.dart';
import 'package:kariyerden_sirkete/features/economy/domain/entities/economy_difficulty.dart';
import 'package:kariyerden_sirkete/features/game/application/game_session_application_service.dart';
import 'package:kariyerden_sirkete/features/game/data/mappers/player_state_mapper.dart';
import 'package:kariyerden_sirkete/features/game/data/repositories/local_player_state_repository.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/debug_state_patch.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/game/domain/repositories/player_state_repository.dart';
import 'package:kariyerden_sirkete/features/game/presentation/state/game_session_controller.dart';

void main() {
  sqfliteFfiInit();

  test('oyun ilerlemesi uygulama yeniden açıldığında korunur', () async {
    final directory = await Directory.systemTemp.createTemp('mudur_restart_');
    final path = '${directory.path}${Platform.pathSeparator}save.db';
    addTearDown(() async {
      await databaseFactoryFfi.deleteDatabase(path);
      await directory.delete(recursive: true);
    });

    var database = AppDatabase(databasePath: path, factory: databaseFactoryFfi);
    var session = await _readySession(_sqliteRepository(database));
    expect(await session.completeOnboarding(EconomyDifficulty.normal), isTrue);
    await session.updateDebugState(
      const DebugStatePatch(day: 42, money: 9876, experience: 321),
    );
    session.dispose();
    await database.close();

    database = AppDatabase(databasePath: path, factory: databaseFactoryFfi);
    session = await _readySession(_sqliteRepository(database));
    expect(session.state.isOnboarded, isTrue);
    expect(session.state.day, 42);
    expect(session.state.money, greaterThan(PlayerState.initial.money));
    expect(session.state.experience, 321);
    session.dispose();
    await database.close();
  });

  test('eski tutarsız onboarding kaydı ilerlemeyi silmeden onarılır', () async {
    final repository = _MemoryRepository(
      PlayerState.initial.copyWith(
        money: 4500,
        day: 12,
        tutorialCompleted: true,
        isOnboarded: false,
      ),
    );

    final session = await _readySession(repository);
    addTearDown(session.dispose);

    expect(session.state.isOnboarded, isTrue);
    expect(session.state.tutorialCompleted, isTrue);
    expect(session.state.money, greaterThan(PlayerState.initial.money));
    expect(session.state.day, 12);
    expect(repository.state?.isOnboarded, isTrue);
  });

  test('ilk kayıt başarısızsa öğretici ilerlemesi oluşturulmaz', () async {
    final repository = _FailingRepository();
    final session = await _readySession(repository);
    addTearDown(session.dispose);

    expect(await session.completeOnboarding(EconomyDifficulty.normal), isFalse);
    expect(session.state.isOnboarded, isFalse);
    expect(
      await session.setTutorialProgress(step: 1, completed: false),
      contains('önce yeni oyun kaydı'),
    );
    expect(session.state.tutorialStep, 0);
  });
}

Future<GameSessionController> _readySession(
  PlayerStateRepository repository,
) async {
  final session = GameSessionController(
    applicationService: GameSessionApplicationService(repository: repository),
  );
  await session.initialize();
  return session;
}

LocalPlayerStateRepository _sqliteRepository(AppDatabase database) =>
    LocalPlayerStateRepository(database: database, mapper: PlayerStateMapper());

class _MemoryRepository implements PlayerStateRepository {
  _MemoryRepository(this.state);

  PlayerState? state;

  @override
  Future<PlayerState?> load() async => state;

  @override
  Future<void> save(PlayerState value) async => state = value;
}

class _FailingRepository implements PlayerStateRepository {
  var saves = 0;

  @override
  Future<PlayerState?> load() async => null;

  @override
  Future<void> save(PlayerState state) async {
    saves++;
    if (saves > 1) throw const FileSystemException('simulated save failure');
  }
}
