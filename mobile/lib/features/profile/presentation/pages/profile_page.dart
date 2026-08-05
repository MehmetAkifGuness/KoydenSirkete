import 'package:flutter/material.dart';

import '../../../game/presentation/state/game_session_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final state = session.state;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Profil', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: const Text('Yerel oyuncu'),
              subtitle: Text('Gün ${state.day} · ₺${state.money} · ${state.experience} tecrübe'),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.cloud_off_outlined),
              title: Text('Çevrimdışı mod'),
              subtitle: Text('Oyun kuralları ve ilerleme yalnızca bu cihazda saklanır.'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Yeni oyuna başla'),
              subtitle: const Text('Mevcut ilerleme silinir ve başlangıç durumuna dönülür.'),
              onTap: session.isBusy ? null : () => _confirmReset(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni oyun başlatılsın mı?'),
        content: const Text('Mevcut yerel ilerlemen silinecek.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sıfırla')),
        ],
      ),
    );
    if (confirmed == true) {
      await session.resetGame();
    }
  }
}
