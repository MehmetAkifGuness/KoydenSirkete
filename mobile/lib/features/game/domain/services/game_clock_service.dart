import 'dart:math' as math;

import '../entities/active_activity.dart';
import '../entities/clock_tick_result.dart';
import '../entities/player_state.dart';

class GameClockService {
  static const realTickInterval = Duration(seconds: 20);
  static const gameHoursPerRealTick = 1;
  static const hoursPerRecovery = 3;
  static const recoveryAmount = 10;

  ClockTickResult tick(PlayerState state, {int hours = 1}) {
    if (hours < 1) {
      throw ArgumentError.value(hours, 'hours', 'must be positive');
    }

    var current = state;
    var dayChanged = false;
    ActiveActivity? completedActivity;
    for (var index = 0; index < hours; index++) {
      final result = _tickHour(current);
      current = result.state;
      dayChanged = dayChanged || result.dayChanged;
      completedActivity ??= result.completedActivity;
    }
    return ClockTickResult(
      state: current,
      completedActivity: completedActivity,
      dayChanged: dayChanged,
    );
  }

  ClockTickResult _tickHour(PlayerState state) {
    final advanced = state.advanceGameHour();
    final dayChanged = advanced.day != state.day;
    final recoveryRemainder = state.energyRecoveryRemainder + 1;
    final shouldRecover = recoveryRemainder >= hoursPerRecovery;
    final nextRemainder = shouldRecover ? recoveryRemainder - hoursPerRecovery : recoveryRemainder;
    final nextEnergy = shouldRecover ? math.min(advanced.maxEnergy, advanced.energy + recoveryAmount) : advanced.energy;
    final negativeMoneyHours = advanced.money < 0 ? math.min(PlayerState.bankruptcyDurationHours, advanced.negativeMoneyHours + 1) : 0;
    final activity = advanced.activeActivity;
    if (activity == null) {
      return ClockTickResult(
        state: advanced.copyWith(energy: nextEnergy, energyRecoveryRemainder: nextRemainder, negativeMoneyHours: negativeMoneyHours),
        dayChanged: dayChanged,
      );
    }

    final remaining = activity.remainingHours - 1;
    final completed = remaining <= 0 ? activity : null;
    final nextActivity = remaining <= 0 ? null : activity.copyWith(remainingHours: remaining);
    return ClockTickResult(
      state: advanced.copyWith(
        energy: nextEnergy,
        energyRecoveryRemainder: nextRemainder,
        negativeMoneyHours: negativeMoneyHours,
        activeActivity: nextActivity,
      ),
      completedActivity: completed,
      dayChanged: dayChanged,
    );
  }
}
