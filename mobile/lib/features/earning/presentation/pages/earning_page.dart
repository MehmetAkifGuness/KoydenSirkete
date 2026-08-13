import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../widgets/earning_mini_game_panel.dart';

class EarningPage extends StatelessWidget {
  const EarningPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Kazanç',
      subtitle: 'İlk sermayeni kendi emeğinle oluştur',
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          final state = session.state;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              AppInfoCard(
                accent: AppPalette.primary,
                padding: const EdgeInsets.fromLTRB(19, 19, 19, 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Cüzdanın',
                            style: TextStyle(
                              color: AppPalette.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const AppPill(
                          label: 'OFFLINE',
                          color: AppPalette.primary,
                          icon: Icons.cloud_off_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₺${state.money}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Bugün ${state.earningSessionsToday} tur tamamlandı',
                            style: const TextStyle(
                              color: AppPalette.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          '${state.energy}/${state.maxEnergy} enerji',
                          style: const TextStyle(
                            color: AppPalette.tertiary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const AppSectionHeader(
                title: 'Hızlı kazanç',
                caption: '10 saniyelik refleks oyunu ile bonus kazan.',
              ),
              const SizedBox(height: 12),
              EarningMiniGamePanel(session: session),
            ],
          );
        },
      ),
    );
  }
}
