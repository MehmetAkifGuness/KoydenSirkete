import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../core/input/bounded_integer_input_formatter.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/app_transaction_preview.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/services/company_treasury_service.dart';

enum _TreasuryAction { addCapital, withdrawDividend }

const _largeTransferThreshold = 10000;

class CompanyTreasuryPanel extends StatelessWidget {
  const CompanyTreasuryPanel({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final state = session.state;
    return AppInfoCard(
      accent: AppPalette.tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HESAPLAR ARASI AKTARIM',
            style: TextStyle(
              color: AppPalette.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _BalanceTile(
                  title: 'Kişisel cüzdan',
                  amount: state.money,
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppPalette.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BalanceTile(
                  title: 'Şirket kasası',
                  amount: state.companyFunds,
                  icon: Icons.business_center_outlined,
                  color: AppPalette.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed:
                      state.money >= CompanyTreasuryService.minimumTransfer &&
                          !session.isBusy
                      ? () => _open(context, _TreasuryAction.addCapital)
                      : null,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                  label: const Text('Sermaye aktar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      state.companyFunds >=
                              CompanyTreasuryService.minimumTransfer &&
                          !session.isBusy
                      ? () => _open(context, _TreasuryAction.withdrawDividend)
                      : null,
                  icon: const Icon(Icons.savings_outlined, size: 17),
                  label: const Text('Kâr payı çek'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            'Kâr payında %10 vergi kesilir. Şirket işlemleri yalnızca şirket kasasını kullanır.',
            style: TextStyle(color: AppPalette.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, _TreasuryAction action) async {
    final available = action == _TreasuryAction.addCapital
        ? session.state.money
        : session.state.companyFunds;
    final amount = await showDialog<int>(
      context: context,
      builder: (_) => _TreasuryAmountDialog(
        action: action,
        available: math.max(0, available),
      ),
    );
    if (amount == null || !context.mounted) return;
    if (amount >= _largeTransferThreshold) {
      final dividend = action == _TreasuryAction.withdrawDividend;
      final confirmed = await showAppConfirmation(
        context,
        title: 'Büyük para transferini onayla',
        summary: Text(
          dividend
              ? 'Şirket kasasından -₺$amount; kişisel cüzdana vergi sonrası +₺${CompanyTreasuryService.dividendNet(amount)}.'
              : 'Kişisel cüzdandan -₺$amount; şirket kasasına +₺$amount sermaye.',
        ),
        confirmLabel: 'Transferi yap',
        irreversibleWarning: 'Tamamlanan transfer otomatik geri alınamaz.',
      );
      if (!confirmed || !context.mounted) return;
    }
    final message = action == _TreasuryAction.addCapital
        ? await session.addCompanyCapital(amount)
        : await session.withdrawCompanyDividend(amount);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _BalanceTile extends StatelessWidget {
  const _BalanceTile({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final int amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: .24)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(color: AppPalette.textMuted, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          '₺$amount',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ],
    ),
  );
}

class _TreasuryAmountDialog extends StatefulWidget {
  const _TreasuryAmountDialog({required this.action, required this.available});

  final _TreasuryAction action;
  final int available;

  @override
  State<_TreasuryAmountDialog> createState() => _TreasuryAmountDialogState();
}

class _TreasuryAmountDialogState extends State<_TreasuryAmountDialog> {
  late final TextEditingController _controller;

  int get _amount => int.tryParse(_controller.text) ?? 0;
  bool get _isValid =>
      _amount >= CompanyTreasuryService.minimumTransfer &&
      _amount <= widget.available;

  @override
  void initState() {
    super.initState();
    final initial = math.min(1000, widget.available);
    _controller = TextEditingController(
      text: initial >= CompanyTreasuryService.minimumTransfer ? '$initial' : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dividend = widget.action == _TreasuryAction.withdrawDividend;
    final tax = CompanyTreasuryService.dividendTax(_amount);
    return AlertDialog(
      title: Text(dividend ? 'Kâr payı çek' : 'Şirkete sermaye aktar'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${dividend ? "Şirket kasası → kişisel cüzdan" : "Kişisel cüzdan → şirket kasası"}\n'
            'Kullanılabilir bakiye: ₺${widget.available}',
            style: const TextStyle(color: AppPalette.textSecondary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              BoundedIntegerInputFormatter(maximum: widget.available),
            ],
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Tutar',
              prefixText: '₺',
              helperText: 'En az ₺100 · ₺10.000 ve üzeri ayrıca onaylanır',
            ),
          ),
          if (dividend && _amount > 0) ...[
            const SizedBox(height: 11),
            Text(
              'Vergi ₺$tax · Cüzdana net ₺${CompanyTreasuryService.dividendNet(_amount)}',
              style: const TextStyle(
                color: AppPalette.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: _isValid ? () => Navigator.pop(context, _amount) : null,
          child: const Text('Aktar'),
        ),
      ],
    );
  }
}
