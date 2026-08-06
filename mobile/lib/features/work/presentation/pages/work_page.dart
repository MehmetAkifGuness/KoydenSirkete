import 'package:flutter/material.dart';

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
    final tasks = session.employerTasks(job);
    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: AnimatedBuilder(
        animation: session,
        builder: (context, _) => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: tasks.length + 1,
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text('Performans %${session.state.performance} · Bugün ${session.state.workSessionsToday} görev');
            }
            return _WorkTaskCard(task: tasks[index - 1], session: session, job: job);
          },
        ),
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
            Text(task.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(task.description, style: const TextStyle(color: Colors.white70)),
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
                onPressed: session.isBusy ? null : () => _work(context),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
