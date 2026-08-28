enum FinanceAccount { personal, company }

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
  companyCapital,
  companyDividend,
  dividendTax,
  companyRevenue,
  companyPayroll,
  companyProject,
  companyBranch,
  companyMarket,
  companySeason,
  companyDevelopment,
  companyExpansion,
}

class FinanceEntry {
  const FinanceEntry({
    required this.day,
    required this.category,
    required this.amount,
    this.account = FinanceAccount.personal,
  });

  final int day;
  final FinanceCategory category;
  final int amount;
  final FinanceAccount account;
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
    FinanceAccount account = FinanceAccount.personal,
  }) {
    if (amount == 0) return this;
    final firstRetainedDay = day - retainedDays + 1;
    final next = <FinanceEntry>[];
    var merged = false;
    for (final entry in entries) {
      if (entry.day < firstRetainedDay) continue;
      if (entry.day == day &&
          entry.category == category &&
          entry.account == account) {
        final mergedAmount = entry.amount + amount;
        if (mergedAmount != 0) {
          next.add(
            FinanceEntry(
              day: day,
              category: category,
              amount: mergedAmount,
              account: account,
            ),
          );
        }
        merged = true;
      } else {
        next.add(entry);
      }
    }
    if (!merged) {
      next.add(
        FinanceEntry(
          day: day,
          category: category,
          amount: amount,
          account: account,
        ),
      );
    }
    next.sort((left, right) {
      final dayOrder = left.day.compareTo(right.day);
      return dayOrder != 0
          ? dayOrder
          : left.category.index != right.category.index
          ? left.category.index.compareTo(right.category.index)
          : left.account.index.compareTo(right.account.index);
    });
    return FinanceLedger(entries: List<FinanceEntry>.unmodifiable(next));
  }

  List<FinanceEntry> forDay(int day, {FinanceAccount? account}) => entries
      .where(
        (entry) =>
            entry.day == day && (account == null || entry.account == account),
      )
      .toList(growable: false);

  FinanceTotals totals({
    required int fromDay,
    required int toDay,
    FinanceAccount? account,
  }) {
    var income = 0;
    var expense = 0;
    for (final entry in entries) {
      if (entry.day < fromDay || entry.day > toDay) continue;
      if (account != null && entry.account != account) continue;
      if (entry.amount > 0) {
        income += entry.amount;
      } else {
        expense -= entry.amount;
      }
    }
    return FinanceTotals(income: income, expense: expense);
  }
}
