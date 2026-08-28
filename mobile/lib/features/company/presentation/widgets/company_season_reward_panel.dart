import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../domain/entities/company_season_reward.dart';
import '../../domain/services/company_season_reward_service.dart';

class CompanySeasonRewardPanel extends StatelessWidget {
  const CompanySeasonRewardPanel({required this.state, super.key});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    const service = CompanySeasonRewardService();
    final competition = state.companyCompetition;
    final sponsorship = service.sponsorshipRevenueBonus(state);
    final invitations = service.availableProjectInvitations(state);
    final reputation = service.reputationBonus(state);
    final history = competition.seasonRewards.reversed.take(6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Sezon ödülleri',
          caption:
              'Dereceler para dışında kalıcı veya kullanımlık haklar verir.',
        ),
        const SizedBox(height: 12),
        AppInfoCard(
          accent: AppPalette.tertiary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aktif kazanımlar',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  AppPill(
                    label: sponsorship > 0
                        ? 'Sponsor +%$sponsorship gelir'
                        : 'Aktif sponsor yok',
                    icon: Icons.handshake_outlined,
                    color: sponsorship > 0
                        ? AppPalette.success
                        : AppPalette.textMuted,
                  ),
                  AppPill(
                    label: '$invitations özel proje daveti',
                    icon: Icons.mark_email_unread_outlined,
                    color: invitations > 0
                        ? AppPalette.secondary
                        : AppPalette.textMuted,
                  ),
                  AppPill(
                    label: 'Sezon itibarı +$reputation',
                    icon: Icons.star_outline_rounded,
                    color: reputation > 0
                        ? AppPalette.warning
                        : AppPalette.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        AppInfoCard(
          accent: AppPalette.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Derece tablosu',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              for (var rank = 1; rank <= 5; rank++) ...[
                _RewardRow(
                  reward: service.rewardFor(
                    seasonNumber: competition.seasonNumber,
                    rank: rank,
                  ),
                  showSeason: false,
                ),
                if (rank < 5) const SizedBox(height: 7),
              ],
            ],
          ),
        ),
        if (history.isNotEmpty) ...[
          const SizedBox(height: 9),
          AppInfoCard(
            accent: AppPalette.outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Son ödüller',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                for (final reward in history) ...[
                  _RewardRow(reward: reward, showSeason: true),
                  if (reward != history.last) const SizedBox(height: 7),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.reward, required this.showSeason});

  final CompanySeasonReward reward;
  final bool showSeason;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(reward.type);
    return Row(
      children: [
        Icon(_iconFor(reward.type), size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                showSeason
                    ? '${reward.seasonNumber}. sezon · ${reward.title}'
                    : '${reward.rank}. ${reward.title}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                reward.description,
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        if (showSeason) AppPill(label: '${reward.rank}. sıra', color: color),
      ],
    );
  }

  static IconData _iconFor(CompanySeasonRewardType type) => switch (type) {
    CompanySeasonRewardType.trophy => Icons.emoji_events_outlined,
    CompanySeasonRewardType.sponsorship => Icons.handshake_outlined,
    CompanySeasonRewardType.projectInvitation =>
      Icons.mark_email_unread_outlined,
    CompanySeasonRewardType.reputation => Icons.star_outline_rounded,
    CompanySeasonRewardType.none => Icons.remove_circle_outline,
  };

  static Color _colorFor(CompanySeasonRewardType type) => switch (type) {
    CompanySeasonRewardType.trophy => AppPalette.warning,
    CompanySeasonRewardType.sponsorship => AppPalette.success,
    CompanySeasonRewardType.projectInvitation => AppPalette.secondary,
    CompanySeasonRewardType.reputation => AppPalette.tertiary,
    CompanySeasonRewardType.none => AppPalette.textMuted,
  };
}
