enum EconomyDifficulty {
  easy('Kolay', .90, 1.10, .5),
  normal('Normal', 1, 1, 1),
  hard('Zor', 1.10, .90, 1.5);

  const EconomyDifficulty(
    this.label,
    this.expenseMultiplier,
    this.incomeMultiplier,
    this.monthlyInflationPercent,
  );

  final String label;
  final double expenseMultiplier;
  final double incomeMultiplier;
  final double monthlyInflationPercent;

  static EconomyDifficulty fromName(String? value) => values.firstWhere(
    (difficulty) => difficulty.name == value,
    orElse: () => normal,
  );
}
