import 'package:flutter/material.dart';
import '../../../../app/theme/app_palette.dart';

import '../../../game/presentation/state/game_session_controller.dart';
import '../widgets/earning_mini_game_panel.dart';

class EarningPage extends StatelessWidget {
  const EarningPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Para kazan')),
      body: AnimatedBuilder(
        animation: session,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _EarningSummary(session: session),
            const SizedBox(height: 24),
            const Text('Aktivite 2 oyun saati sürer ve 20 enerji harcar.', textAlign: TextAlign.center, style: TextStyle(color: AppPalette.textMuted)),
            const SizedBox(height: 18),
            EarningMiniGamePanel(session: session),
          ],
        ),
      ),
    );
  }
}

class _EarningSummary extends StatelessWidget {
  const _EarningSummary({required this.session});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final state = session.state;
    final earningSessions = state.earningSessionsToday;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GÜNLÜK KAZANÇ PLANI', style: TextStyle(color: AppPalette.textMuted, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: .5)),
            const SizedBox(height: 12),
            Text('₺${state.money}', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontFamily: 'serif', fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Bugün $earningSessions tur', style: const TextStyle(color: AppPalette.textMuted)),
          ],
        ),
      ),
    );
  }
}
