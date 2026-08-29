import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/core/errors/game_rule_exception.dart';
import 'package:kariyerden_sirkete/features/finance/domain/entities/personal_finance_state.dart';
import 'package:kariyerden_sirkete/features/finance/domain/services/personal_finance_service.dart';
import 'package:kariyerden_sirkete/features/game/data/mappers/personal_finance_codec.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';

void main() {
  final service = PersonalFinanceService();

  test('loan has a bounded limit, fixed interest, and automatic payments', () {
    final state = PlayerState.initial.copyWith(
      money: 5000,
      careerLevel: 2,
      totalEarned: 8000,
    );

    final borrowed = service.borrow(state, 4000);

    expect(borrowed.money, 9000);
    expect(borrowed.personalFinance.debtRemaining, 4480);
    expect(borrowed.personalFinance.dailyPayment, 150);
    expect(
      () => service.borrow(borrowed, 1000),
      throwsA(isA<GameRuleException>()),
    );

    final settled = service.processDays(borrowed.copyWith(day: 31), 30);
    expect(settled.personalFinance.hasDebt, isFalse);
    expect(settled.money, 4520);
    expect(settled.personalFinance.lastLoanClosedDay, 31);
  });

  test('early repayment enforces cooldown to prevent loan cycling', () {
    final borrowed = service.borrow(
      PlayerState.initial.copyWith(money: 5000, careerLevel: 2),
      2000,
    );
    final repaid = service.repay(
      borrowed,
      borrowed.personalFinance.debtRemaining,
    );

    expect(repaid.personalFinance.hasDebt, isFalse);
    expect(
      () => service.borrow(repaid, 1000),
      throwsA(isA<GameRuleException>()),
    );
  });

  test('investment locks principal and pays deterministic maturity return', () {
    final invested = service.invest(
      PlayerState.initial.copyWith(money: 2000),
      1000,
      InvestmentPlan.protected,
    );

    expect(invested.money, 1000);
    expect(invested.personalFinance.hasInvestment, isTrue);
    expect(
      () => service.invest(invested, 500, InvestmentPlan.growth),
      throwsA(isA<GameRuleException>()),
    );

    final matured = service.processDays(invested.copyWith(day: 16), 15);
    expect(matured.money, 2040);
    expect(matured.personalFinance.hasInvestment, isFalse);
  });

  test('personal finance codec persists debt and investment state', () {
    const value = PersonalFinanceState(
      debtPrincipal: 2000,
      debtRemaining: 1800,
      dailyPayment: 75,
      loanDueDay: 40,
      investmentPrincipal: 1000,
      investmentOpenedDay: 2,
      investmentMaturityDay: 32,
      investmentPlan: InvestmentPlan.balanced,
    );

    final actual = const PersonalFinanceCodec().decode(
      const PersonalFinanceCodec().encode(value),
    );

    expect(actual.debtRemaining, 1800);
    expect(actual.investmentPlan, InvestmentPlan.balanced);
    expect(actual.investmentMaturityDay, 32);
  });
}
