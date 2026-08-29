import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/core/errors/game_rule_exception.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_branch.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_budget_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_branch_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_budget_service.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_employee_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_project_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_service.dart';
import 'package:kariyerden_sirkete/features/finance/domain/entities/finance_ledger.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  const budgetService = CompanyBudgetService();
  final employee = CompanyEmployeeCatalog.candidates.first.copyWith(
    morale: 50,
    burnout: 40,
  );

  test('daily limit forces tradeoffs between budget levels', () {
    var state = PlayerState.initial.copyWith(companyLevel: 1);
    for (final category in CompanyBudgetCategory.values) {
      state = budgetService.setLevel(state, category, CompanyBudgetLevel.low);
    }

    expect(budgetService.dailyBreakdown(state).total, 70);
    expect(budgetService.dailyLimit(state), 75);
    expect(
      () => budgetService.setLevel(
        state,
        CompanyBudgetCategory.research,
        CompanyBudgetLevel.medium,
      ),
      throwsA(isA<GameRuleException>()),
    );
    expect(
      () => budgetService.setLevel(
        PlayerState.initial,
        CompanyBudgetCategory.office,
        CompanyBudgetLevel.low,
      ),
      throwsA(isA<GameRuleException>()),
    );

    final oversized = PlayerState.initial.copyWith(
      companyLevel: 1,
      companyBudget: const CompanyBudgetState(
        office: CompanyBudgetLevel.high,
        marketing: CompanyBudgetLevel.high,
        research: CompanyBudgetLevel.high,
        maintenance: CompanyBudgetLevel.high,
      ),
    );
    expect(
      budgetService
          .setLevel(
            oversized,
            CompanyBudgetCategory.office,
            CompanyBudgetLevel.off,
          )
          .companyBudget
          .office,
      CompanyBudgetLevel.off,
    );
  });

  test(
    'daily budgets only debit company funds and use separate ledger rows',
    () {
      final state = PlayerState.initial.copyWith(
        money: 500,
        companyLevel: 1,
        companyFunds: 1000,
        employeeCount: 1,
        employees: [employee],
        companyBudget: const CompanyBudgetState(
          office: CompanyBudgetLevel.low,
          marketing: CompanyBudgetLevel.low,
          research: CompanyBudgetLevel.low,
          maintenance: CompanyBudgetLevel.low,
        ),
    );
    final service = CompanyService();
    final budget = budgetService.dailyBreakdown(state);
    final supportedState = budgetService.applyDailyHeadquartersOfficeEffect(
      state,
    );
    final expectedFunds =
        state.companyFunds +
        service.dailyRevenue(supportedState) -
        service.dailyPayroll(supportedState) -
        budget.total;

      final result = service.processDailyOperations(state).state;

      expect(result.money, state.money);
      expect(result.companyFunds, expectedFunds);
      expect(result.employees.single.morale, employee.morale + 1);
      expect(result.employees.single.burnout, employee.burnout - 1);
      final entries = result.financeLedger.forDay(
        state.day,
        account: FinanceAccount.company,
      );
      final expectedExpenses = {
        FinanceCategory.companyOfficeBudget: budget.office,
        FinanceCategory.companyMarketingBudget: budget.marketing,
        FinanceCategory.companyResearchBudget: budget.research,
        FinanceCategory.companyMaintenanceBudget: budget.maintenance,
      };
      for (final item in expectedExpenses.entries) {
        expect(
          entries.singleWhere((entry) => entry.category == item.key).amount,
          -item.value,
        );
      }
    },
  );

  test('marketing, research and maintenance produce bounded daily effects', () {
    final city = CityCatalog.cities.first;
    final branch = CompanyBranch(
      id: city.id,
      cityId: city.id,
      employees: [employee],
    );
    final base = PlayerState.initial.copyWith(
      companyLevel: 3,
      employeeCount: 1,
      employees: [employee],
      branches: [branch],
    );
    final funded = base.copyWith(
      companyBudget: const CompanyBudgetState(
        marketing: CompanyBudgetLevel.high,
        research: CompanyBudgetLevel.high,
        maintenance: CompanyBudgetLevel.high,
      ),
    );
    final companyService = CompanyService();
    final branchService = CompanyBranchService();
    final project = CompanyProjectCatalog.byId(base.activeProjectId);

    expect(
      companyService.dailyRevenue(funded),
      greaterThan(companyService.dailyRevenue(base)),
    );
    expect(
      branchService.dailyRevenueFor(funded, branch),
      greaterThan(branchService.dailyRevenueFor(base, branch)),
    );
    expect(
      companyService.projectForecast(funded, project).dailyProgress,
      companyService.projectForecast(base, project).dailyProgress + 3,
    );
  });

  test('legacy default budget has no expense or gameplay effect', () {
    final state = PlayerState.initial.copyWith(
      companyLevel: 1,
      companyFunds: 500,
      employeeCount: 1,
      employees: [employee],
    );
    final service = CompanyService();
    final result = service.processDailyOperations(state).state;

    expect(state.companyBudget.isDisabled, isTrue);
    expect(budgetService.dailyBreakdown(state).total, 0);
    expect(
      result.companyFunds,
      state.companyFunds +
          service.dailyRevenue(state) -
          service.dailyPayroll(state),
    );
    expect(
      result.financeLedger.entries.where(
        (entry) => entry.category.name.endsWith('Budget'),
      ),
      isEmpty,
    );
  });

  test('multi-day processing charges each configured budget once per day', () {
    final state = PlayerState.initial.copyWith(
      day: 3,
      companyLevel: 1,
      companyFunds: 100,
      companyBudget: const CompanyBudgetState(office: CompanyBudgetLevel.low),
    );

    final result = CompanyService()
        .processDailyOperations(state, days: 3)
        .state;
    final expenses = result.financeLedger.entries
        .where((entry) => entry.category == FinanceCategory.companyOfficeBudget)
        .toList();

    expect(result.companyFunds, 55);
    expect(expenses.map((entry) => entry.day), [1, 2, 3]);
    expect(expenses.map((entry) => entry.amount), [-15, -15, -15]);
    expect(
      expenses.every((entry) => entry.account == FinanceAccount.company),
      isTrue,
    );
  });

  test('branch office support is applied once before each branch workday', () {
    final city = CityCatalog.cities.first;
    final state = PlayerState.initial.copyWith(
      companyLevel: 1,
      branches: [
        CompanyBranch(
          id: city.id,
          cityId: city.id,
          employees: [employee],
        ),
      ],
      companyBudget: const CompanyBudgetState(
        office: CompanyBudgetLevel.high,
      ),
    );

    final result = CompanyBranchService()
        .processDailyOperations(state, days: 3)
        .state;
    final supported = result.branches.single.employees.single;

    expect(supported.morale, employee.morale + 9);
    expect(supported.burnout, employee.burnout - 9);
  });
}
