import '../../../finance/domain/entities/finance_ledger.dart';
import '../../../game/domain/entities/player_state.dart';

abstract final class CompanyFinanceRecorder {
  static FinanceLedger record(
    PlayerState state,
    FinanceCategory category,
    int amount,
  ) => state.financeLedger.record(
    day: state.day,
    category: category,
    amount: amount,
    account: FinanceAccount.company,
  );

  static FinanceLedger recordDailyOperations(
    PlayerState state, {
    required int revenue,
    required int payroll,
  }) {
    var ledger = record(state, FinanceCategory.companyRevenue, revenue);
    ledger = ledger.record(
      day: state.day,
      category: FinanceCategory.companyPayroll,
      amount: -payroll,
      account: FinanceAccount.company,
    );
    return ledger;
  }

  static FinanceLedger recordEstablishment(
    PlayerState state, {
    required int cost,
    required int initialFunds,
  }) {
    var ledger = state.financeLedger.record(
      day: state.day,
      category: FinanceCategory.companyInvestment,
      amount: -cost,
    );
    ledger = ledger.record(
      day: state.day,
      category: FinanceCategory.companyCapital,
      amount: initialFunds,
      account: FinanceAccount.company,
    );
    return ledger;
  }
}
