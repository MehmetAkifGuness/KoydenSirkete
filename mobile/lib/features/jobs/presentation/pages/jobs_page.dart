import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/job_listing.dart';
import '../models/job_listing_filter.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({required this.session, super.key});

  final GameSessionController session;

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  JobListingFilter _filter = JobListingFilter.all;

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    return AppPage(
      title: 'İş fırsatları',
      subtitle: 'Şehrindeki yeni başlangıçlar',
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          final allListings = session.jobListings;
          final listings = filterJobListings(
            allListings,
            _filter,
            (listing) => session.checkJob(listing.job).isEligible,
          );
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
                        color: AppPalette.secondary.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.explore_rounded,
                        color: AppPalette.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bugünün fırsat havuzu',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${listings.length} ilan · Şehirindeki pazar hareketli',
                            style: const TextStyle(
                              color: AppPalette.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppPill(
                      label: '${listings.length} ilan',
                      color: AppPalette.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const AppSectionHeader(
                title: 'Sana uygun ilanlar',
                caption: 'Her başvuru 10 enerji ve 1 oyun saati harcar.',
              ),
              const SizedBox(height: 12),
              _JobFilterBar(
                selected: _filter,
                onSelected: (filter) => setState(() => _filter = filter),
              ),
              const SizedBox(height: 9),
              Text(
                '${listings.length}/${allListings.length} ilan gösteriliyor',
                style: const TextStyle(color: AppPalette.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 8),
              for (final listing in listings) ...[
                _JobCard(listing: listing, session: session),
                const SizedBox(height: 10),
              ],
            ],
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
    final enabled =
        check.isEligible &&
        !session.isBusy &&
        session.state.hasActivityCapacity;
    return AppInfoCard(
      accent: enabled ? AppPalette.primary : AppPalette.outline,
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${job.company} · ${job.careerTrack} ${job.level}. rütbe',
                      style: const TextStyle(
                        color: AppPalette.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              AppPill(
                label: '₺${listing.salary}/gün',
                color: AppPalette.tertiary,
                icon: Icons.payments_outlined,
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            job.description,
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _Requirement(label: 'Bilgi ${job.minimumKnowledge}'),
              _Requirement(label: 'Tecrübe ${job.minimumExperience}'),
              for (final entry in job.scaledSkillRequirements.entries)
                _Requirement(label: '${entry.key.label} ${entry.value}'),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            check.reason,
            style: TextStyle(
              color: check.isEligible ? AppPalette.success : AppPalette.warning,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (check.missingSkills.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'Eksik alanlar: ${check.missingSkills.entries.map((entry) => '${entry.key.label} ${entry.value}').join(', ')}',
              style: const TextStyle(color: AppPalette.warning, fontSize: 11),
            ),
          ],
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: enabled ? () => _apply(context) : null,
              child: const Text('Başvuru gönder'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _apply(BuildContext context) async {
    final message = await session.applyForListing(listing);
    if (context.mounted && message != null) {
      AppFeedback.show(context, message);
    }
  }
}

class _JobFilterBar extends StatelessWidget {
  const _JobFilterBar({required this.selected, required this.onSelected});

  final JobListingFilter selected;
  final ValueChanged<JobListingFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in JobListingFilter.values) ...[
            ChoiceChip(
              label: Text(filter.label),
              selected: filter == selected,
              onSelected: (_) => onSelected(filter),
              selectedColor: AppPalette.primary.withValues(alpha: .18),
              showCheckmark: false,
              labelStyle: TextStyle(
                color: filter == selected
                    ? AppPalette.primary
                    : AppPalette.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (filter != JobListingFilter.values.last)
              const SizedBox(width: 7),
          ],
        ],
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) =>
      AppPill(label: label, color: AppPalette.textSecondary);
}
