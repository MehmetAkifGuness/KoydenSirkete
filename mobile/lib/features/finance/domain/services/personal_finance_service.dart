import '../../../../core/errors/game_rule_exception.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/finance_ledger.dart';
import '../entities/personal_finance_state.dart';

class PersonalFinanceService {
  static const loanTermDays = 30;
  static const loanInterestPercent = 12;
  static const loanCooldownDays = 15;
  static const minimumInvestment = 500;

  int creditLimit(PlayerState state) {
    final earnedLimit = state.totalEarned ~/ 4;
    final careerLimit = state.careerLevel * 2000;
    return (earnedLimit + careerLimit).clamp(2000, 20000).toInt();
  }

  PlayerState borrow(PlayerState state, int amount) {
    final finance = state.personalFinance;
    if (finance.hasDebt) {
      throw const GameRuleException('Önce mevcut kredini kapatmalısın.');
    }
    if (state.day - finance.lastLoanClosedDay < loanCooldownDays) {
      throw const GameRuleException('Yeni kredi için 15 gün beklemelisin.');
    }
    if (amount < 1000 || amount > creditLimit(state)) {
      throw GameRuleException(
        'Kredi 1.000 TL ile ${creditLimit(state)} TL arasında olmalı.',
      );
    }
    final totalDebt = (amount * (100 + loanInterestPercent) / 100).ceil();
    final dailyPayment = (totalDebt / loanTermDays).ceil();
    return state.copyWith(
      money: state.money + amount,
      personalFinance: finance.copyWith(
        debtPrincipal: amount,
        debtRemaining: totalDebt,
        dailyPayment: dailyPayment,
        loanDueDay: state.day + loanTermDays,
      ),
      financeLedger: state.financeLedger.record(
        day: state.day,
        category: FinanceCategory.loan,
        amount: amount,
      ),
    );
  }

  PlayerState repay(PlayerState state, int amount) {
    final finance = state.personalFinance;
    if (!finance.hasDebt) {
      throw const GameRuleException('Ödenecek kredi borcun yok.');
    }
    final payment = amount.clamp(1, finance.debtRemaining).toInt();
    if (state.money < payment) {
      throw const GameRuleException('Kişisel cüzdanda yeterli para yok.');
    }
    final remaining = finance.debtRemaining - payment;
    return state.copyWith(
      money: state.money - payment,
      personalFinance: finance.copyWith(
        debtPrincipal: remaining == 0 ? 0 : finance.debtPrincipal,
        debtRemaining: remaining,
        dailyPayment: remaining == 0 ? 0 : finance.dailyPayment,
        loanDueDay: remaining == 0 ? 0 : finance.loanDueDay,
        lastLoanClosedDay: remaining == 0
            ? state.day
            : finance.lastLoanClosedDay,
      ),
      financeLedger: state.financeLedger.record(
        day: state.day,
        category: FinanceCategory.loanPayment,
        amount: -payment,
      ),
    );
  }

  PlayerState invest(PlayerState state, int amount, InvestmentPlan plan) {
    if (state.personalFinance.hasInvestment) {
      throw const GameRuleException(
        'Aynı anda yalnızca bir yatırım açabilirsin.',
      );
    }
    final maximum = (state.money - 500).clamp(0, 50000).toInt();
    if (amount < minimumInvestment || amount > maximum) {
      throw GameRuleException(
        'Yatırım 500 TL ile $maximum TL arasında olmalı; 500 TL nakit yedek kalır.',
      );
    }
    return state.copyWith(
      money: state.money - amount,
      personalFinance: state.personalFinance.copyWith(
        investmentPrincipal: amount,
        investmentOpenedDay: state.day,
        investmentMaturityDay: state.day + plan.durationDays,
        investmentPlan: plan,
      ),
      financeLedger: state.financeLedger.record(
        day: state.day,
        category: FinanceCategory.investment,
        amount: -amount,
      ),
    );
  }

  PlayerState processDays(PlayerState state, int elapsedDays) {
    var next = state;
    final firstDay = state.day - elapsedDays + 1;
    for (var day = firstDay; day <= state.day; day++) {
      var finance = next.personalFinance;
      if (finance.hasDebt) {
        final payment = finance.dailyPayment
            .clamp(1, finance.debtRemaining)
            .toInt();
        final remaining = finance.debtRemaining - payment;
        next = next.copyWith(
          money: next.money - payment,
          personalFinance: finance.copyWith(
            debtPrincipal: remaining == 0 ? 0 : finance.debtPrincipal,
            debtRemaining: remaining,
            dailyPayment: remaining == 0 ? 0 : finance.dailyPayment,
            loanDueDay: remaining == 0 ? 0 : finance.loanDueDay,
            lastLoanClosedDay: remaining == 0 ? day : finance.lastLoanClosedDay,
          ),
          financeLedger: next.financeLedger.record(
            day: day,
            category: FinanceCategory.loanPayment,
            amount: -payment,
          ),
        );
      }
      finance = next.personalFinance;
      if (finance.hasInvestment && day >= finance.investmentMaturityDay) {
        final percent = _returnPercent(finance);
        final payout = finance.investmentPrincipal * (100 + percent) ~/ 100;
        next = next.copyWith(
          money: next.money + payout,
          personalFinance: finance.copyWith(clearInvestment: true),
          financeLedger: next.financeLedger.record(
            day: day,
            category: FinanceCategory.investmentReturn,
            amount: payout,
          ),
        );
      }
    }
    return next;
  }

  int _returnPercent(PersonalFinanceState finance) {
    final plan = finance.investmentPlan!;
    final seed =
        (finance.investmentOpenedDay * 31 +
            finance.investmentPrincipal * 17 +
            plan.index * 13) %
        100;
    if (seed < 25) return plan.lowReturnPercent;
    if (seed < 75) return plan.midReturnPercent;
    return plan.highReturnPercent;
  }
}
