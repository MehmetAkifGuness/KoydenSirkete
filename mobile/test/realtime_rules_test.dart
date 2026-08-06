import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/game/domain/services/activity_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/services/game_clock_service.dart';
import 'package:kariyerden_sirkete/features/earning/domain/services/earning_service.dart';
import 'package:kariyerden_sirkete/features/sport/domain/services/sport_service.dart';
import 'package:kariyerden_sirkete/features/game/presentation/state/foreground_clock_ticker.dart';

void main() {
  test('one game-hour clock tick advances one game hour', () {
    final result = GameClockService().tick(PlayerState.initial);

    expect(result.state.day, 1);
    expect(result.state.hour, 9);
    expect(result.state.energy, 100);
    expect(result.dayChanged, isFalse);
  });

  test('20-second foreground tick advances one game hour', () {
    expect(ForegroundClockTicker.tickInterval, const Duration(seconds: 20));

    final result = GameClockService().tick(
      PlayerState.initial,
      hours: GameClockService.gameHoursPerRealTick,
    );

    expect(result.state.hour, 9);
    expect(result.state.energy, 100);
  });

  test('energy recovers every three game hours and stays below max', () {
    var state = PlayerState.initial.copyWith(energy: 70);
    final clock = GameClockService();

    state = clock.tick(state).state;
    expect(state.energy, 70);
    state = clock.tick(state).state;
    expect(state.energy, 70);
    state = clock.tick(state).state;
    expect(state.energy, 80);

    for (var index = 0; index < 4; index++) {
      state = clock.tick(state).state;
    }
    expect(state.energy, 90);
  });

  test('activity spends energy at start and rewards only at completion', () {
    final activities = ActivityService();
    final earning = activities.startEarning(PlayerState.initial);
    var state = activities.activate(PlayerState.initial, earning);
    final clock = GameClockService();

    expect(state.energy, PlayerState.initial.energy - EarningService.energyCost);
    expect(state.money, PlayerState.initial.money);
    state = clock.tick(state).state;
    expect(state.activeActivity, isNotNull);
    expect(state.money, PlayerState.initial.money);
    final tick = clock.tick(state);
    final completed = activities.complete(tick.state, tick.completedActivity!);

    expect(completed.state.activeActivity, isNull);
    expect(completed.state.money, greaterThan(PlayerState.initial.money));
  });

  test('sport increases max energy after two hours', () {
    final activities = ActivityService();
    final sport = activities.startSport(PlayerState.initial);
    var state = activities.activate(PlayerState.initial, sport);
    final clock = GameClockService();

    expect(state.energy, 80);
    state = clock.tick(state).state;
    final tick = clock.tick(state);
    state = activities.complete(tick.state, tick.completedActivity!).state;

    expect(state.maxEnergy, PlayerState.initial.maxEnergy + SportService.maxEnergyGain);
  });
}
