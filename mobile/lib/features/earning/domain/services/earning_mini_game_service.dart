import '../entities/earning_performance.dart';

class EarningMiniGameService {
  static const gridSize = 3;
  static const cellCount = gridSize * gridSize;
  static const durationSeconds = 10;
  static const maxHits = 24;

  EarningPerformance performanceFor(int hits) {
    return EarningPerformance(hits: hits.clamp(0, maxHits).toInt());
  }

  int bonusPercent(EarningPerformance performance) {
    final hits = performance.hits.clamp(0, maxHits);
    if (hits >= 12) {
      return 35;
    }
    if (hits >= 8) {
      return 20;
    }
    if (hits >= 4) {
      return 10;
    }
    return 0;
  }

  double rewardMultiplier(EarningPerformance performance) {
    return 1 + bonusPercent(performance) / 100;
  }
}
