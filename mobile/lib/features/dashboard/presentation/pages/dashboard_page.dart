import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/constants/app_features.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/feature_card.dart';
import '../../../../core/widgets/metric_tile.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../daily_goals/domain/entities/daily_goal.dart';
import '../../../game/domain/entities/active_activity.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../models/dashboard_models.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.session,
    required this.onFeatureTap,
    super.key,
  });

  final GameSessionController session;
  final ValueChanged<AppFeature> onFeatureTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: session,
      builder: (context, _) {
        final design = DashboardDesignState.fromPlayer(session.state);
        final activities = session.state.activities;
        return AppPage(
          title: 'Kontrol',
          subtitle: 'Bugünün kararlarını yönet.',
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            children: [
              _DashboardMeta(day: session.state.day, hour: session.state.hour),
              const SizedBox(height: 18),
              _WelcomeHero(status: session.dailyGoalStatus, session: session),
              const SizedBox(height: 28),
              const SectionTitle(title: 'Bugünün özeti'),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: design.metrics.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 112,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (_, index) {
                  final metric = design.metrics[index];
                  return MetricTile(
                    label: metric.label,
                    value: metric.value,
                    icon: metric.icon,
                    color: metric.color,
                  );
                },
              ),
              if (activities.isNotEmpty) ...[
                const SizedBox(height: 28),
                SectionTitle(
                  title: 'Devam edenler',
                  action:
                      '${activities.length}/${session.state.activityCapacity}',
                ),
                const SizedBox(height: 12),
                for (final activity in activities) ...[
                  _ActivityCard(activity: activity),
                  const SizedBox(height: 10),
                ],
              ],
              const SizedBox(height: 28),
              const SectionTitle(title: 'Hızlı erişim'),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 8,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 126,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (_, index) {
                  final feature = [
                    AppFeatures.earning,
                    AppFeatures.finance,
                    AppFeatures.assets,
                    AppFeatures.training,
                    AppFeatures.skills,
                    AppFeatures.sport,
                    AppFeatures.jobs,
                    AppFeatures.cities,
                  ][index];
                  return FeatureCard(
                    feature: feature,
                    onTap: () => onFeatureTap(feature),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardMeta extends StatelessWidget {
  const _DashboardMeta({required this.day, required this.hour});

  final int day;
  final int hour;

  @override
  Widget build(BuildContext context) {
    final formattedHour = hour.toString().padLeft(2, '0');
    return Row(
      children: [
        const Icon(Icons.today_outlined, color: AppPalette.primary, size: 17),
        const SizedBox(width: 7),
        Text(
          'GÜN $day',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 12),
        Container(width: 1, height: 15, color: AppPalette.outlineMuted),
        const SizedBox(width: 12),
        Text(
          '$formattedHour:00',
          style: const TextStyle(
            color: AppPalette.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        const Text(
          'ÇEVRİMDIŞI KAYIT',
          style: TextStyle(
            color: AppPalette.success,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: .6,
          ),
        ),
      ],
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.status, required this.session});

  final DailyGoalStatus status;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final progress = status.ratio.clamp(0.0, 1.0);
    final title = status.isClaimed
        ? 'Hedef tamamlandı'
        : status.isComplete
        ? 'Ödülün hazır'
        : 'Bugünün odağı';
    return AppInfoCard(
      accent: AppPalette.primary,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppPill(label: 'Günlük hedef', icon: Icons.flag_outlined),
              const Spacer(),
              Text(
                '₺${status.reward}',
                style: const TextStyle(
                  color: AppPalette.primaryDim,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 5),
          Text(
            status.isClaimed
                ? 'Bugünün kazanımı hesabına eklendi.'
                : 'Küçük adımlar, büyük bir kariyer.',
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 17),
          AppProgressLine(value: progress),
          const SizedBox(height: 8),
          Text(
            '%${(progress * 100).round()} tamamlandı',
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (status.isComplete && !status.isClaimed) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: session.isBusy ? null : () => _claim(context),
              icon: const Icon(Icons.redeem_outlined, size: 18),
              label: const Text('Ödülü al'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _claim(BuildContext context) async {
    final message = await session.claimDailyGoal();
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final ActiveActivity activity;

  @override
  Widget build(BuildContext context) {
    final icon = switch (activity.type.name) {
      'training' => Icons.school_outlined,
      'sport' => Icons.fitness_center_outlined,
      'earning' => Icons.payments_outlined,
      'jobApplication' => Icons.send_outlined,
      _ => Icons.work_outline,
    };
    return AppInfoCard(
      accent: AppPalette.secondary,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, color: AppPalette.secondary, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(activity.type.name),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                AppProgressLine(
                  value: activity.progress,
                  color: AppPalette.secondary,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${activity.remainingHours}s',
            style: const TextStyle(
              color: AppPalette.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _title(String type) => switch (type) {
    'earning' => 'Para kazan',
    'training' => 'Eğitim',
    'sport' => 'Spor',
    'work' => 'İş görevi',
    'jobApplication' => 'İş başvurusu',
    _ => 'Aktif işlem',
  };
}
