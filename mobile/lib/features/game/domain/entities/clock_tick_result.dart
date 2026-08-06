import 'active_activity.dart';
import 'player_state.dart';

class ClockTickResult {
  const ClockTickResult({required this.state, this.completedActivity, required this.dayChanged});

  final PlayerState state;
  final ActiveActivity? completedActivity;
  final bool dayChanged;
}
