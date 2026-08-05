import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/app/app.dart';
import 'package:kariyerden_sirkete/core/database/player_state_store.dart';

void main() {
  testWidgets('offline onboarding opens the playable dashboard', (tester) async {
    await tester.pumpWidget(CareerToCompanyApp(playerStateStore: _MemoryPlayerStateStore()));
    await tester.pumpAndSettle();

    expect(find.text('Oyuna başla'), findsOneWidget);

    await tester.tap(find.text('Oyuna başla'));
    await tester.pumpAndSettle();

    expect(find.text('Panel'), findsOneWidget);
  });
}

class _MemoryPlayerStateStore implements PlayerStateStore {
  PlayerStateRecord? _record;

  @override
  Future<PlayerStateRecord?> readPlayerState() async => _record;

  @override
  Future<void> savePlayerState(PlayerStateRecord record) async {
    _record = record;
  }

  @override
  Future<void> close() async {}
}
