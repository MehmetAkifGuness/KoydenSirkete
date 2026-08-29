import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/company_budget_state.dart';
import '../../domain/services/company_budget_service.dart';

class CompanyBudgetPanel extends StatelessWidget {
  const CompanyBudgetPanel({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    const service = CompanyBudgetService();
    final state = session.state;
    final breakdown = service.dailyBreakdown(state);
    final limit = service.dailyLimit(state);
    final usage = limit == 0 ? 0.0 : breakdown.total / limit;
    return AppInfoCard(
      accent: AppPalette.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ŞİRKET BÜTÇELERİ',
            style: TextStyle(
              color: AppPalette.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Günlük ₺${breakdown.total} / ₺$limit',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Semantics(
            label: 'Günlük şirket bütçesi kullanım oranı',
            value: '%${(usage * 100).round()}',
            child: LinearProgressIndicator(
              value: usage.clamp(0, 1),
              minHeight: 7,
              color: AppPalette.secondary,
              backgroundColor: AppPalette.track,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Seçimler ücretsizdir; giderler her oyun günü yalnızca şirket kasasından kesilir.',
            style: TextStyle(color: AppPalette.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 15),
          for (final category in CompanyBudgetCategory.values) ...[
            _BudgetRow(
              category: category,
              selected: state.companyBudget.levelFor(category),
              dailyCost: breakdown.costFor(category),
              effect: service.effectFor(
                category,
                state.companyBudget.levelFor(category),
              ),
              enabled: !session.isBusy,
              onSelected: (level) => _setLevel(context, category, level),
            ),
            if (category != CompanyBudgetCategory.values.last)
              const Divider(height: 25, color: AppPalette.outlineMuted),
          ],
        ],
      ),
    );
  }

  Future<void> _setLevel(
    BuildContext context,
    CompanyBudgetCategory category,
    CompanyBudgetLevel level,
  ) async {
    if (session.state.companyBudget.levelFor(category) == level) return;
    final message = await session.setCompanyBudgetLevel(category, level);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.category,
    required this.selected,
    required this.dailyCost,
    required this.effect,
    required this.enabled,
    required this.onSelected,
  });

  final CompanyBudgetCategory category;
  final CompanyBudgetLevel selected;
  final int dailyCost;
  final String effect;
  final bool enabled;
  final ValueChanged<CompanyBudgetLevel> onSelected;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(category.icon, color: AppPalette.secondary, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              category.label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            '₺$dailyCost/gün',
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        effect,
        style: const TextStyle(color: AppPalette.textMuted, fontSize: 11),
      ),
      const SizedBox(height: 9),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final level in CompanyBudgetLevel.values)
            Semantics(
              label: '${category.label} bütçesi: ${level.label}',
              button: true,
              selected: selected == level,
              excludeSemantics: true,
              child: ChoiceChip(
                key: ValueKey(
                  'company-budget-${category.name}-${level.name}',
                ),
                label: Text(level.label),
                selected: selected == level,
                onSelected: enabled ? (_) => onSelected(level) : null,
              ),
            ),
        ],
      ),
    ],
  );
}

extension on CompanyBudgetCategory {
  IconData get icon => switch (this) {
    CompanyBudgetCategory.office => Icons.apartment_outlined,
    CompanyBudgetCategory.marketing => Icons.campaign_outlined,
    CompanyBudgetCategory.research => Icons.science_outlined,
    CompanyBudgetCategory.maintenance => Icons.build_outlined,
  };
}
