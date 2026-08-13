import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../assets/presentation/pages/assets_page.dart';
import '../../../game/presentation/pages/developer_data_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../../progress/presentation/pages/progress_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: session,
      builder: (context, _) {
        final state = session.state;
        return AppPage(
          title: 'Profil',
          subtitle: 'İlerlemeni ve kişisel alanını yönet.',
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            children: [
              AppInfoCard(
                accent: AppPalette.secondary,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      color: AppPalette.secondary,
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yerel oyuncu',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Gün ${state.day} · ₺${state.money} · ${state.experience} tecrübe',
                            style: const TextStyle(
                              color: AppPalette.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.verified_outlined,
                      color: AppPalette.primary,
                      size: 21,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const AppSectionHeader(
                title: 'Hesabım',
                caption: 'Kişisel ilerleme ve sahip oldukların.',
              ),
              const SizedBox(height: 12),
              _ProfileAction(
                icon: Icons.home_work_outlined,
                title: 'Varlıklarım',
                subtitle: 'Ev ve araba koleksiyonunu yönet.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AssetsPage(session: session),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              _ProfileAction(
                icon: Icons.emoji_events_outlined,
                title: 'İstatistikler ve başarılar',
                subtitle: 'İlerlemeni ve kazandığın ödülleri gör.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProgressPage(session: session),
                  ),
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 9),
                _ProfileAction(
                  icon: Icons.developer_mode_outlined,
                  title: 'Geliştirici verileri',
                  subtitle: 'Debug sürümünde oyun değerlerini düzenle.',
                  enabled: !session.isBusy,
                  onTap: session.isBusy
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => DeveloperDataPage(session: session),
                          ),
                        ),
                ),
              ],
              const SizedBox(height: 9),
              _ProfileAction(
                icon: Icons.restart_alt_rounded,
                title: 'Yeni oyuna başla',
                subtitle: 'Mevcut ilerlemeyi sıfırla.',
                enabled: !session.isBusy,
                onTap: session.isBusy ? null : () => _confirmReset(context),
                destructive: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni oyun başlatılsın mı?'),
        content: const Text('Mevcut yerel ilerlemen silinecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
    if (confirmed == true) await session.resetGame();
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.enabled = true,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool enabled;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppPalette.error : AppPalette.primary;
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: AppInfoCard(
        accent: color,
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
            child: Row(
              children: [
                Icon(icon, color: color, size: 21),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text(subtitle, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(Icons.arrow_forward_rounded, size: 17),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
