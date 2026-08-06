import 'package:flutter/material.dart';

import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/job_listing.dart';

class JobsPage extends StatelessWidget {
  const JobsPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İş ilanları')),
      body: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          final listings = session.jobListings;
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: listings.length + 1,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) return Text('Bugünün şehir fırsatları · ${listings.length} ilan');
              return _JobCard(listing: listings[index - 1], session: session);
            },
          );
        },
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.listing, required this.session});

  final JobListing listing;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final job = listing.job;
    final check = session.checkJob(job);
    final enabled = check.isEligible && !session.isBusy && session.state.activeActivity == null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(job.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
            Text('₺${listing.salary}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 5),
          Text('${job.company} · ${job.careerTrack} ${job.level}. rütbe', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 12),
          Text(job.description, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _Requirement(label: 'Bilgi ${job.minimumKnowledge}'),
            _Requirement(label: 'Tecrübe ${job.minimumExperience}'),
            for (final entry in job.skillRequirements.entries) _Requirement(label: '${entry.key.label} ${entry.value}'),
          ]),
          const SizedBox(height: 10),
          Text(check.reason, style: TextStyle(color: check.isEligible ? Colors.greenAccent : Colors.orangeAccent, fontSize: 12)),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: FilledButton.tonal(
            onPressed: enabled ? () => _apply(context) : null,
            child: const Text('Başvur · 10 enerji · 1 saat'),
          )),
        ]),
      ),
    );
  }

  Future<void> _apply(BuildContext context) async {
    final message = await session.applyForListing(listing);
    if (!context.mounted || message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Chip(label: Text(label, style: const TextStyle(fontSize: 11)));
}
