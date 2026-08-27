import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../domain/entities/company_growth_goal.dart';
import '../../domain/services/company_growth_service.dart';

class CompanyGrowthPanel extends StatelessWidget {
  const CompanyGrowthPanel({required this.state, super.key});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final service = CompanyGrowthService();
    final dailyNet = service.dailyNetIncome(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Uzun vadeli hedefler',
          caption: 'Şirketini şehirler arası bir markaya dönüştür.',
        ),
        const SizedBox(height: 12),
        AppInfoCard(
          accent: AppPalette.secondary,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppPill(
                label: 'Değer ₺${service.valuation(state)}',
                color: AppPalette.tertiary,
              ),
              AppPill(
                label: 'İtibar ${service.reputation(state)}/100',
                color: AppPalette.primary,
              ),
              AppPill(
                label:
                    'Pazar %${service.marketShare(state).toStringAsFixed(1)}',
                color: AppPalette.secondary,
              ),
              AppPill(
                label: 'Net ${dailyNet >= 0 ? '+' : '-'}₺${dailyNet.abs()}/gün',
                color: dailyNet >= 0
                    ? AppPalette.success
                    : AppPalette.warning,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        for (final goal in CompanyGrowthService.goals) ...[
          _GrowthGoalTile(goal: goal, state: state),
          const SizedBox(height: 9),
        ],
      ],
    );
  }
}

class _GrowthGoalTile extends StatelessWidget {
  const _GrowthGoalTile({required this.goal, required this.state});

  final CompanyGrowthGoal goal;
  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final completed = goal.isCompleted(state);
    final accent = completed ? AppPalette.success : AppPalette.primary;
    return AppInfoCard(
      accent: accent,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle_rounded : Icons.flag_outlined,
            color: accent,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      '${goal.progress(state)}/${goal.target}',
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  goal.description,
                  style: const TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                AppProgressLine(value: goal.ratio(state), color: accent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
