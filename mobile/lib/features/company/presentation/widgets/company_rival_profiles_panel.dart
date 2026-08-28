import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../domain/entities/company_competition_state.dart';
import '../../domain/entities/company_rival_progress.dart';
import '../../domain/services/company_market_service.dart';
import '../../domain/services/company_rival_progress_service.dart';

class CompanyRivalProfilesPanel extends StatelessWidget {
  const CompanyRivalProfilesPanel({required this.state, super.key});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final event = CompanyMarketService.eventForDay(state.day);
    final competition = state.companyCompetition;
    final progressService = const CompanyRivalProgressService();
    final progress = [
      for (final competitor in CompanyMarketService.competitors)
        progressService.progressFor(
          competitor,
          seasonNumber: competition.seasonNumber,
          throughDay: state.day,
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Rakip şirket takibi',
          caption:
              '${competition.seasonNumber}. sezon · '
              '${progress.first.elapsedDays}/${CompanyCompetitionState.seasonDurationDays} gün · '
              '${event.title}',
        ),
        const SizedBox(height: 12),
        for (final item in progress) ...[
          _RivalProfileCard(progress: item, event: event),
          const SizedBox(height: 9),
        ],
      ],
    );
  }
}

class _RivalProfileCard extends StatelessWidget {
  const _RivalProfileCard({required this.progress, required this.event});

  final CompanyRivalProgress progress;
  final CompanyMarketEvent event;

  @override
  Widget build(BuildContext context) {
    final competitor = progress.competitor;
    final modifier = CompanyMarketService.competitorProfileModifier(
      competitor,
      event,
    );
    final color = modifier > 0
        ? AppPalette.warning
        : modifier < 0
        ? AppPalette.success
        : AppPalette.textMuted;
    return AppInfoCard(
      accent: color,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      competitor.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${competitor.leaderName} · ${competitor.personality}',
                      style: const TextStyle(
                        color: AppPalette.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AppPill(
                label: competitor.specialty.label,
                icon: Icons.business_center_outlined,
              ),
            ],
          ),
          const SizedBox(height: 11),
          _TraitLine(
            icon: Icons.add_circle_outline_rounded,
            color: AppPalette.success,
            title: competitor.strengthTitle,
            description: competitor.strengthDescription,
          ),
          const SizedBox(height: 7),
          _TraitLine(
            icon: Icons.remove_circle_outline_rounded,
            color: AppPalette.error,
            title: competitor.weaknessTitle,
            description: competitor.weaknessDescription,
          ),
          const Divider(height: 20),
          _RivalProgressSummary(progress: progress),
          const Divider(height: 20),
          Row(
            children: [
              Icon(
                modifier > 0
                    ? Icons.trending_up_rounded
                    : modifier < 0
                    ? Icons.trending_down_rounded
                    : Icons.horizontal_rule_rounded,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  CompanyMarketService.competitorProfileReason(
                    competitor,
                    event,
                  ),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${modifier > 0 ? '+' : ''}$modifier güç',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RivalProgressSummary extends StatelessWidget {
  const _RivalProgressSummary({required this.progress});

  final CompanyRivalProgress progress;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        progress.competitor.growthFocus,
        style: const TextStyle(
          color: AppPalette.secondary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          AppPill(
            label:
                'Bayi ${progress.branchCount} ${_countGrowth(progress.branchGrowth)}',
            icon: Icons.storefront_outlined,
          ),
          AppPill(
            label:
                'Çalışan ${progress.employeeCount} ${_countGrowth(progress.employeeGrowth)}',
            icon: Icons.groups_outlined,
            color: AppPalette.secondary,
          ),
          AppPill(
            label:
                'Kasa ₺${progress.companyFunds} · ${_moneyGrowth(progress.fundsGrowth)}',
            icon: Icons.account_balance_wallet_outlined,
            color: progress.fundsGrowth >= 0
                ? AppPalette.success
                : AppPalette.warning,
          ),
          AppPill(
            label:
                'Proje ${progress.completedProjects} ${_countGrowth(progress.completedProjectGrowth)}',
            icon: Icons.task_alt_rounded,
            color: AppPalette.tertiary,
          ),
        ],
      ),
      const SizedBox(height: 9),
      Row(
        children: [
          Expanded(
            child: Text(
              'Aktif proje %${progress.projectProgress}',
              style: const TextStyle(
                color: AppPalette.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            'Operasyon gücü +${progress.competitiveStrengthBonus}',
            style: const TextStyle(
              color: AppPalette.warning,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      AppProgressLine(
        value: progress.projectProgress / 100,
        color: AppPalette.tertiary,
      ),
    ],
  );

  static String _countGrowth(int value) => value > 0 ? '· +$value' : '· sabit';

  static String _moneyGrowth(int value) =>
      value >= 0 ? '+₺$value' : '-₺${value.abs()}';
}

class _TraitLine extends StatelessWidget {
  const _TraitLine({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 7),
      Expanded(
        child: Text.rich(
          TextSpan(
            text: '$title · ',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
            children: [
              TextSpan(
                text: description,
                style: const TextStyle(
                  color: AppPalette.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
