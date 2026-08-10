import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../../../app/theme/theme_palette_picker.dart';
import '../../../game/presentation/pages/developer_data_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../../progress/presentation/pages/progress_page.dart';
import '../../../assets/presentation/pages/assets_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final state = session.state;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Center(child: Text('Profil', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 24))),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: const Text('Yerel oyuncu', style: TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.w700)),
              subtitle: Text('Gün ${state.day} · ₺${state.money} · ${state.experience} tecrübe'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.home_work_outlined),
              title: const Text('Varlıklarım'),
              subtitle: const Text('Ev al, kira giderinden kurtul ve araba ile taşınma maliyetini azalt.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AssetsPage(session: session))),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events_outlined),
              title: const Text('İstatistikler ve başarılar', style: TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700)),
              subtitle: const Text('Toplam ilerlemeni ve açılan ödülleri görüntüle.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ProgressPage(session: session))),
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
          ThemePalettePicker(
            selectedId: state.themePaletteId,
            enabled: !session.isBusy,
            onSelected: (id) => session.selectThemePalette(id),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.developer_mode_outlined),
                title: const Text('Geliştirici verileri'),
                subtitle: const Text('Debug APK içinde oyun değerlerini düzenle.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: session.isBusy ? null : () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DeveloperDataPage(session: session))),
              ),
            ),
          ],
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
