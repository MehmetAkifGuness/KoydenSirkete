enum InvestmentPlan {
  protected('Korunan mevduat', 15, 4, 4, 4),
  balanced('Dengeli fon', 30, -5, 10, 18),
  growth('Büyüme fonu', 45, -20, 15, 35);

  const InvestmentPlan(
    this.label,
    this.durationDays,
    this.lowReturnPercent,
    this.midReturnPercent,
    this.highReturnPercent,
  );

  final String label;
  final int durationDays;
  final int lowReturnPercent;
  final int midReturnPercent;
  final int highReturnPercent;
}

class PersonalFinanceState {
  const PersonalFinanceState({
    this.debtPrincipal = 0,
    this.debtRemaining = 0,
    this.dailyPayment = 0,
    this.loanDueDay = 0,
    this.lastLoanClosedDay = -30,
    this.investmentPrincipal = 0,
    this.investmentOpenedDay = 0,
    this.investmentMaturityDay = 0,
    this.investmentPlan,
  });

  final int debtPrincipal;
  final int debtRemaining;
  final int dailyPayment;
  final int loanDueDay;
  final int lastLoanClosedDay;
  final int investmentPrincipal;
  final int investmentOpenedDay;
  final int investmentMaturityDay;
  final InvestmentPlan? investmentPlan;

  bool get hasDebt => debtRemaining > 0;
  bool get hasInvestment => investmentPrincipal > 0 && investmentPlan != null;

  PersonalFinanceState copyWith({
    int? debtPrincipal,
    int? debtRemaining,
    int? dailyPayment,
    int? loanDueDay,
    int? lastLoanClosedDay,
    int? investmentPrincipal,
    int? investmentOpenedDay,
    int? investmentMaturityDay,
    InvestmentPlan? investmentPlan,
    bool clearInvestment = false,
  }) => PersonalFinanceState(
    debtPrincipal: debtPrincipal ?? this.debtPrincipal,
    debtRemaining: debtRemaining ?? this.debtRemaining,
    dailyPayment: dailyPayment ?? this.dailyPayment,
    loanDueDay: loanDueDay ?? this.loanDueDay,
    lastLoanClosedDay: lastLoanClosedDay ?? this.lastLoanClosedDay,
    investmentPrincipal: clearInvestment
        ? 0
        : investmentPrincipal ?? this.investmentPrincipal,
    investmentOpenedDay: clearInvestment
        ? 0
        : investmentOpenedDay ?? this.investmentOpenedDay,
    investmentMaturityDay: clearInvestment
        ? 0
        : investmentMaturityDay ?? this.investmentMaturityDay,
    investmentPlan: clearInvestment
        ? null
        : investmentPlan ?? this.investmentPlan,
  );
}
