import 'dart:convert';

import '../../../finance/domain/entities/finance_ledger.dart';

class FinanceLedgerCodec {
  String encode(FinanceLedger ledger) => jsonEncode([
    for (final entry in ledger.entries)
      {
        'day': entry.day,
        'category': entry.category.name,
        'amount': entry.amount,
        'account': entry.account.name,
      },
  ]);

  FinanceLedger decode(String? value) {
    if (value == null || value.isEmpty) return const FinanceLedger();
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List) return const FinanceLedger();
      final entries = <FinanceEntry>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final categoryName = item['category'];
        final category = FinanceCategory.values.where(
          (candidate) => candidate.name == categoryName,
        );
        if (category.isEmpty) continue;
        final day = item['day'];
        final amount = item['amount'];
        final accountName = item['account'];
        final account = FinanceAccount.values.where(
          (candidate) => candidate.name == accountName,
        );
        if (day is! int || amount is! int || amount == 0) continue;
        entries.add(
          FinanceEntry(
            day: day,
            category: category.first,
            amount: amount,
            account: account.isEmpty ? FinanceAccount.personal : account.first,
          ),
        );
      }
      return FinanceLedger(entries: List<FinanceEntry>.unmodifiable(entries));
    } on FormatException {
      return const FinanceLedger();
    }
  }
}
