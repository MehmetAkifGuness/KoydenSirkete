import 'package:flutter/material.dart';
import '../../../../app/theme/app_palette.dart';

import '../../../../core/widgets/app_feedback.dart';
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
    final enabled = check.isEligible && !session.isBusy && session.state.hasActivityCapacity;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(job.title, style: const TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.w700))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: AppPalette.primary, borderRadius: BorderRadius.circular(4)), child: Text('₺${listing.salary}', style: TextStyle(color: AppPalette.background, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 5),
          Text('${job.company} · ${job.careerTrack} ${job.level}. rütbe', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 12),
          Text(job.description, style: const TextStyle(color: AppPalette.textSecondary)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
          _Requirement(label: 'BİLGİ ${job.minimumKnowledge}'),
          _Requirement(label: 'TECRÜBE ${job.minimumExperience}'),
          for (final entry in job.scaledSkillRequirements.entries) _Requirement(label: '${entry.key.label.toUpperCase()} ${entry.value}'),
          ]),
          const SizedBox(height: 10),
          Text(check.reason, style: TextStyle(color: check.isEligible ? AppPalette.success : AppPalette.warning, fontSize: 12)),
          if (check.missingSkills.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Eksik yetenekler: ${check.missingSkills.entries.map((entry) => '${entry.key.label} ${entry.value}').join(', ')}. Bunları geliştirmelisin.',
              style: const TextStyle(color: AppPalette.warning, fontSize: 12),
            ),
          ],
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
    AppFeedback.show(context, message);
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(border: Border.all(color: AppPalette.outline), borderRadius: BorderRadius.circular(16)),
    child: Text(label, style: TextStyle(color: AppPalette.primary, fontSize: 10, fontWeight: FontWeight.w700)),
  );
}
