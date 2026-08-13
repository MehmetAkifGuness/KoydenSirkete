import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../../jobs/domain/entities/job.dart';
import '../../domain/entities/work_task.dart';
import '../../domain/services/task_efficiency_service.dart';

class WorkPage extends StatelessWidget {
  const WorkPage({required this.session, required this.job, super.key});

  final GameSessionController session;
  final Job job;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Günün görevleri',
      subtitle: job.title,
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          final tasks = session.employerTasks(job);
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              AppInfoCard(
                accent: AppPalette.secondary,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppPalette.secondary.withValues(alpha: .13),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.work_history_rounded,
                        color: AppPalette.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bugünün performansı',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '%${session.state.performance} performans · ${session.state.workSessionsToday} görev tamamlandı',
                            style: const TextStyle(
                              color: AppPalette.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppPill(
                      label: '${tasks.length} görev',
                      color: AppPalette.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const AppSectionHeader(
                title: 'Görev seç',
                caption: 'Yeteneklerin maliyeti ve süreyi etkiler.',
              ),
              const SizedBox(height: 12),
              for (final task in tasks) ...[
                _WorkTaskCard(task: task, session: session, job: job),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _WorkTaskCard extends StatelessWidget {
  const _WorkTaskCard({
    required this.task,
    required this.session,
    required this.job,
  });

  final WorkTask task;
  final GameSessionController session;
  final Job job;

  @override
  Widget build(BuildContext context) {
    final efficiency = TaskEfficiencyService().calculate(session.state, task);
    return AppInfoCard(
      accent: AppPalette.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_outward_rounded,
                color: AppPalette.textMuted,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            task.description,
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              AppPill(
                label: '-${efficiency.energyCost} enerji',
                color: AppPalette.tertiary,
                icon: Icons.bolt_rounded,
              ),
              AppPill(
                label: '${efficiency.durationHours} saat',
                color: AppPalette.secondary,
                icon: Icons.schedule_rounded,
              ),
              AppPill(
                label: '+${task.experienceGain} tecrübe',
                color: AppPalette.primary,
                icon: Icons.trending_up_rounded,
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: session.isBusy || !session.state.hasActivityCapacity
                  ? null
                  : () => _work(context),
              child: const Text('Görevi başlat'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _work(BuildContext context) async {
    final message = await session.startWork(job, task);
    if (context.mounted && message != null) {
      AppFeedback.show(context, message);
    }
  }
}
