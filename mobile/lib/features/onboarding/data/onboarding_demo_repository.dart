import '../../economy/domain/entities/economy_difficulty.dart';
import '../../game/domain/entities/player_state.dart';
import '../../game/domain/repositories/player_state_repository.dart';

class OnboardingDemoRepository implements PlayerStateRepository {
  PlayerState _state = PlayerState.initial;

  void reset(EconomyDifficulty difficulty) {
    _state = PlayerState.initial.copyWith(
      isOnboarded: true,
      economyDifficulty: difficulty,
      money: 25000,
      knowledge: 50,
      experience: 500,
      careerLevel: 3,
    );
  }

  @override
  Future<PlayerState?> load() async => _state;

  @override
  Future<void> save(PlayerState state) async => _state = state;
}
