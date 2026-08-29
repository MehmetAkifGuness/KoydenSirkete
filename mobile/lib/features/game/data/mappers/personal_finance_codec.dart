import 'dart:convert';

import '../../../finance/domain/entities/personal_finance_state.dart';

class PersonalFinanceCodec {
  const PersonalFinanceCodec();

  String encode(PersonalFinanceState state) => jsonEncode({
    'debtPrincipal': state.debtPrincipal,
    'debtRemaining': state.debtRemaining,
    'dailyPayment': state.dailyPayment,
    'loanDueDay': state.loanDueDay,
    'lastLoanClosedDay': state.lastLoanClosedDay,
    'investmentPrincipal': state.investmentPrincipal,
    'investmentOpenedDay': state.investmentOpenedDay,
    'investmentMaturityDay': state.investmentMaturityDay,
    'investmentPlan': state.investmentPlan?.name,
  });

  PersonalFinanceState decode(String? value) {
    if (value == null || value.isEmpty) return const PersonalFinanceState();
    try {
      final json = jsonDecode(value);
      if (json is! Map) return const PersonalFinanceState();
      final planName = json['investmentPlan'];
      final plans = InvestmentPlan.values.where((p) => p.name == planName);
      int read(String key, [int fallback = 0]) =>
          json[key] is int ? json[key] as int : fallback;
      return PersonalFinanceState(
        debtPrincipal: read('debtPrincipal'),
        debtRemaining: read('debtRemaining'),
        dailyPayment: read('dailyPayment'),
        loanDueDay: read('loanDueDay'),
        lastLoanClosedDay: read('lastLoanClosedDay', -30),
        investmentPrincipal: read('investmentPrincipal'),
        investmentOpenedDay: read('investmentOpenedDay'),
        investmentMaturityDay: read('investmentMaturityDay'),
        investmentPlan: plans.isEmpty ? null : plans.first,
      );
    } on FormatException {
      return const PersonalFinanceState();
    }
  }
}
