import '../entities/player_state.dart';

abstract interface class PlayerStateRepository {
  Future<PlayerState?> load();

  Future<void> save(PlayerState state);
}
