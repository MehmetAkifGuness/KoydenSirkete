import 'dart:math' as math;

import '../entities/earning_performance.dart';

class EarningMiniGameService {
  static const gridSize = 3;
  static const cellCount = gridSize * gridSize;
  static const durationSeconds = 10;
  static const maxHits = 24;
  static const baseBonusHitLimit = 10;
  static const baseBonusPerHit = .05;
  static const streakIncreasePerHit = .10;
  static const maximumRewardMultiplier = 3.0;

  EarningPerformance performanceFor(int hits) {
    return EarningPerformance(hits: hits.clamp(0, maxHits).toInt());
  }

  int bonusPercent(EarningPerformance performance) {
    return ((rewardMultiplier(performance) - 1) * 100).round();
  }

  double rewardMultiplier(EarningPerformance performance) {
    final hits = performance.hits.clamp(0, maxHits);
    final baseHits = math.min(hits, baseBonusHitLimit);
    final baseMultiplier = 1 + baseHits * baseBonusPerHit;
    if (hits <= baseBonusHitLimit) return baseMultiplier;
    final streakHits = hits - baseBonusHitLimit;
    return math
        .min(
          maximumRewardMultiplier,
          baseMultiplier * math.pow(1 + streakIncreasePerHit, streakHits),
        )
        .toDouble();
  }
}
