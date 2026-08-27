import '../../../game/domain/entities/player_state.dart';

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.measure,
    required this.target,
  });

  final int id;
  final String title;
  final String description;
  final int reward;
  final int target;
  final int Function(PlayerState state) measure;

  bool isUnlocked(PlayerState state) =>
      state.unlockedAchievementsMask & (1 << (id - 1)) != 0;
  int progress(PlayerState state) => measure(state).clamp(0, target);
}

class AchievementEvaluation {
  const AchievementEvaluation({required this.state, required this.unlocked});

  final PlayerState state;
  final List<Achievement> unlocked;
}
