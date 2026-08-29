import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/game_account_bar.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../domain/entities/company_competition_state.dart';
import '../../domain/entities/company_season_rule.dart';
import '../../domain/services/company_competition_service.dart';
import '../../domain/services/company_season_rule_service.dart';
import '../pages/company_season_history_page.dart';

class CompanyCompetitionPanel extends StatelessWidget {
  const CompanyCompetitionPanel({required this.state, super.key});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final service = CompanyCompetitionService();
    final competition = state.companyCompetition;
    final seasonRule = const CompanySeasonRuleService().ruleForSeason(
      competition.seasonNumber,
    );
    final standings = service.standings(state);
    final seasonStart = CompanyCompetitionState.startDay(
      competition.seasonNumber,
    );
    final playedDays = state.day < seasonStart
        ? 0
        : (state.day - seasonStart + 1)
              .clamp(0, CompanyCompetitionState.seasonDurationDays)
              .toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: '30 günlük rekabet sezonu',
          caption: 'Günlük piyasa galibiyetleri 3 puan kazandırır.',
        ),
        const SizedBox(height: 12),
        AppInfoCard(
          accent: AppPalette.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${competition.seasonNumber}. sezon',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  AppPill(
                    label:
                        '${CompanyCompetitionState.seasonDurationDays - playedDays} gün kaldı',
                    color: AppPalette.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SeasonRuleSummary(rule: seasonRule),
              const SizedBox(height: 10),
              AppProgressLine(
                value: playedDays / CompanyCompetitionState.seasonDurationDays,
                color: AppPalette.secondary,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  AppPill(label: '${competition.points} puan'),
                  AppPill(
                    label: '${competition.wins}G · ${competition.losses}M',
                  ),
                  AppPill(
                    label: '${competition.championships} şampiyonluk',
                    icon: Icons.emoji_events_outlined,
                    color: AppPalette.warning,
                  ),
                ],
              ),
              const Divider(height: 24),
              const _StandingHeader(),
              const SizedBox(height: 5),
              for (final standing in standings)
                _StandingRow(standing: standing),
              const Divider(height: 24),
              const Text(
                'Ödüller · 1. kupa · 2. sponsor · 3. özel proje · 4. itibar',
                style: TextStyle(
                  color: AppPalette.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (competition.lastRank > 0) ...[
                const SizedBox(height: 7),
                Text(
                  'Son sezon: ${competition.lastRank}. sıra'
                  '${competition.lastReward > 0 ? ' · +₺${competition.lastReward}' : ''}',
                  style: const TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const ValueKey('open-season-history'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => Column(
                        children: [
                          GameAccountBar(state: state),
                          Expanded(
                            child: CompanySeasonHistoryPage(state: state),
                          ),
                        ],
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.history_rounded, size: 18),
                  label: const Text('Sezon geçmişini aç'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SeasonRuleSummary extends StatelessWidget {
  const _SeasonRuleSummary({required this.rule});

  final CompanySeasonRule rule;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: AppPalette.surfaceElevated,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppPalette.tertiary.withValues(alpha: .25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.public_rounded,
              color: AppPalette.tertiary,
              size: 17,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'Sezon kuralı · ${rule.title}',
                style: const TextStyle(
                  color: AppPalette.tertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          rule.description,
          style: const TextStyle(
            color: AppPalette.textSecondary,
            fontSize: 10,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            AppPill(label: _percentLabel('Gelir', rule.revenuePercent)),
            AppPill(
              label: _percentLabel('Maaş', rule.payrollPercent),
              color: AppPalette.warning,
            ),
            AppPill(
              label:
                  '${rule.favoredSpecialty.label} uzmanlığı +${rule.specialtyStrengthBonus} güç',
              color: AppPalette.secondary,
              icon: Icons.psychology_alt_outlined,
            ),
          ],
        ),
      ],
    ),
  );

  static String _percentLabel(String title, int value) =>
      '$title ${value >= 0 ? '+' : '-'}%${value.abs()}';
}

class _StandingHeader extends StatelessWidget {
  const _StandingHeader();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      SizedBox(width: 28, child: Text('#', style: _labelStyle)),
      Expanded(child: Text('Şirket', style: _labelStyle)),
      SizedBox(width: 42, child: Text('Güç', style: _labelStyle)),
      SizedBox(
        width: 46,
        child: Text('Puan', textAlign: TextAlign.end, style: _labelStyle),
      ),
    ],
  );

  static const _labelStyle = TextStyle(
    color: AppPalette.textMuted,
    fontSize: 9,
    fontWeight: FontWeight.w700,
  );
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.standing});

  final CompanySeasonStanding standing;

  @override
  Widget build(BuildContext context) {
    final color = standing.isPlayer
        ? AppPalette.primary
        : AppPalette.textSecondary;
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      decoration: BoxDecoration(
        color: standing.isPlayer
            ? AppPalette.primary.withValues(alpha: .08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${standing.rank}.',
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: Text(
              standing.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: standing.isPlayer
                    ? FontWeight.w900
                    : FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 42,
            child: Text(
              '${standing.strength}',
              style: TextStyle(color: color, fontSize: 11),
            ),
          ),
          SizedBox(
            width: 46,
            child: Text(
              '${standing.points}',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
