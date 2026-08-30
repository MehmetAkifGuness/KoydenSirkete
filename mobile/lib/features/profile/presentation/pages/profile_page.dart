import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/accessibility/app_feedback_preferences.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/app_transaction_preview.dart';
import '../../../../core/widgets/game_account_bar.dart';
import '../../../assets/presentation/pages/assets_page.dart';
import '../../../game/presentation/pages/developer_data_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../../progress/presentation/pages/progress_page.dart';
import '../../../economy/domain/entities/economy_difficulty.dart';
import '../../../game/domain/services/playtest_metrics_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final feedbackPreferences = AppFeedbackPreferences.instance;
    return AnimatedBuilder(
      animation: Listenable.merge([session, feedbackPreferences]),
      builder: (context, _) {
        final state = session.state;
        const metrics = PlaytestMetricsService();
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
                      value: feedbackPreferences.soundEffectsEnabled,
                      onChanged: feedbackPreferences.setSoundEffects,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.vibration_rounded),
                      title: const Text('Titreşim'),
                      subtitle: const Text('Dokunsal işlem geri bildirimi'),
                      value: feedbackPreferences.hapticsEnabled,
                      onChanged: feedbackPreferences.setHaptics,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const AppSectionHeader(
                title: 'Oynanış testi ölçümleri',
                caption: 'Kişisel veri içermeyen yerel denge sonuçları.',
              ),
              const SizedBox(height: 12),
              AppInfoCard(
                accent: AppPalette.secondary,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İlk şirket: ${metrics.firstCompanyDays(state)?.toString() ?? "Henüz tamamlanmadı"} oyun günü',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Geç oyuna ulaşma: ${metrics.lateGameDays(state)?.toString() ?? "Henüz tamamlanmadı"} oyun günü',
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _copyPlaytestReport(context, metrics),
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text('Raporu kopyala'),
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
                child: SegmentedButton<EconomyDifficulty>(
                  segments: [
                    for (final difficulty in EconomyDifficulty.values)
                      ButtonSegment(
                        value: difficulty,
                        label: Text(difficulty.label),
                      ),
                  ],
                  selected: {state.economyDifficulty},
                  onSelectionChanged: session.isBusy
                      ? null
                      : (selection) =>
                            session.setEconomyDifficulty(selection.first),
                ),
              ),
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

  Future<void> _copyPlaytestReport(
    BuildContext context,
    PlaytestMetricsService metrics,
  ) async {
    final testerProfile = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Test deneyimini seç'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Yeni oyuncu'),
            child: const Text('Yeni oyuncu'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Deneyimli oyuncu'),
            child: const Text('Deneyimli oyuncu'),
          ),
        ],
      ),
    );
    if (testerProfile == null) return;
    await Clipboard.setData(
      ClipboardData(
        text: metrics.report(session.state, testerProfile: testerProfile),
      ),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ölçüm raporu kopyalandı.')));
    }
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
