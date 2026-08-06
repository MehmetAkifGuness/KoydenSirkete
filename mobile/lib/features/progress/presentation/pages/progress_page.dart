import 'package:flutter/material.dart';

import '../../../game/presentation/state/game_session_controller.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/services/achievement_service.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final state = session.state;
    final achievements = AchievementService.achievements;
    return Scaffold(
      appBar: AppBar(title: const Text('İlerleme')),
      body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const Text('İstatistikler', style: TextStyle(fontFamily: 'serif', fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 24,
                runSpacing: 16,
                children: [
                  _Stat(label: 'Toplam kazanç', value: '₺${state.totalEarned}'),
                  _Stat(label: 'Çalışma', value: '${state.totalWorkSessions} görev'),
                  _Stat(label: 'Eğitim', value: '${state.totalTrainingSessions} kurs'),
                  _Stat(label: 'Proje', value: '${state.completedProjects} tamamlandı'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Başarılar', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'serif', fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (final achievement in achievements)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AchievementTile(achievement: achievement, state: state),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 125,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ]),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement, required this.state});

  final Achievement achievement;
  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked(state);
    final progress = achievement.progress(state);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Icon(unlocked ? Icons.emoji_events : Icons.lock_outline, color: unlocked ? Colors.amber : Colors.white38),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(achievement.title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(achievement.description, style: const TextStyle(color: Colors.white60, fontSize: 12)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress / achievement.target),
          ])),
          const SizedBox(width: 10),
          Text('₺${achievement.reward}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}
