import 'dart:math' as math;

import '../entities/player_state.dart';

class EnergyRecoveryService {
  static const recoveryInterval = Duration(minutes: 1);
  static const recoveryAmount = 10;

  PlayerState recover(PlayerState state, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final anchor = state.energyRecoveryAt;
    if (anchor == null) {
      return state.copyWith(energyRecoveryAt: currentTime);
    }

    final elapsed = currentTime.difference(anchor);
    if (elapsed.isNegative) {
      return state.copyWith(energyRecoveryAt: currentTime);
    }

    final completedIntervals = elapsed.inSeconds ~/ recoveryInterval.inSeconds;
    final remainder = elapsed.inSeconds % recoveryInterval.inSeconds;
    final recoveredEnergy = math.min(
      state.maxEnergy,
      state.energy + completedIntervals * recoveryAmount,
    );
    return state.copyWith(
      energy: recoveredEnergy,
      energyRecoveryAt: currentTime.subtract(Duration(seconds: remainder)),
    );
  }
}
