import 'dart:math' as math;

import '../entities/economy_difficulty.dart';

class EconomyIndexService {
  const EconomyIndexService();

  static const periodDays = 30;
  static const percentPerPeriod = 1;
  static const maximumPercent = 25;

  double multiplierForDay(
    int day, {
    EconomyDifficulty difficulty = EconomyDifficulty.normal,
  }) {
    final periods = math.max(0, day - 1) ~/ periodDays;
    final percent = math.min(
      maximumPercent,
      periods * difficulty.monthlyInflationPercent,
    );
    return 1 + percent / 100;
  }

  int apply(int amount, int day) => applyIncome(amount, day);

  int applyIncome(
    int amount,
    int day, {
    EconomyDifficulty difficulty = EconomyDifficulty.normal,
  }) =>
      (amount *
              multiplierForDay(day, difficulty: difficulty) *
              difficulty.incomeMultiplier)
          .round();

  int applyExpense(
    int amount,
    int day, {
    EconomyDifficulty difficulty = EconomyDifficulty.normal,
  }) =>
      (amount *
              multiplierForDay(day, difficulty: difficulty) *
              difficulty.expenseMultiplier)
          .round();
}
