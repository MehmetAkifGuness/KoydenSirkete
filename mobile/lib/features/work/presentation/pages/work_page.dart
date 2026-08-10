import 'package:flutter/material.dart';
import '../../../../app/theme/app_palette.dart';

import '../../../../core/widgets/app_feedback.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          final tasks = session.employerTasks(job);
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: tasks.length + 1,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Text('Performans %${session.state.performance} · Bugün ${session.state.workSessionsToday} görev');
              }
              final taskIndex = index - 1;
              return _WorkTaskCard(task: tasks[taskIndex], session: session, job: job);
            },
          );
        },
      ),
    );
  }
}

class _WorkTaskCard extends StatelessWidget {
  const _WorkTaskCard({required this.task, required this.session, required this.job});

  final WorkTask task;
  final GameSessionController session;
  final Job job;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: const TextStyle(fontFamily: 'serif', fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(task.description, style: const TextStyle(color: AppPalette.textSecondary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('-${TaskEfficiencyService().calculate(session.state, task).energyCost} enerji')),
                Chip(label: Text('${TaskEfficiencyService().calculate(session.state, task).durationHours} saat')),
                Chip(label: Text('+${task.experienceGain} tecrübe')),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: session.isBusy || !session.state.hasActivityCapacity ? null : () => _work(context),
                child: const Text('Görevi yap'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _work(BuildContext context) async {
    final message = await session.startWork(job, task);
    if (!context.mounted || message == null) {
      return;
    }
    AppFeedback.show(context, message);
  }
}
