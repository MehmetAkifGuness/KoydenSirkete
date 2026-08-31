import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:kariyerden_sirkete/app/app.dart';
import 'package:kariyerden_sirkete/core/database/app_database.dart';
import 'package:kariyerden_sirkete/features/finance/domain/entities/finance_ledger.dart';
import 'package:kariyerden_sirkete/features/game/data/mappers/player_state_mapper.dart';
import 'package:kariyerden_sirkete/features/game/data/repositories/local_player_state_repository.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const tier = String.fromEnvironment('PERFORMANCE_TIER', defaultValue: 'low');

  testWidgets('Android $tier donanım performans duman testi', (tester) async {
    final limits = switch (tier) {
      'low' => (startup: 7000, save: 3500, animation: 2200),
      'mid' => (startup: 5000, save: 2500, animation: 1500),
      'high' => (startup: 3500, save: 1800, animation: 1000),
      _ => throw ArgumentError.value(tier, 'PERFORMANCE_TIER'),
    };
    final path = join(await getDatabasesPath(), 'performance_smoke.db');
    await databaseFactory.deleteDatabase(path);
    final store = AppDatabase(databasePath: path);
    addTearDown(() async {
      await store.close();
      await databaseFactory.deleteDatabase(path);
    });
    final repository = LocalPlayerStateRepository(
      database: store,
      mapper: PlayerStateMapper(),
    );
    final largeState = _largeState();

    final saveWatch = Stopwatch()..start();
    await repository.save(largeState);
    saveWatch.stop();

    final startupWatch = Stopwatch()..start();
    await tester.pumpWidget(CareerToCompanyApp(playerStateStore: store));
    await tester.pumpAndSettle();
    startupWatch.stop();

    await binding.traceAction(() async {
      final scrollable = find.byType(Scrollable).first;
      for (var index = 0; index < 8; index++) {
        await tester.fling(scrollable, const Offset(0, -450), 1800);
        await tester.pumpAndSettle();
      }
    }, reportKey: 'dashboard_scroll_$tier');

    final animationWatch = Stopwatch()..start();
    await tester.tap(find.text('Şirket').last);
    await tester.pumpAndSettle();
    animationWatch.stop();

    final metrics = <String, int>{
      'startup_ms': startupWatch.elapsedMilliseconds,
      'large_save_ms': saveWatch.elapsedMilliseconds,
      'navigation_animation_ms': animationWatch.elapsedMilliseconds,
      'ledger_entries': largeState.financeLedger.entries.length,
    };
    binding.reportData = {...?binding.reportData, 'performance_$tier': metrics};

    expect(metrics['startup_ms'], lessThan(limits.startup));
    expect(metrics['large_save_ms'], lessThan(limits.save));
    expect(metrics['navigation_animation_ms'], lessThan(limits.animation));
  });
}

PlayerState _largeState() {
  final entries = List<FinanceEntry>.generate(20000, (index) {
    final company = index.isEven;
    return FinanceEntry(
      day: index % 30 + 1,
      category: company
          ? FinanceCategory.companyRevenue
          : FinanceCategory.salaryIncome,
      amount: index % 4 == 0 ? -20 : 40,
      account: company ? FinanceAccount.company : FinanceAccount.personal,
    );
  });
  return PlayerState.initial.copyWith(
    isOnboarded: true,
    tutorialCompleted: true,
    day: 30,
    money: 50000,
    companyLevel: 2,
    companyFunds: 100000,
    financeLedger: FinanceLedger(entries: entries),
  );
}
