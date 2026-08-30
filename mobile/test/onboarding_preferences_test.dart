import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/features/economy/domain/entities/economy_difficulty.dart';
import 'package:kariyerden_sirkete/features/game/application/game_session_application_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/game/domain/repositories/player_state_repository.dart';
import 'package:kariyerden_sirkete/features/game/domain/services/player_guidance_service.dart';
import 'package:kariyerden_sirkete/features/game/presentation/state/game_session_controller.dart';

void main() {
  test('onboarding chooses and permanently locks economy difficulty', () async {
    final repository = _MemoryRepository();
    final session = await _readySession(repository);
    addTearDown(session.dispose);

    await session.completeOnboarding(EconomyDifficulty.hard);

    expect(session.state.isOnboarded, isTrue);
    expect(session.state.economyDifficulty, EconomyDifficulty.hard);
    final message = await session.setEconomyDifficulty(EconomyDifficulty.easy);
    expect(message, contains('değiştirilemez'));
    expect(session.state.economyDifficulty, EconomyDifficulty.hard);
  });

  test('sound and haptic preferences survive a repository reload', () async {
    final repository = _MemoryRepository();
    final session = await _readySession(repository);
    await session.setFeedbackPreferences(
      soundEffectsEnabled: false,
      hapticsEnabled: false,
    );
    session.dispose();

    final reloaded = await _readySession(repository);
    addTearDown(reloaded.dispose);
    expect(reloaded.state.soundEffectsEnabled, isFalse);
    expect(reloaded.state.hapticsEnabled, isFalse);
  });

  test('tutorial progress survives reload and can be completed', () async {
    final repository = _MemoryRepository();
    final session = await _readySession(repository);
    await session.completeOnboarding(EconomyDifficulty.normal);
    await session.setTutorialProgress(step: 4, completed: false);
    session.dispose();

    final resumed = await _readySession(repository);
    expect(resumed.state.tutorialStep, 4);
    expect(resumed.state.tutorialCompleted, isFalse);
    await resumed.setTutorialProgress(step: 7, completed: true);
    resumed.dispose();

    final completed = await _readySession(repository);
    addTearDown(completed.dispose);
    expect(completed.state.tutorialStep, 7);
    expect(completed.state.tutorialCompleted, isTrue);
  });

  test('dashboard guidance follows the player state', () {
    const guidance = PlayerGuidanceService();

    expect(guidance.nextAction(PlayerState.initial), contains('Kazanç'));
    expect(
      guidance.nextAction(PlayerState.initial.copyWith(money: 1500)),
      contains('Eğitim'),
    );
    expect(
      guidance.nextAction(
        PlayerState.initial.copyWith(money: 1500, knowledge: 50),
      ),
      contains('İş fırsatlarını'),
    );
  });
}

Future<GameSessionController> _readySession(
  PlayerStateRepository repository,
) async {
  final session = GameSessionController(
    applicationService: GameSessionApplicationService(repository: repository),
  );
  await session.initialize();
  return session;
}

class _MemoryRepository implements PlayerStateRepository {
  PlayerState? state;

  @override
  Future<PlayerState?> load() async => state;

  @override
  Future<void> save(PlayerState value) async => state = value;
}
