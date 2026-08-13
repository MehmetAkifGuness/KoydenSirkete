import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/game/domain/services/activity_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/services/game_clock_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/services/energy_recovery_service.dart';
import 'package:kariyerden_sirkete/features/earning/domain/services/earning_service.dart';
import 'package:kariyerden_sirkete/features/sport/domain/services/sport_service.dart';
import 'package:kariyerden_sirkete/core/errors/game_rule_exception.dart';

void main() {
  test('one game-hour clock tick advances one game hour', () {
    final result = GameClockService().tick(PlayerState.initial);

    expect(result.state.day, 1);
    expect(result.state.hour, 9);
    expect(result.state.energy, 100);
    expect(result.dayChanged, isFalse);
  });

  test('speed controls map real-time intervals to one game hour', () {
    expect(GameClockService.realTickInterval, const Duration(seconds: 20));
    expect(GameClockService.gameSpeedMultiplier, 1);
    expect(GameClockService.gameHoursPerRealTick, 1);
    expect(GameClockService.intervalForSpeed(2), const Duration(seconds: 10));
    expect(GameClockService.intervalForSpeed(4), const Duration(seconds: 5));

    final result = GameClockService().tick(
      PlayerState.initial,
      hours: GameClockService.gameHoursPerRealTick,
    );

    expect(result.state.hour, 9);
    expect(result.state.energy, 100);
  });

  test('energy recovers every real minute while the game is closed', () {
    final anchor = DateTime(2026, 1, 1);
    final service = EnergyRecoveryService();
    var state = PlayerState.initial.copyWith(energy: 70, energyRecoveryAt: anchor);

    state = service.recover(state, now: anchor.add(const Duration(seconds: 59)));
    expect(state.energy, 70);
    state = service.recover(state, now: anchor.add(const Duration(minutes: 1)));
    expect(state.energy, 80);
    state = service.recover(state, now: anchor.add(const Duration(minutes: 2)));
    expect(state.energy, 90);
    state = service.recover(state, now: anchor.add(const Duration(hours: 2)));
    expect(state.energy, 100);
  });

  test('negative money triggers bankruptcy after 24 game hours', () {
    final clock = GameClockService();
    var state = PlayerState.initial.copyWith(money: -1);

    for (var index = 0; index < 23; index++) {
      state = clock.tick(state).state;
    }
    expect(state.negativeMoneyHours, 23);
    expect(state.isBankrupt, isFalse);

    state = clock.tick(state).state;
    expect(state.negativeMoneyHours, 24);
    expect(state.isBankrupt, isTrue);
  });

  test('positive money resets the bankruptcy timer', () {
    final state = GameClockService().tick(
      PlayerState.initial.copyWith(money: 10, negativeMoneyHours: 23),
    ).state;

    expect(state.negativeMoneyHours, 0);
    expect(state.isBankrupt, isFalse);
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

  test('sport increases max energy after one hour', () {
    final activities = ActivityService();
    final sport = activities.startSport(PlayerState.initial);
    var state = activities.activate(PlayerState.initial, sport);
    final clock = GameClockService();

    expect(state.energy, 80);
    final tick = clock.tick(state);
    state = activities.complete(tick.state, tick.completedActivity!).state;

    expect(state.maxEnergy, PlayerState.initial.maxEnergy + SportService.maxEnergyGain);
  });

  test('career level controls concurrent activity capacity', () {
    final activities = ActivityService();
    final stateAtRankTwo = PlayerState.initial.copyWith(careerLevel: 2);
    final earning = activities.startEarning(stateAtRankTwo);
    final sport = activities.startSport(stateAtRankTwo);

    var state = activities.activate(stateAtRankTwo, earning);
    state = activities.activate(state, sport);

    expect(state.activities, hasLength(2));
    expect(state.hasActivityCapacity, isFalse);
    expect(
      () => activities.activate(state, activities.startEarning(state)),
      throwsA(isA<GameRuleException>()),
    );

    final tick = GameClockService().tick(state);
    expect(tick.completedActivities, hasLength(1));
    expect(tick.state.activities, hasLength(1));
  });
}
