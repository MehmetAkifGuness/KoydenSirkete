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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _opacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _offset = Tween<Offset>(begin: const Offset(0, .06), end: Offset.zero)
        .animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _offset,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
              child: _content(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, color: AppPalette.primary),
            const SizedBox(width: 8),
            const Text(
              'Müdür / Başlangıç',
              style: TextStyle(
                color: AppPalette.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            const Text(
              '01 — 04',
              style: TextStyle(
                color: AppPalette.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          height: 158,
          width: double.infinity,
          color: AppPalette.secondary,
          child: Stack(
            children: [
              Positioned(
                top: 18,
                right: 18,
                child: Text(
                  'CAREER\nTO COMPANY',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppPalette.surfaceMuted.withValues(alpha: .65),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Positioned(
                left: 22,
                bottom: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      padding: const EdgeInsets.all(7),
                      color: AppPalette.surface,
                      child: Image.asset(
                        'assets/images/mudurum_cover.png',
                        cacheWidth: 512,
                        cacheHeight: 512,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.business_center_rounded,
                          color: AppPalette.primary,
                          size: 42,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Müdür',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Kendi hikâyeni\nkurmaya başla.',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 10),
        const Text(
          'Köydeki ilk adımından kendi şirketine uzanan, kararlarınla şekillenen offline kariyer simülasyonu.',
          style: TextStyle(
            color: AppPalette.textSecondary,
            fontSize: 15,
            height: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        const Divider(height: 1),
        const SizedBox(height: 4),
        const _WelcomeLine(index: '01', label: 'Kariyerini planla'),
        const _WelcomeLine(index: '02', label: 'Doğru fırsatı seç'),
        const _WelcomeLine(index: '03', label: 'Kendi işini büyüt'),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isStarting || widget.session.isBusy ? null : _start,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Oyuna başla'),
          ),
        ),
      ],
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

class _WelcomeLine extends StatelessWidget {
  const _WelcomeLine({required this.index, required this.label});

  final String index;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            index,
            style: const TextStyle(
              color: AppPalette.primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              color: AppPalette.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          const Icon(Icons.north_east_rounded, size: 16, color: AppPalette.textMuted),
        ],
      ),
    );
  }
}
