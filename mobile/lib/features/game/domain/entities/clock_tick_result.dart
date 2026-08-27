import 'active_activity.dart';
import 'player_state.dart';

class ClockTickResult {
  const ClockTickResult({
    required this.state,
    this.completedActivity,
    this.completedActivities = const <ActiveActivity>[],
    required this.dayChanged,
  });

  final PlayerState state;
  final ActiveActivity? completedActivity;
  final List<ActiveActivity> completedActivities;
  final bool dayChanged;

  List<ActiveActivity> get activities => completedActivities.isNotEmpty
      ? completedActivities
      : completedActivity == null
      ? const <ActiveActivity>[]
      : <ActiveActivity>[completedActivity!];
}
