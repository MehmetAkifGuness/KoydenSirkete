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
    int? day,
    required int revenue,
    required int payroll,
    int officeBudget = 0,
    int marketingBudget = 0,
    int researchBudget = 0,
    int maintenanceBudget = 0,
  }) {
    final operationDay = day ?? state.day;
    var ledger = state.financeLedger.record(
      day: operationDay,
      category: FinanceCategory.companyRevenue,
      amount: revenue,
      account: FinanceAccount.company,
    );
    ledger = ledger.record(
      day: operationDay,
      category: FinanceCategory.companyPayroll,
      amount: -payroll,
      account: FinanceAccount.company,
    );
    ledger = ledger.record(
      day: operationDay,
      category: FinanceCategory.companyOfficeBudget,
      amount: -officeBudget,
      account: FinanceAccount.company,
    );
    ledger = ledger.record(
      day: operationDay,
      category: FinanceCategory.companyMarketingBudget,
      amount: -marketingBudget,
      account: FinanceAccount.company,
    );
    ledger = ledger.record(
      day: operationDay,
      category: FinanceCategory.companyResearchBudget,
      amount: -researchBudget,
      account: FinanceAccount.company,
    );
    ledger = ledger.record(
      day: operationDay,
      category: FinanceCategory.companyMaintenanceBudget,
      amount: -maintenanceBudget,
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
