import '../../../../core/errors/game_rule_exception.dart';
import '../../../finance/domain/entities/finance_ledger.dart';
import '../../../game/domain/entities/player_state.dart';

class CompanyTreasuryCheck {
  const CompanyTreasuryCheck({required this.isEligible, required this.reason});

  final bool isEligible;
  final String reason;
}

class CompanyTreasuryService {
  static const minimumTransfer = 100;
  static const dividendTaxPercent = 10;

  static int dividendTax(int grossAmount) =>
      grossAmount * dividendTaxPercent ~/ 100;

  static int dividendNet(int grossAmount) =>
      grossAmount - dividendTax(grossAmount);

  CompanyTreasuryCheck checkCapital(PlayerState state, int amount) {
    final common = _checkCompanyAndAmount(state, amount);
    if (common != null) return common;
    if (state.money < amount) {
      return const CompanyTreasuryCheck(
        isEligible: false,
        reason: 'Kişisel cüzdanında yeterli para yok.',
      );
    }
    return const CompanyTreasuryCheck(
      isEligible: true,
      reason: 'Sermaye şirket kasasına aktarılabilir.',
    );
  }

  CompanyTreasuryCheck checkDividend(PlayerState state, int grossAmount) {
    final common = _checkCompanyAndAmount(state, grossAmount);
    if (common != null) return common;
    if (state.companyFunds < grossAmount) {
      return const CompanyTreasuryCheck(
        isEligible: false,
        reason: 'Şirket kasasında yeterli para yok.',
      );
    }
    return const CompanyTreasuryCheck(
      isEligible: true,
      reason: 'Kâr payı kişisel cüzdana aktarılabilir.',
    );
  }

  PlayerState addCapital(PlayerState state, int amount) {
    final check = checkCapital(state, amount);
    if (!check.isEligible) throw GameRuleException(check.reason);
    var ledger = state.financeLedger.record(
      day: state.day,
      category: FinanceCategory.companyCapital,
      amount: -amount,
    );
    ledger = ledger.record(
      day: state.day,
      category: FinanceCategory.companyCapital,
      amount: amount,
      account: FinanceAccount.company,
    );
    return state.copyWith(
      money: state.money - amount,
      companyFunds: state.companyFunds + amount,
      financeLedger: ledger,
    );
  }

  PlayerState withdrawDividend(PlayerState state, int grossAmount) {
    final check = checkDividend(state, grossAmount);
    if (!check.isEligible) throw GameRuleException(check.reason);
    final tax = dividendTax(grossAmount);
    var ledger = state.financeLedger.record(
      day: state.day,
      category: FinanceCategory.companyDividend,
      amount: -grossAmount,
      account: FinanceAccount.company,
    );
    ledger = ledger.record(
      day: state.day,
      category: FinanceCategory.companyDividend,
      amount: grossAmount,
    );
    ledger = ledger.record(
      day: state.day,
      category: FinanceCategory.dividendTax,
      amount: -tax,
    );
    return state.copyWith(
      money: state.money + dividendNet(grossAmount),
      companyFunds: state.companyFunds - grossAmount,
      financeLedger: ledger,
    );
  }

  CompanyTreasuryCheck? _checkCompanyAndAmount(PlayerState state, int amount) {
    if (state.companyLevel == 0) {
      return const CompanyTreasuryCheck(
        isEligible: false,
        reason: 'Önce şirketini kurmalısın.',
      );
    }
    if (amount < minimumTransfer) {
      return const CompanyTreasuryCheck(
        isEligible: false,
        reason: 'En az ₺100 aktarabilirsin.',
      );
    }
    return null;
  }
}
