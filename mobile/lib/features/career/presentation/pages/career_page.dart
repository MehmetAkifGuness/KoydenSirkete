import 'package:flutter/material.dart';

import '../../../game/presentation/state/game_session_controller.dart';
import '../../../jobs/domain/entities/job.dart';
import '../../../jobs/domain/services/job_catalog.dart';

class CareerPage extends StatelessWidget {
  const CareerPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kariyer')),
      body: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          final currentJob = JobCatalog.findById(session.state.currentJobId);
          final nextJob = JobCatalog.findById(currentJob?.nextJobId);
          if (currentJob == null) {
            return const Center(child: Text('Kariyer yolunu açmak için önce bir işe başvur.'));
          }
          final check = session.checkPromotion(currentJob, nextJob);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentJob.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text(currentJob.company, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(height: 18),
                      _Progress(label: 'Kariyer seviyesi', value: '${session.state.careerLevel}'),
                      _Progress(label: 'Performans', value: '%${session.state.performance}'),
                      _Progress(label: 'Tecrübe', value: '${session.state.experience}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (nextJob != null) ...[
                Text('Sonraki seviye', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nextJob.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                        const SizedBox(height: 6),
                        Text('Maaş: ₺${nextJob.salary} · Bilgi: ${nextJob.minimumKnowledge} · Tecrübe: ${nextJob.minimumExperience}'),
                        const SizedBox(height: 10),
                        Text(check.reason, style: TextStyle(color: check.isEligible ? Colors.greenAccent : Colors.orangeAccent)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: check.isEligible && !session.isBusy ? () => _promote(context, currentJob, nextJob) : null,
                            child: const Text('Terfi iste'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Kariyer hattının son seviyesindesin.'))),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _promote(BuildContext context, Job currentJob, Job nextJob) async {
    final message = await session.promote(currentJob, nextJob);
    if (!context.mounted || message == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.w800))]),
    );
  }
}
