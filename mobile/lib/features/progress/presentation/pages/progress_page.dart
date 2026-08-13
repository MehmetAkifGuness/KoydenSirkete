import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/services/achievement_service.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'İlerleme',
      subtitle: 'Bugünkü adımların, yarının hikâyesi',
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          final state = session.state;
          final achievements = AchievementService.achievements;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              const AppSectionHeader(
                title: 'Kariyer özeti',
                caption: 'Şimdiye kadar oluşturduğun değer',
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 11,
                crossAxisSpacing: 11,
                childAspectRatio: 1.45,
                children: [
                  _StatCard(
                    label: 'Toplam kazanç',
                    value: '₺${state.totalEarned}',
                    icon: Icons.payments_rounded,
                    color: AppPalette.primary,
                  ),
                  _StatCard(
                    label: 'Çalışma',
                    value: '${state.totalWorkSessions} görev',
                    icon: Icons.work_history_rounded,
                    color: AppPalette.secondary,
                  ),
                  _StatCard(
                    label: 'Eğitim',
                    value: '${state.totalTrainingSessions} kurs',
                    icon: Icons.school_rounded,
                    color: AppPalette.tertiary,
                  ),
                  _StatCard(
                    label: 'Proje',
                    value: '${state.completedProjects} tamamlandı',
                    icon: Icons.rocket_launch_rounded,
                    color: AppPalette.primaryBright,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              AppSectionHeader(
                title: 'Başarılar',
                caption:
                    '${achievements.where((item) => item.isUnlocked(state)).length}/${achievements.length} açıldı',
              ),
              const SizedBox(height: 12),
              for (final achievement in achievements) ...[
                _AchievementTile(achievement: achievement, state: state),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppInfoCard(
      accent: color,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppPalette.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement, required this.state});

  final Achievement achievement;
  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked(state);
    final progress = (achievement.progress(state) / achievement.target).clamp(
      0.0,
      1.0,
    );
    return AppInfoCard(
      accent: unlocked ? AppPalette.tertiary : AppPalette.outline,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (unlocked ? AppPalette.tertiary : AppPalette.outline)
                  .withValues(alpha: .13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              unlocked
                  ? Icons.emoji_events_rounded
                  : Icons.lock_outline_rounded,
              color: unlocked ? AppPalette.tertiary : AppPalette.textMuted,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      '₺${achievement.reward}',
                      style: TextStyle(
                        color: AppPalette.tertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: const TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 9),
                AppProgressLine(
                  value: progress,
                  color: unlocked ? AppPalette.tertiary : AppPalette.outline,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
