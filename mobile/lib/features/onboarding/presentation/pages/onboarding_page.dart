import 'package:flutter/material.dart';

import '../../../game/presentation/state/game_session_controller.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.session, this.onStart, super.key});

  final GameSessionController session;
  final VoidCallback? onStart;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _backgroundOpacity;
  late final Animation<double> _contentOpacity;
  late final Animation<double> _contentScale;
  late final Animation<Offset> _contentOffset;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _backgroundOpacity = Tween<double>(begin: .08, end: .78).animate(curve);
    _contentOpacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(.24, 1, curve: Curves.easeOut)));
    _contentScale = Tween<double>(begin: .88, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(.18, 1, curve: Curves.easeOutCubic)));
    _contentOffset = Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(.18, 1, curve: Curves.easeOutCubic)));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          FadeTransition(
            opacity: _backgroundOpacity,
            child: Image.asset(
              'assets/images/mudurum_cover.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x99000000), Color(0x26000000), Color(0xF5000000)],
                stops: [0, .42, 1],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                  child: Center(
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: SlideTransition(
                        position: _contentOffset,
                        child: ScaleTransition(
                          scale: _contentScale,
                          child: _content(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context) {
    final gold = Theme.of(context).colorScheme.primary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 124,
          height: 124,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xCC080808),
            border: Border.all(color: gold.withValues(alpha: .7)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: gold.withValues(alpha: .2), blurRadius: 30, spreadRadius: 4)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.asset('assets/images/mudurum_cover.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 22),
        Text('Müdür', style: TextStyle(color: gold, fontFamily: 'serif', fontSize: 32, fontWeight: FontWeight.w700, shadows: [Shadow(color: Colors.black, blurRadius: 12)])),
        const SizedBox(height: 14),
        const Text(
          'Köydeki ilk adımından kendi şirketine\nuzanan tamamen offline bir kariyer\nsimülasyonuna hoş geldin.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFE8E2D5), fontFamily: 'serif', fontSize: 17, height: 1.55, fontWeight: FontWeight.w600, shadows: [Shadow(color: Colors.black, blurRadius: 8)]),
        ),
        const SizedBox(height: 38),
        SizedBox(
          width: 240,
          child: FilledButton.icon(
            onPressed: _isStarting || widget.session.isBusy ? null : _start,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Oyuna başla'),
          ),
        ),
      ],
    );
  }

  Future<void> _start() async {
    if (_isStarting) {
      return;
    }
    setState(() => _isStarting = true);
    if (!widget.session.state.isOnboarded) {
      await widget.session.completeOnboarding();
    }
    if (mounted) {
      widget.onStart?.call();
    }
  }
}
