import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/game_account_bar.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../../jobs/domain/services/job_catalog.dart';
import '../../../cities/domain/services/city_catalog.dart';
import '../../../wheel/presentation/widgets/esnaf_wheel_panel.dart';
import '../../../work/presentation/pages/work_page.dart';

class EmploymentPage extends StatelessWidget {
  const EmploymentPage({required this.session, this.onFindJob, super.key});

  final GameSessionController session;
  final VoidCallback? onFindJob;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'İşim',
      subtitle: 'Günlük ritmini ve performansını yönet',
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          final state = session.state;
          final employment = state.employment;
          final job = JobCatalog.findById(
            employment?.jobId ?? state.currentJobId,
          );
          final salaryMultiplier =
              CityCatalog.findById(state.currentCityId)?.salaryMultiplier ?? 1;
          if (job == null || employment == null) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                AppEmptyState(
                  icon: Icons.work_off_rounded,
                  title: 'Aktif işin yok',
                  message:
                      'İş fırsatları ekranından bir role başvur. Uygun bir işi seçtiğinde görevlerin burada görünecek.',
                  action: onFindJob == null
                      ? null
                      : FilledButton.icon(
                          onPressed: onFindJob,
                          icon: const Icon(Icons.search_rounded),
                          label: const Text('İş fırsatlarını aç'),
                        ),
                ),
                const SizedBox(height: 16),
                EsnafWheelPanel(session: session),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              AppInfoCard(
                accent: AppPalette.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppPalette.primary.withValues(alpha: .13),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.business_center_rounded,
                            color: AppPalette.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                employment.company,
                                style: const TextStyle(
                                  color: AppPalette.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppPill(
                          label: '₺${employment.salary}',
                          color: AppPalette.tertiary,
                          icon: Icons.payments_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 21),
                    Row(
                      children: [
                        const Text(
                          'Performans',
                          style: TextStyle(
                            color: AppPalette.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '%${state.performance}',
                          style: const TextStyle(
                            color: AppPalette.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    AppProgressLine(value: state.performance / 100),
                    const SizedBox(height: 12),
                    Text(
                      'Gün ${state.day} · Şehir maaşı x${salaryMultiplier.toStringAsFixed(2)} · Bugün ${state.workSessionsToday} görev · Son görev günü ${employment.lastTaskDay}',
                      style: const TextStyle(
                        color: AppPalette.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: session.isBusy || !state.hasActivityCapacity
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => GameAccountRoute(
                              session: session,
                              child: WorkPage(session: session, job: job),
                            ),
                          ),
                        ),
                  icon: const Icon(Icons.assignment_rounded),
                  label: const Text('Günün görevlerini aç'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: session.isBusy ? null : () => _leave(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('İşten ayrıl'),
                ),
              ),
              const SizedBox(height: 20),
              const AppSectionHeader(
                title: 'Ekstra fırsat',
                caption: 'Şansını dene, günlük avantaj kazan.',
              ),
              const SizedBox(height: 12),
              EsnafWheelPanel(session: session),
            ],
          );
        },
      ),
    );
  }

  Future<void> _leave(BuildContext context) async {
    final message = await session.leaveJob();
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}
