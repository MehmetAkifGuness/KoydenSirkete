import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../../jobs/domain/entities/job.dart';
import '../../../jobs/domain/services/job_catalog.dart';

class CareerPage extends StatelessWidget {
  const CareerPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Kariyer',
      subtitle: 'Bir sonraki seviyene giden yol',
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          final state = session.state;
          final currentJob = JobCatalog.findById(
            state.employment?.jobId ?? state.currentJobId,
          );
          final nextJob = JobCatalog.findById(currentJob?.nextJobId);
          if (currentJob == null) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: const [
                AppEmptyState(
                  icon: Icons.trending_up_rounded,
                  title: 'Kariyerin henüz başlamadı',
                  message:
                      'İş fırsatları ekranından ilk başvurunu yap. İlk rolün, büyük yolculuğunun başlangıcı olacak.',
                ),
              ],
            );
          }
          final check = session.checkPromotion(currentJob, nextJob);
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              AppInfoCard(
                accent: AppPalette.secondary,
                padding: const EdgeInsets.all(19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppPalette.secondary.withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.workspace_premium_rounded,
                            color: AppPalette.secondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentJob.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.employment?.company ?? currentJob.company,
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
                          label: 'Seviye ${state.careerLevel}',
                          color: AppPalette.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _ProgressLine(
                      label: 'Performans',
                      value: state.performance / 100,
                      valueText: '%${state.performance}',
                      color: AppPalette.primary,
                    ),
                    const SizedBox(height: 14),
                    _ProgressLine(
                      label: 'Kariyer seviyesi',
                      value: state.careerLevel / 10,
                      valueText: '${state.careerLevel}',
                      color: AppPalette.secondary,
                    ),
                    const SizedBox(height: 14),
                    _ProgressLine(
                      label: 'Toplam tecrübe',
                      value: (state.experience / 1000).clamp(0, 1),
                      valueText: '${state.experience}',
                      color: AppPalette.tertiary,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        AppPill(
                          label: 'Kıdem: ${currentJob.careerStage.label}',
                          color: AppPalette.primary,
                        ),
                        AppPill(
                          label: 'Uzmanlık: ${currentJob.careerTrack}',
                          color: AppPalette.secondary,
                        ),
                        AppPill(
                          label: currentJob.careerDirection,
                          color: AppPalette.tertiary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const AppSectionHeader(
                title: 'Kariyer rotası',
                caption:
                    'Uzmanlaşmadan yöneticiliğe uzanan meslek basamakların.',
              ),
              const SizedBox(height: 12),
              AppInfoCard(
                child: Column(
                  children: [
                    for (final job in JobCatalog.careerPathFor(currentJob))
                      _CareerStep(
                        job: job,
                        isCurrent: job.id == currentJob.id,
                        isCompleted: job.level < currentJob.level,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              AppSectionHeader(
                title: nextJob == null ? 'Zirvedesin' : 'Sıradaki adım',
                caption: nextJob == null
                    ? 'Bu kariyer hattının son seviyesine ulaştın.'
                    : 'Yeni rolün için gerekenleri tamamla.',
              ),
              const SizedBox(height: 12),
              if (nextJob != null)
                AppInfoCard(
                  accent: check.isEligible
                      ? AppPalette.primary
                      : AppPalette.tertiary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              nextJob.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          AppPill(
                            label: '₺${nextJob.salary}',
                            color: AppPalette.tertiary,
                            icon: Icons.payments_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${state.employment?.company ?? nextJob.company} · ${nextJob.careerTrack} ${nextJob.level}. rütbe',
                        style: const TextStyle(
                          color: AppPalette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          AppPill(
                            label: 'Bilgi ${nextJob.minimumKnowledge}',
                            color: AppPalette.secondary,
                          ),
                          AppPill(
                            label: 'Tecrübe ${nextJob.minimumExperience}',
                            color: AppPalette.primary,
                          ),
                          AppPill(
                            label: nextJob.careerStage.label,
                            color: AppPalette.tertiary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        check.reason,
                        style: TextStyle(
                          color: check.isEligible
                              ? AppPalette.success
                              : AppPalette.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: check.isEligible && !session.isBusy
                              ? () => _promote(context, currentJob, nextJob)
                              : null,
                          child: const Text('Terfi iste'),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const AppEmptyState(
                  icon: Icons.emoji_events_rounded,
                  title: 'Kariyer hattının sonundasın',
                  message:
                      'Bu rolü en iyi şekilde yönetmeye ve kendi şirketini büyütmeye odaklan.',
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _promote(
    BuildContext context,
    Job currentJob,
    Job nextJob,
  ) async {
    final message = await session.promote(currentJob, nextJob);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _CareerStep extends StatelessWidget {
  const _CareerStep({
    required this.job,
    required this.isCurrent,
    required this.isCompleted,
  });

  final Job job;
  final bool isCurrent;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Icon(
          isCompleted
              ? Icons.check_circle_rounded
              : isCurrent
              ? Icons.radio_button_checked_rounded
              : Icons.lock_outline_rounded,
          color: isCompleted || isCurrent
              ? AppPalette.primary
              : AppPalette.textMuted,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${job.careerStage.label} · ${job.careerDirection}',
                style: const TextStyle(
                  color: AppPalette.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (isCurrent)
          const AppPill(label: 'Mevcut', color: AppPalette.primary),
      ],
    ),
  );
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.label,
    required this.value,
    required this.valueText,
    required this.color,
  });

  final String label;
  final double value;
  final String valueText;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppPalette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            valueText,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      const SizedBox(height: 7),
      AppProgressLine(value: value, color: color),
    ],
  );
}
