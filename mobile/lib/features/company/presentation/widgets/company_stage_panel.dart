import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../domain/entities/company_stage.dart';
import '../../domain/services/company_stage_service.dart';

class CompanyStagePanel extends StatelessWidget {
  const CompanyStagePanel({required this.state, super.key});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final service = CompanyStageService();
    final current = service.current(state);
    final roadmap = service.roadmap(state);
    final currentMilestone = roadmap[current.index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Şirket yol haritası',
          caption: 'Kısa, orta ve uzun vadeli büyüme aşamaların.',
        ),
        const SizedBox(height: 12),
        AppInfoCard(
          accent: AppPalette.tertiary,
          child: Row(
            children: [
              const Icon(
                Icons.route_rounded,
                color: AppPalette.tertiary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mevcut aşama',
                      style: TextStyle(
                        color: AppPalette.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      currentMilestone.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const AppPill(
                label: 'Otomatik ilerler',
                color: AppPalette.tertiary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        for (final milestone in roadmap) ...[
          _StageTile(milestone: milestone, currentStage: current),
          const SizedBox(height: 9),
        ],
      ],
    );
  }
}

class _StageTile extends StatelessWidget {
  const _StageTile({required this.milestone, required this.currentStage});

  final CompanyStageMilestone milestone;
  final CompanyStage currentStage;

  @override
  Widget build(BuildContext context) {
    final completed = milestone.stage.index < currentStage.index;
    final current = milestone.stage == currentStage;
    final accent = completed
        ? AppPalette.success
        : current
        ? AppPalette.primary
        : AppPalette.outline;
    return AppInfoCard(
      accent: accent,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                completed
                    ? Icons.check_circle_rounded
                    : current
                    ? Icons.radio_button_checked_rounded
                    : Icons.lock_outline_rounded,
                color: accent,
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  milestone.title,
                  style: TextStyle(
                    color: completed || current
                        ? AppPalette.textPrimary
                        : AppPalette.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                completed
                    ? 'Tamamlandı'
                    : current
                    ? 'Mevcut'
                    : '%${(milestone.ratio * 100).round()}',
                style: TextStyle(
                  color: accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            milestone.description,
            style: const TextStyle(color: AppPalette.textMuted, fontSize: 10),
          ),
          if (milestone.requirements.isNotEmpty) ...[
            const SizedBox(height: 9),
            AppProgressLine(value: milestone.ratio, color: accent),
            const SizedBox(height: 9),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final requirement in milestone.requirements)
                  AppPill(
                    label: '${requirement.label} · ${requirement.valueLabel}',
                    color: requirement.isMet
                        ? AppPalette.success
                        : AppPalette.textMuted,
                    icon: requirement.isMet ? Icons.check_rounded : null,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
