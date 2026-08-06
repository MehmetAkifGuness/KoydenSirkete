import 'package:flutter/material.dart';

import '../../../game/presentation/state/game_session_controller.dart';
import '../../../jobs/domain/services/job_catalog.dart';
import '../../../work/presentation/pages/work_page.dart';

class EmploymentPage extends StatelessWidget {
  const EmploymentPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İşim')),
      body: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          final state = session.state;
          final job = JobCatalog.findById(state.currentJobId);
          if (job == null || state.employment == null) {
            return _EmptyEmployment(event: state.lastJobEvent);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(state.employment!.company, style: const TextStyle(fontSize: 13, color: Colors.white60)),
                const SizedBox(height: 5),
                Text(job.title, style: const TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Text('Maaş ₺${state.employment!.salary} · ${job.careerTrack} ${job.level}. rütbe'),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: state.performance / 100, minHeight: 5, borderRadius: BorderRadius.circular(8)),
                const SizedBox(height: 6),
                Text('Performans %${state.performance} · Bugün ${state.workSessionsToday} görev'),
                const SizedBox(height: 12),
                Text('Son görev günü: ${state.employment!.lastTaskDay}'),
              ]))),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: session.isBusy || state.activeActivity != null ? null : () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => WorkPage(session: session, job: job))),
                icon: const Icon(Icons.assignment_outlined),
                label: const Text('Günlük görevleri yönet'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: session.isBusy ? null : () => _leave(context),
                child: const Text('İşten ayrıl'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _leave(BuildContext context) async {
    final message = await session.leaveJob();
    if (!context.mounted || message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EmptyEmployment extends StatelessWidget {
  const _EmptyEmployment({this.event});

  final String? event;

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.work_off_outlined, size: 46),
      const SizedBox(height: 12),
      const Text('Aktif işin yok', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      if (event != null) ...[const SizedBox(height: 10), Text(event!, textAlign: TextAlign.center)],
      const SizedBox(height: 10),
      const Text('Yeni bir işe başvurmak için Panel > İş ilanları bölümünü aç.'),
    ])))));
  }
}
