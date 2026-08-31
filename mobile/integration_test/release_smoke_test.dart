import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:kariyerden_sirkete/app/app.dart';
import 'package:kariyerden_sirkete/core/database/app_database.dart';
import 'package:kariyerden_sirkete/features/game/data/mappers/player_state_mapper.dart';
import 'package:kariyerden_sirkete/features/game/data/repositories/local_player_state_repository.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('çevrimdışı açılış ve kalıcı kayıt duman testi', (tester) async {
    final databasePath = join(await getDatabasesPath(), 'release_smoke.db');
    await databaseFactory.deleteDatabase(databasePath);
    addTearDown(() => databaseFactory.deleteDatabase(databasePath));

    var store = AppDatabase(databasePath: databasePath);
    var repository = _repository(store);
    final expected = PlayerState.initial.copyWith(
      isOnboarded: true,
      tutorialCompleted: true,
      day: 17,
      money: 12345,
      companyLevel: 1,
      companyFunds: 6789,
    );
    await repository.save(expected);
    await store.close();

    store = AppDatabase(databasePath: databasePath);
    repository = _repository(store);
    final restored = await repository.load();
    expect(restored?.day, expected.day);
    expect(restored?.money, expected.money);
    expect(restored?.companyFunds, expected.companyFunds);

    await tester.pumpWidget(CareerToCompanyApp(playerStateStore: store));
    await tester.pumpAndSettle();
    expect(find.text('GÜNLÜK DURUM'), findsOneWidget);
  });
}

LocalPlayerStateRepository _repository(AppDatabase database) =>
    LocalPlayerStateRepository(database: database, mapper: PlayerStateMapper());
