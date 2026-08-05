import 'package:flutter/material.dart';

import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/job.dart';
import '../../domain/services/job_catalog.dart';
import '../../../work/presentation/pages/work_page.dart';

class JobsPage extends StatelessWidget {
  const JobsPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İş ilanları')),
      body: AnimatedBuilder(
        animation: session,
        builder: (context, _) => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: JobCatalog.jobs.length + 1,
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Text('Yerel katalog v1 · Bilgi ve tecrübeni geliştirerek daha iyi işlere başvurabilirsin.');
            }
            return _JobCard(job: JobCatalog.jobs[index - 1], session: session);
          },
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.session});

  final Job job;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final isCurrent = session.state.currentJobId == job.id;
    final check = session.checkJob(job);
    final isEnabled = check.isEligible && !session.isBusy;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(job.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
                Text('₺${job.salary}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 5),
            Text(job.company, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 12),
            Text(job.description, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Requirement(label: 'Bilgi ${job.minimumKnowledge}'),
                _Requirement(label: 'Tecrübe ${job.minimumExperience}'),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              isCurrent ? 'Bu iş şu anda aktif.' : check.reason,
              style: TextStyle(color: isCurrent || check.isEligible ? Colors.greenAccent : Colors.orangeAccent, fontSize: 12),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: isCurrent ? () => _openWork(context) : (!isEnabled ? null : () => _apply(context)),
                child: Text(isCurrent ? 'Çalış' : 'Başvur'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _apply(BuildContext context) async {
    final message = await session.applyForJob(job);
    if (!context.mounted || message == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openWork(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => WorkPage(session: session, job: job)));
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Chip(label: Text(label, style: const TextStyle(fontSize: 11)));
}
