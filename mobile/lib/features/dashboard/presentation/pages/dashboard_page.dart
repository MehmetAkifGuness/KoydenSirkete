import 'package:flutter/material.dart';
import '../../../../app/theme/app_palette.dart';

import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/constants/app_features.dart';
import '../../../../core/widgets/feature_card.dart';
import '../../../../core/widgets/metric_tile.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../../game/domain/entities/active_activity.dart';
import '../../../daily_goals/domain/entities/daily_goal.dart';
import '../models/dashboard_models.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.session, required this.onFeatureTap, super.key});

  final GameSessionController session;
  final ValueChanged<AppFeature> onFeatureTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: session,
      builder: (context, _) {
        final state = DashboardDesignState.fromPlayer(session.state);
        final activityCount = session.state.activities.length;
        final activityCapacity = session.state.activityCapacity;
        return SafeArea(
          child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _Header(day: session.state.day, hour: session.state.hour),
            const SizedBox(height: 24),
            _GoalCard(status: session.dailyGoalStatus, session: session),
            const SizedBox(height: 24),
            const SectionTitle(title: 'Durum'),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.metrics.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 116, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemBuilder: (_, index) {
                final metric = state.metrics[index];
                return MetricTile(label: metric.label, value: metric.value, icon: metric.icon, color: metric.color);
              },
            ),
            const SizedBox(height: 24),
            if (session.state.activities.isNotEmpty) ...[
              const SizedBox(height: 24),
              SectionTitle(
                title: 'Aktif aktiviteler ($activityCount/$activityCapacity)',
              ),
              const SizedBox(height: 12),
              for (final activity in session.state.activities) ...[
                _ActivityCard(activity: activity),
                const SizedBox(height: 10),
              ],
            ],
            const SizedBox(height: 24),
            const SectionTitle(title: 'Kategoriler'),
            const SizedBox(height: 12),
            for (final feature in [AppFeatures.earning, AppFeatures.training, AppFeatures.skills, AppFeatures.sport, AppFeatures.jobs, AppFeatures.cities])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FeatureCard(feature: feature, onTap: () => onFeatureTap(feature)),
              ),
          ],
          ),
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final ActiveActivity activity;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(color: AppPalette.surfaceElevated, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.work_outline, color: AppPalette.primary)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_title(activity.type.name), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Kalan süre: ${activity.remainingHours} saat', style: const TextStyle(color: AppPalette.textSecondary, fontSize: 13)),
            ])),
            Icon(Icons.close, color: AppPalette.textMuted.withValues(alpha: .8)),
          ]),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: activity.progress, minHeight: 4, borderRadius: BorderRadius.circular(8)),
        ]),
      ),
    );
  }

  String _title(String type) {
    return switch (type) {
      'earning' => 'Para kazan',
      'training' => 'Eğitim',
      'sport' => 'Spor',
      'work' => 'İş görevi',
      'jobApplication' => 'İş başvurusu',
      _ => 'Aktif işlem',
    };
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.day, required this.hour});

  final int day;
  final int hour;

  @override
  Widget build(BuildContext context) {
    final formattedHour = hour.toString().padLeft(2, '0');
    return SizedBox(
      height: 48,
      child: Row(children: [
        IconButton(onPressed: () { if (Navigator.canPop(context)) Navigator.pop(context); }, icon: const Icon(Icons.arrow_back)),
        Expanded(child: Center(child: Text('Müdür', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 24)))),
        SizedBox(
          width: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
          Text('$day. gün', style: const TextStyle(fontSize: 11, color: AppPalette.textSecondary)),
              Text('$formattedHour:00', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
            ],
          ),
        ),
      ]),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.status, required this.session});

  final DailyGoalStatus status;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('GÜNLÜK HEDEF', style: TextStyle(color: AppPalette.textMuted, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: .5)),
          const SizedBox(height: 20),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: Text(status.isClaimed ? 'Hedef tamamlandı' : 'Aktif hedef', style: const TextStyle(fontFamily: 'serif', fontSize: 25, fontWeight: FontWeight.w700))),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('Ödül', style: TextStyle(color: AppPalette.textMuted, fontSize: 12)),
              Text('₺${status.reward}', style: TextStyle(color: color, fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700)),
            ]),
          ]),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: status.ratio, minHeight: 4, borderRadius: BorderRadius.circular(8)),
          if (status.isComplete && !status.isClaimed) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: session.isBusy ? null : () => _claim(context),
                child: const Text('Ödülü al'),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  Future<void> _claim(BuildContext context) async {
    final message = await session.claimDailyGoal();
    if (!context.mounted || message == null) {
      return;
    }
    AppFeedback.show(context, message);
  }
}
