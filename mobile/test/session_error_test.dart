import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/earning/domain/services/earning_service.dart';
import 'package:kariyerden_sirkete/features/game/application/game_session_application_service.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/game/domain/repositories/player_state_repository.dart';
import 'package:kariyerden_sirkete/features/game/domain/services/rest_service.dart';
import 'package:kariyerden_sirkete/features/game/presentation/state/game_session_controller.dart';
import 'package:kariyerden_sirkete/features/training/domain/services/training_service.dart';

void main() {
  test('session exposes a recoverable storage error', () async {
    final controller = GameSessionController(
      applicationService: GameSessionApplicationService(
        repository: _FailingRepository(),
        earningService: EarningService(),
        trainingService: TrainingService(),
        restService: RestService(),
      ),
    );

    await controller.initialize();

    expect(controller.isReady, isTrue);
    expect(controller.errorMessage, isNotNull);
    expect(controller.state, PlayerState.initial);
  });
}

class _FailingRepository implements PlayerStateRepository {
  @override
  Future<PlayerState?> load() async => throw StateError('storage unavailable');

  @override
  Future<void> save(PlayerState state) async {}
}
