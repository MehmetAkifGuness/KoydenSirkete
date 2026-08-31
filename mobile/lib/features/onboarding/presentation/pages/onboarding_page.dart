import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../economy/domain/entities/economy_difficulty.dart';
import '../../../game/presentation/state/game_session_controller.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.session, this.onStart, super.key});

  final GameSessionController session;
  final VoidCallback? onStart;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  EconomyDifficulty? _difficulty;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    if (widget.session.state.isOnboarded) {
      _difficulty = widget.session.state.economyDifficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = widget.session.state.isOnboarded;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    image: true,
                    label: 'Müdür uygulama logosu',
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/images/mudurum_cover.png',
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    locked
                        ? 'Oyunu gerçek ekranlarda keşfet'
                        : 'Kariyerini kur',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bu eğitim yalnızca uygulamayı anlatmaz; gerçek ekranlarda butonlara dokunarak her temel sistemi güvenli bir demo kaydında denetir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppPalette.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const AppInfoCard(
                    accent: AppPalette.secondary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '16 adımda yaparak öğren',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 12),
                        _TourPoint(
                          icon: Icons.touch_app_outlined,
                          text:
                              'Hız, kısayol, kazanç, eğitim, spor, iş ve çalışma düğmelerini kullan.',
                        ),
                        _TourPoint(
                          icon: Icons.account_balance_wallet_outlined,
                          text:
                              'Finans, şehir ve varlık işlemlerini alt sayfalarıyla birlikte dene.',
                        ),
                        _TourPoint(
                          icon: Icons.business_outlined,
                          text:
                              'Şirket kur; operasyon, proje, büyüme ve ekip alanlarını ayrı ayrı aç.',
                        ),
                        _TourPoint(
                          icon: Icons.shield_outlined,
                          text:
                              'Demo işlemleri gerçek kariyerini ve SQLite kaydını değiştirmez.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  AppInfoCard(
                    accent: AppPalette.primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Ekonomi zorluğu',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final value in EconomyDifficulty.values)
                              ChoiceChip(
                                label: Text(value.label),
                                selected: _difficulty == value,
                                onSelected: locked
                                    ? null
                                    : (_) =>
                                          setState(() => _difficulty = value),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          locked
                              ? '${_difficulty!.label} bu kariyer için kilitli.'
                              : 'Bu seçim yalnızca yeni oyunun başında yapılır ve kariyer boyunca değiştirilemez.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppPalette.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _difficulty == null || _isStarting
                        ? null
                        : _finish,
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('16 adımlı uygulamalı eğitimi başlat'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'İlk kurulumda her zorunlu görev tamamlanınca sonraki adım açılır.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppPalette.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _finish() async {
    final difficulty = _difficulty;
    if (_isStarting || difficulty == null) return;
    setState(() => _isStarting = true);
    if (!widget.session.state.isOnboarded) {
      final saved = await widget.session.completeOnboarding(difficulty);
      if (!saved) {
        if (mounted) setState(() => _isStarting = false);
        return;
      }
    }
    if (!mounted) return;
    widget.onStart?.call();
  }
}

class _TourPoint extends StatelessWidget {
  const _TourPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppPalette.secondary, size: 18),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    ),
  );
}
