import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../domain/entities/company_season_result.dart';
import '../../domain/entities/company_season_reward.dart';

class CompanySeasonHistoryPage extends StatelessWidget {
  const CompanySeasonHistoryPage({required this.state, super.key});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final history = state.companyCompetition.seasonHistory.reversed.toList(
      growable: false,
    );
    return AppPage(
      title: 'Sezon geçmişi',
      subtitle: 'Önceki dereceler, puanlar ve ödüller',
      child: history.isEmpty
          ? const _EmptyHistory()
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                _HistorySummary(history: history),
                const SizedBox(height: 18),
                const AppSectionHeader(
                  title: 'Tamamlanan sezonlar',
                  caption: 'En yeni sonuç en üstte gösterilir.',
                ),
                const SizedBox(height: 12),
                for (final result in history) ...[
                  _SeasonResultCard(result: result),
                  const SizedBox(height: 9),
                ],
              ],
            ),
    );
  }
}

class _HistorySummary extends StatelessWidget {
  const _HistorySummary({required this.history});

  final List<CompanySeasonResult> history;

  @override
  Widget build(BuildContext context) {
    final bestRank = history
        .map((result) => result.rank)
        .reduce((left, right) => left < right ? left : right);
    final totalCash = history.fold<int>(
      0,
      (total, result) => total + result.cashReward,
    );
    return AppInfoCard(
      accent: AppPalette.secondary,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AppPill(
            label: '${history.length} tamamlanan sezon',
            icon: Icons.history_rounded,
            color: AppPalette.secondary,
          ),
          AppPill(
            label: 'En iyi derece $bestRank.',
            icon: Icons.emoji_events_outlined,
            color: AppPalette.warning,
          ),
          AppPill(
            label: 'Toplam +₺$totalCash',
            icon: Icons.account_balance_wallet_outlined,
            color: AppPalette.success,
          ),
        ],
      ),
    );
  }
}

class _SeasonResultCard extends StatelessWidget {
  const _SeasonResultCard({required this.result});

  final CompanySeasonResult result;

  @override
  Widget build(BuildContext context) {
    final color = _rewardColor(result.reward.type);
    return AppInfoCard(
      key: ValueKey('season-history-${result.seasonNumber}'),
      accent: result.rank == 1 ? AppPalette.warning : AppPalette.outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${result.seasonNumber}. sezon',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              AppPill(
                label: '${result.rank}. sıra',
                color: result.rank == 1
                    ? AppPalette.warning
                    : AppPalette.secondary,
              ),
            ],
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              AppPill(label: '${result.points} puan'),
              AppPill(label: '${result.wins}G · ${result.losses}M'),
              AppPill(
                label: result.cashReward > 0
                    ? 'Nakit +₺${result.cashReward}'
                    : 'Nakit ödül yok',
                color: result.cashReward > 0
                    ? AppPalette.success
                    : AppPalette.textMuted,
              ),
            ],
          ),
          const Divider(height: 22),
          Row(
            children: [
              Icon(_rewardIcon(result.reward.type), color: color, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.reward.title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result.reward.description,
                      style: const TextStyle(
                        color: AppPalette.textMuted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static IconData _rewardIcon(CompanySeasonRewardType type) => switch (type) {
    CompanySeasonRewardType.trophy => Icons.emoji_events_outlined,
    CompanySeasonRewardType.sponsorship => Icons.handshake_outlined,
    CompanySeasonRewardType.projectInvitation =>
      Icons.mark_email_unread_outlined,
    CompanySeasonRewardType.reputation => Icons.star_outline_rounded,
    CompanySeasonRewardType.none => Icons.remove_circle_outline,
  };

  static Color _rewardColor(CompanySeasonRewardType type) => switch (type) {
    CompanySeasonRewardType.trophy => AppPalette.warning,
    CompanySeasonRewardType.sponsorship => AppPalette.success,
    CompanySeasonRewardType.projectInvitation => AppPalette.secondary,
    CompanySeasonRewardType.reputation => AppPalette.tertiary,
    CompanySeasonRewardType.none => AppPalette.textMuted,
  };
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(28),
      child: Text(
        'Henüz tamamlanan sezon yok. İlk sezon kapandığında sonuç burada görünecek.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppPalette.textSecondary, height: 1.4),
      ),
    ),
  );
}
