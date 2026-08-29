import 'dart:math' as math;

class EconomyIndexService {
  const EconomyIndexService();

  static const periodDays = 30;
  static const percentPerPeriod = 1;
  static const maximumPercent = 25;

  double multiplierForDay(int day) {
    final periods = math.max(0, day - 1) ~/ periodDays;
    final percent = math.min(maximumPercent, periods * percentPerPeriod);
    return 1 + percent / 100;
  }

  int apply(int amount, int day) => (amount * multiplierForDay(day)).round();
}
