import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../game/presentation/state/game_session_controller.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.session, this.onStart, super.key});

  final GameSessionController session;
  final VoidCallback? onStart;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;
  bool _isStarting = false;
  final PageController _pageController = PageController();
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _offset = Tween<Offset>(
      begin: const Offset(0, .06),
      end: Offset.zero,
    ).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _offset,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 12, 14, 0),
                  child: Row(
                    children: [
                      Text(
                        'Kısa öğretici · ${_step + 1}/3',
                        style: const TextStyle(
                          color: AppPalette.textMuted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _isStarting ? null : _start,
                        child: const Text('Atla'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (value) => setState(() => _step = value),
                    children: const [
                      _TutorialStep(
                        icon: Icons.bolt_rounded,
                        title: 'Gününü yönet',
                        description:
                            'Enerjini kazanç, eğitim ve iş görevleri arasında paylaştır. Zaman akışını üst çubuktan durdurabilirsin.',
                        action: 'İlk hamle: Kazanç ekranında sermaye oluştur.',
                      ),
                      _TutorialStep(
                        icon: Icons.trending_up_rounded,
                        title: 'Kariyerini büyüt',
                        description:
                            'Yeteneklerini geliştir, koşullarını karşıladığın işe başvur ve günlük performansını koru.',
                        action: 'Sonraki hamle: Kariyer ekranındaki hedefi izle.',
                      ),
                      _TutorialStep(
                        icon: Icons.business_rounded,
                        title: 'Şirketini kur',
                        description:
                            'Kişisel cüzdanın ile şirket kasan ayrıdır. Her işlemde kullanılan hesabı ve tahmini sonucu kontrol et.',
                        action: 'Uzun hedef: Seviye 3 ve ₺15.000 sermaye.',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isStarting || widget.session.isBusy
                          ? null
                          : _step == 2
                          ? _start
                          : _next,
                      icon: Icon(
                        _step == 2
                            ? Icons.play_arrow_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(_step == 2 ? 'Oyuna başla' : 'Devam'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _start() async {
    if (_isStarting) return;
    setState(() => _isStarting = true);
    if (!widget.session.state.isOnboarded) {
      await widget.session.completeOnboarding();
    }
    if (mounted) widget.onStart?.call();
  }
}

class _TutorialStep extends StatelessWidget {
  const _TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String description;
  final String action;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
    child: Column(
      children: [
        const SizedBox(height: 28),
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            color: AppPalette.primary.withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 48, color: AppPalette.primary),
        ),
        const SizedBox(height: 28),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 13),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppPalette.textSecondary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppPalette.tertiary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            action,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}
