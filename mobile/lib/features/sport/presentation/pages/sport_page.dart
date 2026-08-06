import 'package:flutter/material.dart';

import '../../../game/presentation/state/game_session_controller.dart';

class SportPage extends StatelessWidget {
  const SportPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final state = session.state;
    final activity = state.activeActivity;
    return Scaffold(
      appBar: AppBar(title: const Text('Spor')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Enerji kapasiteni geliştir', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('Mevcut enerji: ${state.energy}/${state.maxEnergy}'),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: state.energy / state.maxEnergy),
                const SizedBox(height: 14),
                const Text('Spor 20 enerji harcar, 2 oyun saati sürer ve tamamlandığında maksimum enerjiyi 5 artırır.'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: session.isBusy || activity != null ? null : () => _start(context),
                    icon: const Icon(Icons.fitness_center),
                    label: const Text('Spor yap · 20 enerji'),
                  ),
                ),
              ]),
            ),
          ),
          if (activity?.type.name == 'sport') ...[
            const SizedBox(height: 12),
            Text('${activity!.remainingHours} oyun saati kaldı.', style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: activity.progress),
          ],
        ],
      ),
    );
  }

  Future<void> _start(BuildContext context) async {
    final message = await session.startSport();
    if (!context.mounted || message == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
