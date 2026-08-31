import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/game_account_bar.dart';
import '../../../cities/domain/services/living_cost_service.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/finance_ledger.dart';
import '../../domain/entities/personal_finance_state.dart';
import '../../domain/services/personal_finance_service.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({required this.session, this.onSectionOpened, super.key});

  final GameSessionController session;
  final ValueChanged<String>? onSectionOpened;

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Finans',
    subtitle: 'Gelirini, giderini ve yaşam standardını izle',
    child: AnimatedBuilder(
      animation: session,
      builder: (context, _) {
        final state = session.state;
        final costs = LivingCostService().breakdown(state, state.currentCityId);
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            _AccountBalances(
              personal: state.money,
              company: state.companyFunds,
            ),
            const SizedBox(height: 12),
            _ProjectionCard(costs: costs),
            const SizedBox(height: 22),
            const AppSectionHeader(
              title: 'Finans alanları',
              caption: 'İhtiyacın olan rapora veya işleme doğrudan git.',
            ),
            const SizedBox(height: 12),
            AppSubpageCard(
              icon: Icons.receipt_long_outlined,
              title: 'Bugünkü hareketler',
              subtitle: 'Kişisel cüzdan ve şirket kasası işlemleri.',
              onTap: () => _open(context, _FinanceSection.movements),
            ),
            const SizedBox(height: 10),
            AppSubpageCard(
              icon: Icons.account_balance_outlined,
              title: 'Kredi ve yatırım',
              subtitle: 'Borçlanma, erken ödeme ve yatırım planları.',
              color: AppPalette.secondary,
              onTap: () => _open(context, _FinanceSection.personalFinance),
            ),
            const SizedBox(height: 10),
            AppSubpageCard(
              icon: Icons.analytics_outlined,
              title: '7 günlük özet',
              subtitle: 'Gelir, gider ve net değişimi gün gün karşılaştır.',
              color: AppPalette.tertiary,
              onTap: () => _open(context, _FinanceSection.history),
            ),
          ],
        );
      },
    ),
  );

  void _open(BuildContext context, _FinanceSection section) {
    onSectionOpened?.call(section.name);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameAccountRoute(
          session: session,
          child: _FinanceSectionPage(session: session, section: section),
        ),
      ),
    );
  }
}

enum _FinanceSection { movements, personalFinance, history }

class _FinanceSectionPage extends StatelessWidget {
  const _FinanceSectionPage({required this.session, required this.section});

  final GameSessionController session;
  final _FinanceSection section;

  @override
  Widget build(BuildContext context) => AppPage(
    title: switch (section) {
      _FinanceSection.movements => 'Bugünkü hareketler',
      _FinanceSection.personalFinance => 'Kredi ve yatırım',
      _FinanceSection.history => '7 günlük özet',
    },
    subtitle: switch (section) {
      _FinanceSection.movements => 'Hesap hareketlerini ayrı ayrı incele',
      _FinanceSection.personalFinance => 'Kişisel finans kararlarını yönet',
      _FinanceSection.history => 'Gelir ve gider eğilimini karşılaştır',
    },
    child: AnimatedBuilder(
      animation: session,
      builder: (context, _) {
        final state = session.state;
        final firstDay = (state.day - 6).clamp(1, state.day);
        final snapshot = state.financeLedger.snapshot(
          fromDay: firstDay,
          toDay: state.day,
        );
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: switch (section) {
            _FinanceSection.movements => [
              _AccountHistory(
                title: 'Kişisel hareketler',
                caption: 'Maaş, yaşam giderleri ve kişisel varlıklar',
                entries: snapshot
                    .entriesFor(state.day, FinanceAccount.personal)
                    .reversed
                    .toList(growable: false),
              ),
              const SizedBox(height: 22),
              _AccountHistory(
                title: 'Şirket hareketleri',
                caption: 'Projeler, maaşlar, bütçeler ve piyasa etkileri',
                entries: snapshot
                    .entriesFor(state.day, FinanceAccount.company)
                    .reversed
                    .toList(growable: false),
              ),
            ],
            _FinanceSection.personalFinance => [
              _PersonalFinancePanel(session: session),
            ],
            _FinanceSection.history => [
              AppSectionHeader(
                title: 'Son 7 gün',
                caption:
                    'Kişisel ${_signedMoney(snapshot.personalTotal.net)} · Şirket ${_signedMoney(snapshot.companyTotal.net)}',
              ),
              const SizedBox(height: 12),
              for (var day = firstDay; day <= state.day; day++) ...[
                _DailyFinanceRow(
                  day: day,
                  personal: snapshot.totalsFor(day, FinanceAccount.personal),
                  company: snapshot.totalsFor(day, FinanceAccount.company),
                ),
                const SizedBox(height: 8),
              ],
            ],
          },
        );
      },
    ),
  );
}

class _PersonalFinancePanel extends StatelessWidget {
  const _PersonalFinancePanel({required this.session});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final state = session.state;
    final finance = state.personalFinance;
    final creditLimit = session.creditLimit;
    final investmentAmount = (state.money - 500).clamp(0, 5000).toInt();
    return AppInfoCard(
      accent: AppPalette.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KREDİ VE YATIRIM',
            style: TextStyle(
              color: AppPalette.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          if (finance.hasDebt) ...[
            Text(
              'Kalan borç ₺${finance.debtRemaining} · Günlük ₺${finance.dailyPayment} · Son gün ${finance.loanDueDay}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: session.isBusy
                  ? null
                  : () =>
                        _run(context, session.repayLoan(finance.debtRemaining)),
              child: const Text('Borcu erken kapat'),
            ),
          ] else ...[
            Text(
              '₺$creditLimit kredi · 30 gün · toplam %${PersonalFinanceService.loanInterestPercent} faiz',
              style: const TextStyle(
                color: AppPalette.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: session.isBusy
                  ? null
                  : () => _run(context, session.borrow(creditLimit)),
              child: const Text('Kredi kullan'),
            ),
          ],
          const Divider(height: 24),
          if (finance.hasInvestment)
            Text(
              '${finance.investmentPlan!.label}: ₺${finance.investmentPrincipal} · vade günü ${finance.investmentMaturityDay}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            )
          else ...[
            Text(
              investmentAmount >= PersonalFinanceService.minimumInvestment
                  ? 'Yatırım tutarı ₺$investmentAmount · en az ₺500 nakit korunur'
                  : 'Yatırım için en az ₺1.000 kişisel bakiye gerekir.',
              style: const TextStyle(
                color: AppPalette.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final plan in InvestmentPlan.values)
                  OutlinedButton(
                    onPressed:
                        session.isBusy ||
                            investmentAmount <
                                PersonalFinanceService.minimumInvestment
                        ? null
                        : () => _run(
                            context,
                            session.invest(investmentAmount, plan),
                          ),
                    child: Text(
                      '${plan.label} · ${plan.durationDays}g · ${plan.riskLabel}',
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _run(BuildContext context, Future<String?> action) async {
    final message = await action;
    if (message != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _AccountBalances extends StatelessWidget {
  const _AccountBalances({required this.personal, required this.company});

  final int personal;
  final int company;

  @override
  Widget build(BuildContext context) => AppInfoCard(
    accent: AppPalette.secondary,
    child: Row(
      children: [
        Expanded(
          child: _BalanceColumn(
            title: 'Kişisel cüzdan',
            amount: personal,
            color: AppPalette.secondary,
          ),
        ),
        Container(width: 1, height: 44, color: AppPalette.outlineMuted),
        const SizedBox(width: 14),
        Expanded(
          child: _BalanceColumn(
            title: 'Şirket kasası',
            amount: company,
            color: AppPalette.tertiary,
          ),
        ),
      ],
    ),
  );
}

class _BalanceColumn extends StatelessWidget {
  const _BalanceColumn({
    required this.title,
    required this.amount,
    required this.color,
  });

  final String title;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(color: AppPalette.textMuted, fontSize: 10),
      ),
      const SizedBox(height: 4),
      Text(
        '₺$amount',
        style: TextStyle(
          color: color,
          fontSize: 19,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}

class _AccountHistory extends StatelessWidget {
  const _AccountHistory({
    required this.title,
    required this.caption,
    required this.entries,
  });

  final String title;
  final String caption;
  final List<FinanceEntry> entries;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppSectionHeader(title: title, caption: caption),
      const SizedBox(height: 12),
      if (entries.isEmpty)
        const _EmptyHistory()
      else
        for (final entry in entries) ...[
          _FinanceEntryTile(entry: entry),
          const SizedBox(height: 8),
        ],
    ],
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
            'Yaşam düzeyi x${AppFormatters.decimal(costs.lifestyleMultiplier)} · Enflasyon x${AppFormatters.decimal(costs.inflationMultiplier)}',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.category.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.account == FinanceAccount.personal ? "Kişisel cüzdan" : "Şirket kasası"} · ${income ? "giriş nedeni" : "çıkış nedeni"}: ${entry.category.label}',
                  style: const TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
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
  const _DailyFinanceRow({
    required this.day,
    required this.personal,
    required this.company,
  });

  final int day;
  final FinanceTotals personal;
  final FinanceTotals company;

  @override
  Widget build(BuildContext context) => AppInfoCard(
    accent: personal.net + company.net >= 0
        ? AppPalette.success
        : AppPalette.outline,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kişisel ${_signedMoney(personal.net)}',
                style: const TextStyle(
                  color: AppPalette.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Şirket ${_signedMoney(company.net)}',
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Text(
          _signedMoney(personal.net + company.net),
          style: TextStyle(
            color: personal.net + company.net >= 0
                ? AppPalette.success
                : AppPalette.warning,
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

String _signedMoney(int amount) => '${amount >= 0 ? '+' : '-'}₺${amount.abs()}';

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
    FinanceCategory.companyCapital => 'Sermaye aktarımı',
    FinanceCategory.companyDividend => 'Kâr payı',
    FinanceCategory.dividendTax => 'Kâr payı vergisi',
    FinanceCategory.companyRevenue => 'Şirket operasyon geliri',
    FinanceCategory.companyPayroll => 'Çalışan maaşları',
    FinanceCategory.companyProject => 'Proje sonucu',
    FinanceCategory.companyBranch => 'Bayi operasyonları',
    FinanceCategory.companyMarket => 'Piyasa ve rekabet',
    FinanceCategory.companySeason => 'Rekabet sezonu ödülü',
    FinanceCategory.companyDevelopment => 'Çalışan gelişimi',
    FinanceCategory.companyExpansion => 'Satın alma ve birleşme',
    FinanceCategory.companyOfficeBudget => 'Ofis bütçesi',
    FinanceCategory.companyMarketingBudget => 'Pazarlama bütçesi',
    FinanceCategory.companyResearchBudget => 'Ar-Ge bütçesi',
    FinanceCategory.companyMaintenanceBudget => 'Bakım bütçesi',
    FinanceCategory.personalEvent => 'Kişisel olay',
    FinanceCategory.loan => 'Kredi kullanımı',
    FinanceCategory.loanPayment => 'Kredi geri ödemesi',
    FinanceCategory.investment => 'Yatırım alımı',
    FinanceCategory.investmentReturn => 'Yatırım vade getirisi',
    FinanceCategory.hardshipSupport => 'Geçim desteği',
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
    FinanceCategory.companyCapital => Icons.swap_horiz_rounded,
    FinanceCategory.companyDividend => Icons.savings_outlined,
    FinanceCategory.dividendTax => Icons.account_balance_outlined,
    FinanceCategory.companyRevenue => Icons.trending_up_rounded,
    FinanceCategory.companyPayroll => Icons.groups_outlined,
    FinanceCategory.companyProject => Icons.assignment_turned_in_outlined,
    FinanceCategory.companyBranch => Icons.storefront_outlined,
    FinanceCategory.companyMarket => Icons.show_chart_rounded,
    FinanceCategory.companySeason => Icons.emoji_events_outlined,
    FinanceCategory.companyDevelopment => Icons.school_outlined,
    FinanceCategory.companyExpansion => Icons.handshake_outlined,
    FinanceCategory.companyOfficeBudget => Icons.apartment_outlined,
    FinanceCategory.companyMarketingBudget => Icons.campaign_outlined,
    FinanceCategory.companyResearchBudget => Icons.science_outlined,
    FinanceCategory.companyMaintenanceBudget => Icons.build_outlined,
    FinanceCategory.personalEvent => Icons.bolt_outlined,
    FinanceCategory.loan => Icons.account_balance_outlined,
    FinanceCategory.loanPayment => Icons.payments_outlined,
    FinanceCategory.investment => Icons.trending_up_outlined,
    FinanceCategory.investmentReturn => Icons.savings_outlined,
    FinanceCategory.hardshipSupport => Icons.health_and_safety_outlined,
  };
}

extension on InvestmentPlan {
  String get riskLabel => switch (this) {
    InvestmentPlan.protected => 'kesin +%4',
    InvestmentPlan.balanced => '%25: -%5 · %50: +%10 · %25: +%18',
    InvestmentPlan.growth => '%25: -%20 · %50: +%15 · %25: +%35',
  };
}
