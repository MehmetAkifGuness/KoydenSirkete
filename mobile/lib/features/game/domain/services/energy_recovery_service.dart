import 'dart:math' as math;

import '../../../assets/domain/services/asset_service.dart';
import '../entities/player_state.dart';

class EnergyRecoveryService {
  EnergyRecoveryService({AssetService? assetService})
    : _assetService = assetService ?? AssetService();

  static const recoveryInterval = Duration(minutes: 1);
  static const recoveryAmount = 10;
  static const maximumOfflineRecovery = Duration(hours: 12);

  final AssetService _assetService;

  PlayerState recover(PlayerState state, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final anchor = state.energyRecoveryAt;
    if (anchor == null) {
      return state.copyWith(energyRecoveryAt: currentTime);
    }

    final elapsed = currentTime.difference(anchor);
    if (elapsed.isNegative) {
      return state;
    }

    final creditedElapsed = elapsed > maximumOfflineRecovery
        ? maximumOfflineRecovery
        : elapsed;
    final completedIntervals =
        creditedElapsed.inSeconds ~/ recoveryInterval.inSeconds;
    final remainder = creditedElapsed.inSeconds % recoveryInterval.inSeconds;
    final recoveredEnergy = math.min(
      state.maxEnergy,
      state.energy +
          completedIntervals *
              (recoveryAmount + _assetService.energyRecoveryBonus(state)),
    );
    return state.copyWith(
      energy: recoveredEnergy,
      energyRecoveryAt: elapsed > maximumOfflineRecovery
          ? currentTime
          : currentTime.subtract(Duration(seconds: remainder)),
    );
  }
}
