import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../cities/domain/services/living_cost_service.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/finance_ledger.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Finans',
    subtitle: 'Gelirini, giderini ve yaşam standardını izle',
    child: AnimatedBuilder(
      animation: session,
      builder: (context, _) {
        final state = session.state;
        final costs = LivingCostService().breakdown(
          state,
          state.currentCityId,
        );
        final today = state.financeLedger.forDay(state.day).reversed.toList();
        final weekly = state.financeLedger.totals(
          fromDay: (state.day - 6).clamp(1, state.day),
          toDay: state.day,
        );
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            _ProjectionCard(costs: costs),
            const SizedBox(height: 24),
            AppSectionHeader(
              title: 'Bugünkü hareketler',
              caption: today.isEmpty
                  ? 'Henüz para hareketi oluşmadı.'
                  : '${today.length} kategori işlendi',
            ),
            const SizedBox(height: 12),
            if (today.isEmpty)
              const _EmptyHistory()
            else
              for (final entry in today) ...[
                _FinanceEntryTile(entry: entry),
                const SizedBox(height: 8),
              ],
            const SizedBox(height: 20),
            AppSectionHeader(
              title: 'Son 7 gün',
              caption:
                  'Gelir ₺${weekly.income} · Gider ₺${weekly.expense} · Net ${_signedMoney(weekly.net)}',
            ),
            const SizedBox(height: 12),
            for (var day = (state.day - 6).clamp(1, state.day);
                day <= state.day;
                day++) ...[
              _DailyFinanceRow(
                day: day,
                totals: state.financeLedger.totals(fromDay: day, toDay: day),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    ),
  );
}

class _ProjectionCard extends StatelessWidget {
  const _ProjectionCard({required this.costs});

  final LivingCostBreakdown costs;

  @override
  Widget build(BuildContext context) {
    final net = costs.rentalIncome - costs.totalExpenses;
    return AppInfoCard(
      accent: net >= 0 ? AppPalette.success : AppPalette.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GÜNLÜK SABİT BÜTÇE',
            style: TextStyle(
              color: AppPalette.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _signedMoney(net),
            style: TextStyle(
              color: net >= 0 ? AppPalette.success : AppPalette.warning,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '30 günlük sabit bütçe tahmini ${_signedMoney(net * 30)}',
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              AppPill(label: 'Konut ₺${costs.housing}'),
              AppPill(label: 'Yemek ₺${costs.food}'),
              AppPill(label: 'Fatura ₺${costs.utilities}'),
              AppPill(label: 'Ulaşım ₺${costs.transportation}'),
              if (costs.rentalMaintenance > 0)
                AppPill(
                  label: 'Ev bakımı ₺${costs.rentalMaintenance}',
                  color: AppPalette.warning,
                ),
              if (costs.rentalIncome > 0)
                AppPill(
                  label: 'Kira +₺${costs.rentalIncome}',
                  color: AppPalette.success,
                ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            'Yaşam düzeyi x${costs.lifestyleMultiplier.toStringAsFixed(2)} · Enflasyon x${costs.inflationMultiplier.toStringAsFixed(2)}',
            style: const TextStyle(color: AppPalette.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _FinanceEntryTile extends StatelessWidget {
  const _FinanceEntryTile({required this.entry});

  final FinanceEntry entry;

  @override
  Widget build(BuildContext context) {
    final income = entry.amount > 0;
    final color = income ? AppPalette.success : AppPalette.warning;
    return AppInfoCard(
      accent: color,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(entry.category.icon, color: color, size: 20),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              entry.category.label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            _signedMoney(entry.amount),
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _DailyFinanceRow extends StatelessWidget {
  const _DailyFinanceRow({required this.day, required this.totals});

  final int day;
  final FinanceTotals totals;

  @override
  Widget build(BuildContext context) => AppInfoCard(
    accent: totals.net >= 0 ? AppPalette.success : AppPalette.outline,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    child: Row(
      children: [
        SizedBox(
          width: 58,
          child: Text(
            'Gün $day',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            '+₺${totals.income}  -₺${totals.expense}',
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
        Text(
          _signedMoney(totals.net),
          style: TextStyle(
            color: totals.net >= 0 ? AppPalette.success : AppPalette.warning,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) => const AppInfoCard(
    accent: AppPalette.outline,
    child: Text(
      'Kazanç sağladığında veya bir ödeme yaptığında burada görünecek.',
      style: TextStyle(color: AppPalette.textMuted, fontSize: 12),
    ),
  );
}

String _signedMoney(int amount) =>
    '${amount >= 0 ? '+' : '-'}₺${amount.abs()}';

extension on FinanceCategory {
  String get label => switch (this) {
    FinanceCategory.casualIncome => 'Ek kazanç',
    FinanceCategory.salaryIncome => 'İş geliri',
    FinanceCategory.rentalIncome => 'Kira geliri',
    FinanceCategory.rewards => 'Hedef ve başarı ödülleri',
    FinanceCategory.assetPurchase => 'Varlık satın alımı',
    FinanceCategory.assetSale => 'Varlık satışı',
    FinanceCategory.training => 'Eğitim',
    FinanceCategory.relocation => 'Taşınma',
    FinanceCategory.housing => 'Konut gideri',
    FinanceCategory.food => 'Yemek ve içecek',
    FinanceCategory.utilities => 'Faturalar',
    FinanceCategory.transportation => 'Ulaşım',
    FinanceCategory.rentalMaintenance => 'Kiralık ev bakımı',
    FinanceCategory.wheel => 'Esnaf çarkı',
    FinanceCategory.companyInvestment => 'Şirket yatırımı',
  };

  IconData get icon => switch (this) {
    FinanceCategory.casualIncome => Icons.touch_app_outlined,
    FinanceCategory.salaryIncome => Icons.work_outline_rounded,
    FinanceCategory.rentalIncome => Icons.home_work_outlined,
    FinanceCategory.rewards => Icons.emoji_events_outlined,
    FinanceCategory.assetPurchase => Icons.shopping_cart_outlined,
    FinanceCategory.assetSale => Icons.sell_outlined,
    FinanceCategory.training => Icons.school_outlined,
    FinanceCategory.relocation => Icons.local_shipping_outlined,
    FinanceCategory.housing => Icons.home_outlined,
    FinanceCategory.food => Icons.restaurant_outlined,
    FinanceCategory.utilities => Icons.receipt_long_outlined,
    FinanceCategory.transportation => Icons.directions_bus_outlined,
    FinanceCategory.rentalMaintenance => Icons.home_repair_service_outlined,
    FinanceCategory.wheel => Icons.casino_outlined,
    FinanceCategory.companyInvestment => Icons.business_center_outlined,
  };
}
