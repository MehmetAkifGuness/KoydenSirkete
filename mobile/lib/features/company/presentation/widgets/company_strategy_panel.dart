import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/company_competition_strategy.dart';
import '../../domain/services/company_competition_strategy_service.dart';
import '../../domain/services/company_market_service.dart';

class CompanyStrategyPanel extends StatelessWidget {
  const CompanyStrategyPanel({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final state = session.state;
    final service = const CompanyCompetitionStrategyService();
    final selected = service.selectedFor(state);
    final competitor = CompanyMarketService().forecast(state).competitor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Rekabet stratejisi',
          caption: selected.isSelected
              ? '${state.companyCompetition.seasonNumber}. sezon sonuna kadar kilitli.'
              : 'Bir strateji seç; yeni sezona kadar değiştirilemez.',
        ),
        const SizedBox(height: 12),
        for (final strategy
            in CompanyCompetitionStrategyService.strategies) ...[
          _StrategyCard(
            strategy: strategy,
            effect: service.effectFor(state, strategy, competitor),
            selected: selected.id == strategy.id,
            locked: selected.isSelected,
            session: session,
          ),
          const SizedBox(height: 9),
        ],
      ],
    );
  }
}

class _StrategyCard extends StatelessWidget {
  const _StrategyCard({
    required this.strategy,
    required this.effect,
    required this.selected,
    required this.locked,
    required this.session,
  });

  final CompanyCompetitionStrategy strategy;
  final CompanyStrategyEffect effect;
  final bool selected;
  final bool locked;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(strategy.id);
    return AppInfoCard(
      key: ValueKey('company-strategy-${strategy.id}'),
      accent: selected ? AppPalette.success : accent,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                selected ? Icons.lock_rounded : _iconFor(strategy.id),
                color: selected ? AppPalette.success : accent,
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  strategy.title,
                  style: const TextStyle(
                    color: AppPalette.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              AppPill(
                label: 'Bugün +${effect.strengthModifier} güç',
                color: selected ? AppPalette.success : accent,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            strategy.description,
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              AppPill(
                label:
                    '${strategy.counteredSpecialty.label} rakibe +${strategy.counterStrengthBonus}',
                icon: Icons.gps_fixed_rounded,
                color: accent,
              ),
              AppPill(
                label: _percentLabel('Gelir', strategy.revenuePercent),
                color: AppPalette.warning,
              ),
              if (strategy.payrollPercent != 0)
                AppPill(
                  label: _percentLabel('Maaş', strategy.payrollPercent),
                  color: AppPalette.warning,
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            effect.reason,
            style: const TextStyle(
              color: AppPalette.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              key: ValueKey('select-company-strategy-${strategy.id}'),
              onPressed: !locked && !session.isBusy
                  ? () => _confirm(context)
                  : null,
              icon: Icon(
                selected ? Icons.check_rounded : Icons.flag_outlined,
                size: 18,
              ),
              label: Text(
                selected
                    ? 'Seçildi · sezon sonuna kadar kilitli'
                    : locked
                    ? 'Bu sezon başka strateji seçildi'
                    : 'Bu sezon için seç',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strategy.title),
        content: Text(
          '${session.state.companyCompetition.seasonNumber}. sezon sonuna kadar '
          'bu strateji değiştirilemez. ${_percentLabel('Gelir', strategy.revenuePercent)}'
          '${strategy.payrollPercent == 0 ? '' : ' · ${_percentLabel('Maaş', strategy.payrollPercent)}'}. '
          'Devam edilsin mi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Stratejiyi seç'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final message = await session.selectCompanyCompetitionStrategy(strategy);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }

  static String _percentLabel(String title, int value) =>
      '$title ${value >= 0 ? '+' : '-'}%${value.abs()}';

  static Color _accentFor(String id) => switch (id) {
    'project_offensive' => AppPalette.primary,
    'price_leadership' => AppPalette.secondary,
    'quality_advantage' => AppPalette.success,
    _ => AppPalette.tertiary,
  };

  static IconData _iconFor(String id) => switch (id) {
    'project_offensive' => Icons.rocket_launch_outlined,
    'price_leadership' => Icons.sell_outlined,
    'quality_advantage' => Icons.verified_outlined,
    _ => Icons.account_tree_outlined,
  };
}
