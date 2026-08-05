import '../entities/player_state.dart';

class RestService {
  static const durationHours = 8;

  PlayerState execute(PlayerState state) {
    return state.advanceHours(durationHours).copyWith(energy: 100);
  }
}
