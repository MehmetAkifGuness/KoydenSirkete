import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../economy/domain/entities/economy_difficulty.dart';
import '../../../game/presentation/state/game_session_controller.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    required this.session,
    this.onStart,
    this.onSkip,
    super.key,
  });

  final GameSessionController session;
  final VoidCallback? onStart;
  final VoidCallback? onSkip;

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
                    'Yönlendirmeli turda gerçek Panel, Kazanç, Eğitim, Kariyer, İşim, Finans ve Şirket ekranlarını kullanacaksın. Turdaki işlemler ayrı bir demo kaydında kalır.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppPalette.textSecondary,
                      height: 1.45,
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
                          style: TextStyle(fontWeight: FontWeight.w900),
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
                        : () => _finish(startTutorial: true),
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Gerçek ekranlarda demoyu başlat'),
                  ),
                  TextButton(
                    onPressed: _difficulty == null || _isStarting
                        ? null
                        : () => _finish(startTutorial: false),
                    child: const Text('Öğreticiyi atla'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _finish({required bool startTutorial}) async {
    final difficulty = _difficulty;
    if (_isStarting || difficulty == null) return;
    setState(() => _isStarting = true);
    if (!widget.session.state.isOnboarded) {
      await widget.session.completeOnboarding(difficulty);
    }
    if (!mounted) return;
    if (startTutorial) {
      widget.onStart?.call();
    } else {
      (widget.onSkip ?? widget.onStart)?.call();
    }
  }
}
