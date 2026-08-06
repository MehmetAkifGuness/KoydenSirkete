import 'player_state.dart';

class GameTickOutcome {
  const GameTickOutcome({required this.state, required this.dayChanged, this.message});

  final PlayerState state;
  final bool dayChanged;
  final String? message;
}
