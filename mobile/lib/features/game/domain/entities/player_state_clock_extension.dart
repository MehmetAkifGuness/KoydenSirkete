import 'player_state.dart';

extension PlayerStateClockExtension on PlayerState {
  PlayerState advanceGameHour() {
    final absoluteHour = (day - 1) * 24 + hour + 1;
    final nextDay = absoluteHour ~/ 24 + 1;
    final nextHour = absoluteHour % 24;
    return copyWith(
      day: nextDay,
      hour: nextHour,
      earningSessionsToday: nextDay == day ? earningSessionsToday : 0,
      workSessionsToday: nextDay == day ? workSessionsToday : 0,
      trainingSessionsToday: nextDay == day ? trainingSessionsToday : 0,
      wheelMajorRewardsToday: nextDay == day ? wheelMajorRewardsToday : 0,
    );
  }
}
