class CareerScoreCategory {
  const CareerScoreCategory({
    required this.title,
    required this.description,
    required this.score,
  });

  final String title;
  final String description;
  final int score;
}

class CareerScoreGoal {
  const CareerScoreGoal({
    required this.title,
    required this.description,
    required this.current,
    required this.target,
    required this.scoreReward,
  });

  final String title;
  final String description;
  final int current;
  final int target;
  final int scoreReward;

  double get progress => target <= 0 ? 1 : (current / target).clamp(0, 1);
}

class CareerScoreSummary {
  const CareerScoreSummary({
    required this.totalScore,
    required this.title,
    required this.currentThreshold,
    required this.nextTarget,
    required this.prestigeLevel,
    required this.categories,
    required this.goals,
  });

  final int totalScore;
  final String title;
  final int currentThreshold;
  final int nextTarget;
  final int prestigeLevel;
  final List<CareerScoreCategory> categories;
  final List<CareerScoreGoal> goals;

  int get remainingScore => (nextTarget - totalScore).clamp(0, nextTarget);
  double get progress {
    final range = nextTarget - currentThreshold;
    if (range <= 0) return 1;
    return ((totalScore - currentThreshold) / range).clamp(0, 1);
  }
}
