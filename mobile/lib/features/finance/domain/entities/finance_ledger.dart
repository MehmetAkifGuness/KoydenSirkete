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
  companyOfficeBudget,
  companyMarketingBudget,
  companyResearchBudget,
  companyMaintenanceBudget,
  personalEvent,
  loan,
  loanPayment,
  investment,
  investmentReturn,
  hardshipSupport,
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

class FinanceLedgerSnapshot {
  const FinanceLedgerSnapshot({
    required this.personalEntriesByDay,
    required this.companyEntriesByDay,
    required this.personalTotalsByDay,
    required this.companyTotalsByDay,
    required this.personalTotal,
    required this.companyTotal,
  });

  final Map<int, List<FinanceEntry>> personalEntriesByDay;
  final Map<int, List<FinanceEntry>> companyEntriesByDay;
  final Map<int, FinanceTotals> personalTotalsByDay;
  final Map<int, FinanceTotals> companyTotalsByDay;
  final FinanceTotals personalTotal;
  final FinanceTotals companyTotal;

  List<FinanceEntry> entriesFor(int day, FinanceAccount account) =>
      (account == FinanceAccount.personal
          ? personalEntriesByDay[day]
          : companyEntriesByDay[day]) ??
      const [];

  FinanceTotals totalsFor(int day, FinanceAccount account) =>
      (account == FinanceAccount.personal
          ? personalTotalsByDay[day]
          : companyTotalsByDay[day]) ??
      const FinanceTotals(income: 0, expense: 0);
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
    if (!category.supports(account)) {
      throw ArgumentError.value(
        account,
        'account',
        '${category.name} işlemi bu hesaba kaydedilemez.',
      );
    }
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

  FinanceLedgerSnapshot snapshot({required int fromDay, required int toDay}) {
    final personalEntries = <int, List<FinanceEntry>>{};
    final companyEntries = <int, List<FinanceEntry>>{};
    final personalAmounts = <int, (int, int)>{};
    final companyAmounts = <int, (int, int)>{};
    var personalIncome = 0;
    var personalExpense = 0;
    var companyIncome = 0;
    var companyExpense = 0;
    for (final entry in entries) {
      if (entry.day < fromDay || entry.day > toDay) continue;
      final entryMap = entry.account == FinanceAccount.personal
          ? personalEntries
          : companyEntries;
      entryMap.putIfAbsent(entry.day, () => []).add(entry);
      final amountMap = entry.account == FinanceAccount.personal
          ? personalAmounts
          : companyAmounts;
      final current = amountMap[entry.day] ?? (0, 0);
      final income = entry.amount > 0 ? entry.amount : 0;
      final expense = entry.amount < 0 ? -entry.amount : 0;
      amountMap[entry.day] = (current.$1 + income, current.$2 + expense);
      if (entry.account == FinanceAccount.personal) {
        personalIncome += income;
        personalExpense += expense;
      } else {
        companyIncome += income;
        companyExpense += expense;
      }
    }
    Map<int, FinanceTotals> totalsOf(Map<int, (int, int)> source) => {
      for (final entry in source.entries)
        entry.key: FinanceTotals(
          income: entry.value.$1,
          expense: entry.value.$2,
        ),
    };
    return FinanceLedgerSnapshot(
      personalEntriesByDay: _freezeEntries(personalEntries),
      companyEntriesByDay: _freezeEntries(companyEntries),
      personalTotalsByDay: Map.unmodifiable(totalsOf(personalAmounts)),
      companyTotalsByDay: Map.unmodifiable(totalsOf(companyAmounts)),
      personalTotal: FinanceTotals(
        income: personalIncome,
        expense: personalExpense,
      ),
      companyTotal: FinanceTotals(
        income: companyIncome,
        expense: companyExpense,
      ),
    );
  }

  static Map<int, List<FinanceEntry>> _freezeEntries(
    Map<int, List<FinanceEntry>> source,
  ) => Map.unmodifiable({
    for (final entry in source.entries)
      entry.key: List<FinanceEntry>.unmodifiable(entry.value),
  });
}

extension FinanceCategoryAccount on FinanceCategory {
  bool supports(FinanceAccount account) {
    if (_transferCategories.contains(this)) return true;
    return account ==
        (_companyCategories.contains(this)
            ? FinanceAccount.company
            : FinanceAccount.personal);
  }

  static const _transferCategories = {
    FinanceCategory.companyInvestment,
    FinanceCategory.companyCapital,
    FinanceCategory.companyDividend,
  };

  static const _companyCategories = {
    FinanceCategory.companyRevenue,
    FinanceCategory.companyPayroll,
    FinanceCategory.companyProject,
    FinanceCategory.companyBranch,
    FinanceCategory.companyMarket,
    FinanceCategory.companySeason,
    FinanceCategory.companyDevelopment,
    FinanceCategory.companyExpansion,
    FinanceCategory.companyOfficeBudget,
    FinanceCategory.companyMarketingBudget,
    FinanceCategory.companyResearchBudget,
    FinanceCategory.companyMaintenanceBudget,
  };
}
