import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/finance/domain/entities/finance_ledger.dart';

void main() {
  test('büyük finans listesi tek geçişte hesap ve gün bazında özetlenir', () {
    final entries = List<FinanceEntry>.generate(100000, (index) {
      final company = index.isEven;
      return FinanceEntry(
        day: index % 30 + 1,
        category: company
            ? FinanceCategory.companyRevenue
            : FinanceCategory.salaryIncome,
        amount: index % 3 == 0 ? -10 : 20,
        account: company ? FinanceAccount.company : FinanceAccount.personal,
      );
    });
    final stopwatch = Stopwatch()..start();
    final snapshot = FinanceLedger(
      entries: entries,
    ).snapshot(fromDay: 1, toDay: 30);
    stopwatch.stop();

    expect(
      snapshot.personalEntriesByDay.values.fold<int>(
            0,
            (sum, items) => sum + items.length,
          ) +
          snapshot.companyEntriesByDay.values.fold<int>(
            0,
            (sum, items) => sum + items.length,
          ),
      entries.length,
    );
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
  });
}
