import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../domain/entities/company_season_trophy.dart';
import '../../domain/entities/company_trophy_benefit.dart';
import '../../domain/services/company_trophy_service.dart';

class CompanyTrophyPanel extends StatelessWidget {
  const CompanyTrophyPanel({required this.state, super.key});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final competition = state.companyCompetition;
    final nextBenefit = CompanyTrophyService.nextBenefit(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Kupa geçmişi ve avantajlar',
          caption: 'Şampiyonluklar kalıcı fakat kontrollü güç kazandırır.',
        ),
        const SizedBox(height: 12),
        AppInfoCard(
          accent: AppPalette.warning,
          child: Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: AppPalette.warning,
                size: 31,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${competition.championships} şampiyonluk kupası',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextBenefit == null
                          ? 'Tüm kalıcı kupa avantajları açık.'
                          : 'Sıradaki avantaj: ${nextBenefit.requiredTrophies} kupa · ${nextBenefit.title}',
                      style: const TextStyle(
                        color: AppPalette.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        AppInfoCard(
          accent: AppPalette.primary,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kalıcı avantajlar',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              for (final benefit in CompanyTrophyService.benefits) ...[
                _BenefitRow(benefit: benefit, state: state),
                if (benefit != CompanyTrophyService.benefits.last)
                  const SizedBox(height: 9),
              ],
            ],
          ),
        ),
        const SizedBox(height: 9),
        AppInfoCard(
          accent: AppPalette.outline,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Şampiyonluk geçmişi',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 9),
              if (competition.trophies.isEmpty)
                const Text(
                  'Henüz kupa yok. Sezonu ilk sırada bitirdiğinde burada görünecek.',
                  style: TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 10,
                    height: 1.35,
                  ),
                )
              else
                for (
                  var index = competition.trophies.length - 1;
                  index >= 0;
                  index--
                ) ...[
                  _TrophyRow(trophy: competition.trophies[index]),
                  if (index > 0) const SizedBox(height: 7),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.benefit, required this.state});

  final CompanyTrophyBenefit benefit;
  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final unlocked = CompanyTrophyService.isUnlocked(state, benefit);
    final color = unlocked ? AppPalette.success : AppPalette.textMuted;
    return Row(
      children: [
        Icon(
          unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
          color: color,
          size: 19,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                benefit.title,
                style: TextStyle(
                  color: unlocked
                      ? AppPalette.textPrimary
                      : AppPalette.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                benefit.description,
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        AppPill(
          label: unlocked ? 'Açıldı' : '${benefit.requiredTrophies} kupa',
          color: color,
        ),
      ],
    );
  }
}

class _TrophyRow extends StatelessWidget {
  const _TrophyRow({required this.trophy});

  final CompanySeasonTrophy trophy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.workspace_premium_rounded,
          color: AppPalette.warning,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            trophy.isImported
                ? 'Önceki kayıttan aktarılan şampiyonluk'
                : '${trophy.seasonNumber}. sezon şampiyonluğu',
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (!trophy.isImported)
          Text(
            '${trophy.points} puan · +₺${trophy.reward}',
            style: const TextStyle(color: AppPalette.textMuted, fontSize: 9),
          ),
      ],
    );
  }
}
