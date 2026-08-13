import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';

class SportPage extends StatelessWidget {
  const SportPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Spor',
      subtitle: 'Enerjini uzun vadeli bir avantaja çevir',
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          final state = session.state;
          final sportActivities = state.activities
              .where((item) => item.type.name == 'sport')
              .toList(growable: false);
          final activity = sportActivities.isEmpty
              ? null
              : sportActivities.first;
          final energyRatio = (state.energy / state.maxEnergy).clamp(0.0, 1.0);
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              AppInfoCard(
                accent: AppPalette.tertiary,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppPalette.tertiary.withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: AppPalette.tertiary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Enerji kapasiteni geliştir',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${state.energy}',
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 7, left: 5),
                          child: Text(
                            'enerji',
                            style: TextStyle(
                              color: AppPalette.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'maks. ${state.maxEnergy}',
                          style: const TextStyle(
                            color: AppPalette.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AppProgressLine(
                      value: energyRatio,
                      color: AppPalette.tertiary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Antrenman 20 enerji harcar, 1 oyun saati sürer ve tamamlandığında maksimum enerjini artırır.',
                      style: TextStyle(
                        color: AppPalette.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: session.isBusy || !state.hasActivityCapacity
                            ? null
                            : () => _start(context),
                        icon: const Icon(Icons.fitness_center_rounded),
                        label: const Text('Antrenmana başla · 20 enerji'),
                      ),
                    ),
                  ],
                ),
              ),
              if (activity != null) ...[
                const SizedBox(height: 14),
                AppInfoCard(
                  accent: AppPalette.secondary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.timelapse_rounded,
                            color: AppPalette.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 9),
                          const Expanded(
                            child: Text(
                              'Antrenman devam ediyor',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          Text(
                            '${activity.remainingHours} saat',
                            style: const TextStyle(
                              color: AppPalette.secondary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AppProgressLine(
                        value: activity.progress,
                        color: AppPalette.secondary,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _start(BuildContext context) async {
    final message = await session.startSport();
    if (context.mounted && message != null) {
      AppFeedback.show(context, message);
    }
  }
}
