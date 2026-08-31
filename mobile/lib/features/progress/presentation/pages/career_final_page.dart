import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../company/domain/services/company_growth_service.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/services/achievement_service.dart';
import '../../domain/services/career_score_service.dart';

class CareerFinalPage extends StatelessWidget {
  const CareerFinalPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final state = session.state;
    final growth = CompanyGrowthService();
    final score = CareerScoreService().summarize(state);
    final achievements = AchievementService.achievements
        .where((item) => item.isUnlocked(state))
        .length;
    final wealth = state.money + state.companyFunds;
    return Scaffold(
      body: SafeArea(
        child: AppPage(
          title: 'Kariyer tamamlandı',
          subtitle: 'Köyden holdinge uzanan yolculuğun özeti',
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              AppInfoCard(
                accent: AppPalette.tertiary,
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: AppPalette.tertiary,
                      size: 58,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'HOLDİNG KURULDU',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${state.careerCompletedDay}. günde tamamlandı · ${state.economyDifficulty.label}',
                      style: const TextStyle(color: AppPalette.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${score.totalScore} kariyer puanı',
                      style: const TextStyle(
                        color: AppPalette.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      score.title,
                      style: const TextStyle(color: AppPalette.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _FinalStat(
                    label: 'Şirket değeri',
                    value: '₺${growth.valuation(state)}',
                  ),
                  _FinalStat(label: 'Toplam servet', value: '₺$wealth'),
                  _FinalStat(
                    label: 'Çalışan',
                    value: '${CompanyGrowthService.totalEmployees(state)}',
                  ),
                  _FinalStat(
                    label: 'Proje',
                    value: '${state.completedProjects}',
                  ),
                  _FinalStat(
                    label: 'Kupa',
                    value: '${state.companyCompetition.championships}',
                  ),
                  _FinalStat(label: 'Başarım', value: '$achievements'),
                ],
              ),
              const SizedBox(height: 18),
              for (final category in score.categories) ...[
                AppInfoCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              category.description,
                              style: const TextStyle(
                                color: AppPalette.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${category.score}',
                        style: const TextStyle(
                          color: AppPalette.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
              ],
              const SizedBox(height: 8),
              FilledButton.icon(
                key: const ValueKey('career-final-continue'),
                onPressed: session.isBusy ? null : () => _continue(context),
                icon: const Icon(Icons.all_inclusive_rounded),
                label: const Text('Serbest oyuna devam et'),
              ),
              const SizedBox(height: 9),
              OutlinedButton.icon(
                key: const ValueKey('career-final-restart'),
                onPressed: session.isBusy ? null : () => _restart(context),
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Yeni kariyer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _continue(BuildContext context) async {
    final message = await session.acknowledgeCareerFinal();
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }

  Future<void> _restart(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni kariyer başlatılsın mı?'),
        content: const Text(
          'Mevcut ilerleme silinir ve yeni oyun kurulumuna dönülür.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yeni kariyer'),
          ),
        ],
      ),
    );
    if (confirmed == true) await session.resetGame();
  }
}

class _FinalStat extends StatelessWidget {
  const _FinalStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    width: 148,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: AppPalette.surfaceElevated,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppPalette.outlineMuted),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppPalette.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ],
    ),
  );
}
