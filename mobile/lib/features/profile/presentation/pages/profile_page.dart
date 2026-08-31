import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/accessibility/app_feedback_preferences.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/app_transaction_preview.dart';
import '../../../../core/widgets/game_account_bar.dart';
import '../../../assets/presentation/pages/assets_page.dart';
import '../../../game/presentation/pages/developer_data_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../../progress/presentation/pages/progress_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    required this.session,
    this.onStartTutorial,
    super.key,
  });

  final GameSessionController session;
  final VoidCallback? onStartTutorial;

  @override
  Widget build(BuildContext context) {
    final feedbackPreferences = AppFeedbackPreferences.instance;
    return AnimatedBuilder(
      animation: session,
      builder: (context, _) {
        final state = session.state;
        feedbackPreferences.configure(
          soundEffects: state.soundEffectsEnabled,
          haptics: state.hapticsEnabled,
        );
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
                        color: AppPalette.background,
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
                    builder: (_) => GameAccountRoute(
                      session: session,
                      child: AssetsPage(session: session),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              _ProfileAction(
                icon: Icons.emoji_events_outlined,
                title: 'Kariyer özeti ve başarı puanı',
                subtitle: 'Prestij hedeflerini, puanını ve başarılarını gör.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => GameAccountRoute(
                      session: session,
                      child: ProgressPage(session: session),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              _ProfileAction(
                icon: Icons.school_outlined,
                title: 'Gerçek ekran turunu tekrar aç',
                subtitle: 'Gerçek oyun ekranlarını demo kaydıyla yeniden dene.',
                enabled: onStartTutorial != null,
                onTap: onStartTutorial,
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
                            builder: (_) => GameAccountRoute(
                              session: session,
                              child: DeveloperDataPage(session: session),
                            ),
                          ),
                        ),
                ),
              ],
              const SizedBox(height: 28),
              const AppSectionHeader(
                title: 'Ses ve titreşim',
                caption: 'Geri bildirim kanallarını ayrı ayrı yönet.',
              ),
              const SizedBox(height: 12),
              AppInfoCard(
                accent: AppPalette.secondary,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.volume_up_outlined),
                      title: const Text('Ses efektleri'),
                      subtitle: const Text('İşlem geri bildirim sesleri'),
                      value: state.soundEffectsEnabled,
                      onChanged: session.isBusy
                          ? null
                          : (value) => session.setFeedbackPreferences(
                              soundEffectsEnabled: value,
                            ),
                    ),
                    TextButton.icon(
                      onPressed: state.soundEffectsEnabled
                          ? feedbackPreferences.previewSound
                          : null,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Sesi dene'),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.vibration_rounded),
                      title: const Text('Titreşim'),
                      subtitle: const Text('Dokunsal işlem geri bildirimi'),
                      value: state.hapticsEnabled,
                      onChanged: session.isBusy
                          ? null
                          : (value) => session.setFeedbackPreferences(
                              hapticsEnabled: value,
                            ),
                    ),
                    TextButton.icon(
                      onPressed: state.hapticsEnabled
                          ? feedbackPreferences.previewHaptic
                          : null,
                      icon: const Icon(Icons.touch_app_rounded),
                      label: const Text('Titreşimi dene'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const AppSectionHeader(
                title: 'Ekonomi zorluğu',
                caption: 'Gelirleri, giderleri ve enflasyon hızını belirler.',
              ),
              const SizedBox(height: 12),
              AppInfoCard(
                accent: AppPalette.primary,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.economyDifficulty.label,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Yeni oyun başında seçildi · Bu kariyer boyunca değiştirilemez.',
                            style: TextStyle(
                              color: AppPalette.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              _ProfileAction(
                icon: Icons.restart_alt_rounded,
                title: 'Yeni oyuna başla',
                subtitle: 'Mevcut ilerlemeyi sıfırla.',
                enabled: !session.isBusy,
                onTap: session.isBusy
                    ? null
                    : () => _confirmReset(context, session),
                destructive: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _confirmReset(
  BuildContext context,
  GameSessionController session,
) async {
  final confirmed = await showAppConfirmation(
    context,
    title: 'Yeni oyun başlatılsın mı?',
    summary: const Text('Tüm yerel kariyer ve şirket ilerlemesi silinecek.'),
    confirmLabel: 'Kalıcı olarak sil',
    irreversibleWarning:
        'Bu işlem geri alınamaz; para, varlıklar ve başarılar kurtarılamaz.',
  );
  if (confirmed == true) await session.resetGame();
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
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
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
