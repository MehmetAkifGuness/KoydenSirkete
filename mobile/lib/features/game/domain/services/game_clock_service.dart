import 'dart:math' as math;

import '../entities/active_activity.dart';
import '../entities/clock_tick_result.dart';
import '../entities/player_state.dart';

class GameClockService {
  static const realTickInterval = Duration(seconds: 20);
  static const gameSpeedMultiplier = 2;
  static const gameHoursPerRealTick = gameSpeedMultiplier;

  ClockTickResult tick(PlayerState state, {int hours = 1}) {
    if (hours < 1) {
      throw ArgumentError.value(hours, 'hours', 'must be positive');
    }

    var current = state;
    var dayChanged = false;
    final completedActivities = <ActiveActivity>[];
    for (var index = 0; index < hours; index++) {
      final result = _tickHour(current);
      current = result.state;
      dayChanged = dayChanged || result.dayChanged;
      completedActivities.addAll(result.activities);
    }
    return ClockTickResult(
      state: current,
      completedActivity: completedActivities.isEmpty ? null : completedActivities.first,
      completedActivities: completedActivities,
      dayChanged: dayChanged,
    );
  }

  ClockTickResult _tickHour(PlayerState state) {
    final advanced = state.advanceGameHour();
    final dayChanged = advanced.day != state.day;
    final negativeMoneyHours = advanced.money < 0 ? math.min(PlayerState.bankruptcyDurationHours, advanced.negativeMoneyHours + 1) : 0;
    final activities = advanced.activities;
    if (activities.isEmpty) {
      return ClockTickResult(
        state: advanced.copyWith(negativeMoneyHours: negativeMoneyHours),
        dayChanged: dayChanged,
      );
    }

    final completed = <ActiveActivity>[];
    final nextActivities = <ActiveActivity>[];
    for (final activity in activities) {
      final remaining = activity.remainingHours - 1;
      if (remaining <= 0) {
        completed.add(activity);
      } else {
        nextActivities.add(activity.copyWith(remainingHours: remaining));
      }
    }
    return ClockTickResult(
      state: advanced.copyWith(
        negativeMoneyHours: negativeMoneyHours,
        activeActivity: null,
        activeActivities: nextActivities,
      ),
      completedActivity: completed.isEmpty ? null : completed.first,
      completedActivities: completed,
      dayChanged: dayChanged,
    );
  }
}
