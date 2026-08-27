enum FinanceCategory {
  casualIncome,
  salaryIncome,
  rentalIncome,
  rewards,
  assetPurchase,
  assetSale,
  training,
  relocation,
  housing,
  food,
  utilities,
  transportation,
  rentalMaintenance,
  wheel,
  companyInvestment,
}

class FinanceEntry {
  const FinanceEntry({
    required this.day,
    required this.category,
    required this.amount,
  });

  final int day;
  final FinanceCategory category;
  final int amount;
}

class FinanceTotals {
  const FinanceTotals({required this.income, required this.expense});

  final int income;
  final int expense;

  int get net => income - expense;
}

class FinanceLedger {
  const FinanceLedger({this.entries = const <FinanceEntry>[]});

  static const retainedDays = 30;

  final List<FinanceEntry> entries;

  FinanceLedger record({
    required int day,
    required FinanceCategory category,
    required int amount,
  }) {
    if (amount == 0) return this;
    final firstRetainedDay = day - retainedDays + 1;
    final next = <FinanceEntry>[];
    var merged = false;
    for (final entry in entries) {
      if (entry.day < firstRetainedDay) continue;
      if (entry.day == day && entry.category == category) {
        final mergedAmount = entry.amount + amount;
        if (mergedAmount != 0) {
          next.add(
            FinanceEntry(
              day: day,
              category: category,
              amount: mergedAmount,
            ),
          );
        }
        merged = true;
      } else {
        next.add(entry);
      }
    }
    if (!merged) {
      next.add(FinanceEntry(day: day, category: category, amount: amount));
    }
    next.sort((left, right) {
      final dayOrder = left.day.compareTo(right.day);
      return dayOrder != 0
          ? dayOrder
          : left.category.index.compareTo(right.category.index);
    });
    return FinanceLedger(entries: List<FinanceEntry>.unmodifiable(next));
  }

  List<FinanceEntry> forDay(int day) =>
      entries.where((entry) => entry.day == day).toList(growable: false);

  FinanceTotals totals({required int fromDay, required int toDay}) {
    var income = 0;
    var expense = 0;
    for (final entry in entries) {
      if (entry.day < fromDay || entry.day > toDay) continue;
      if (entry.amount > 0) {
        income += entry.amount;
      } else {
        expense -= entry.amount;
      }
    }
    return FinanceTotals(income: income, expense: expense);
  }
}
