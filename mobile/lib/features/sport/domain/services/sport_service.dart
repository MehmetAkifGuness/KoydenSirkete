import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/active_activity.dart';
import '../../../game/domain/entities/player_state.dart';

class SportService {
  static const energyCost = 20;
  static const durationHours = 1;
  static const maxEnergyGain = 5;
  static const maxEnergyLimit = 1000;

  ActiveActivity start(PlayerState state) {
    if (state.energy < energyCost) {
      throw const GameRuleException(
        'Spor yapmak için en az 20 enerji gerekir.',
      );
    }
    return ActiveActivity(
      type: ActivityType.sport,
      sourceId: 'sport',
      remainingHours: durationHours,
      totalHours: durationHours,
      energyCost: energyCost,
      startedDay: state.day,
      startedHour: state.hour,
    );
  }

  PlayerState complete(PlayerState state) {
    final nextMaxEnergy = (state.maxEnergy + maxEnergyGain).clamp(
      100,
      maxEnergyLimit,
    );
    return state.copyWith(
      maxEnergy: nextMaxEnergy,
      energy: state.energy.clamp(0, nextMaxEnergy),
    );
  }
}
