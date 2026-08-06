import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../game/domain/entities/active_activity.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../../game/presentation/state/game_session_controller.dart';

class EsnafWheelPanel extends StatefulWidget {
  const EsnafWheelPanel({required this.session, super.key});

  final GameSessionController session;

  @override
  State<EsnafWheelPanel> createState() => _EsnafWheelPanelState();
}

class _EsnafWheelPanelState extends State<EsnafWheelPanel> with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  late final CurvedAnimation _spinAnimation;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
    _spinAnimation = CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _spinAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.session.state;
    final availability = widget.session.wheelAvailability;
    final gold = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.casino_outlined, color: gold),
            const SizedBox(width: 10),
            const Expanded(child: Text('Esnaf Çarkı', style: TextStyle(fontFamily: 'serif', fontSize: 19, fontWeight: FontWeight.w700))),
            Text('${state.wheelMajorRewardsToday}/3 büyük ödül', style: TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          const Text('20 dilimde şansını dene.', style: TextStyle(color: Color(0xFFD1C9B8))),
          const SizedBox(height: 10),
          Center(child: _Wheel(animation: _spinAnimation)),
          Wrap(spacing: 8, runSpacing: 8, children: [
            const _InfoPill(text: '50 TL'),
            const _InfoPill(text: 'Bekleme yok'),
            const _InfoPill(text: 'Aktif iş'),
          ]),
          if (state.wheelDurationBuffTasks > 0 || state.wheelEnergyBuffTasks > 0) ...[
            const SizedBox(height: 10),
            Text(_buffText(state), style: TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: availability.isAvailable && !_isSpinning && !widget.session.isBusy && state.activeActivity?.type == ActivityType.work ? () => _spin(context) : null,
              icon: Icon(_isSpinning ? Icons.hourglass_top : Icons.casino_outlined),
              label: Text(_isSpinning ? 'Çark dönüyor...' : 'Çarkı çevir · 50 TL'),
            ),
          ),
          if (!availability.isAvailable && !_isSpinning) ...[
            const SizedBox(height: 8),
            Text(availability.reason, style: const TextStyle(color: Color(0xFFB9A76A), fontSize: 12)),
          ],
        ]),
      ),
    );
  }

  String _buffText(PlayerState state) {
    final parts = <String>[];
    if (state.wheelDurationBuffTasks > 0) {
      parts.add('Süre -%${state.wheelDurationBuffPercent} · ${state.wheelDurationBuffTasks} görev');
    }
    if (state.wheelEnergyBuffTasks > 0) {
      parts.add('Enerji -%${state.wheelEnergyBuffPercent} · ${state.wheelEnergyBuffTasks} görev');
    }
    return parts.join('  |  ');
  }

  Future<void> _spin(BuildContext context) async {
    setState(() => _isSpinning = true);
    final result = widget.session.spinWheel();
    await _spinController.forward(from: 0);
    final message = await result;
    if (!context.mounted) {
      return;
    }
    setState(() => _isSpinning = false);
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 238,
      height: 238,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (_, _) => Transform.rotate(
              angle: animation.value * math.pi * 12,
              child: const CustomPaint(size: Size.square(220), painter: _WheelPainter()),
            ),
          ),
          const Align(alignment: Alignment.topCenter, child: Icon(Icons.arrow_drop_down, size: 34, color: Color(0xFFE6C44A))),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: const Color(0xFF0A0A08), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE6C44A), width: 2)),
            child: const Icon(Icons.casino, size: 17, color: Color(0xFFE6C44A)),
          ),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter();

  static const _labels = [
    'İHALE', 'ŞANS', '60 TL', 'KAZIK', 'BOŞ', 'BAYAT', 'ÇIRAK', '60 TL', 'KAZIK', 'BOŞ',
    'BAYAT', 'KAZIK', 'BOŞ', 'ÇIRAK', 'KAZIK', 'BAYAT', 'BOŞ', 'KAZIK', 'BOŞ', 'KAZIK',
  ];
  static const _colors = [
    Color(0xFFE6C44A), Color(0xFFB99832), Color(0xFFDDBA3E), Color(0xFF6B2525), Color(0xFF2E2B25),
    Color(0xFF4A4130), Color(0xFF6B2525), Color(0xFFDDBA3E), Color(0xFF6B2525), Color(0xFF2E2B25),
    Color(0xFF4A4130), Color(0xFF6B2525), Color(0xFF2E2B25), Color(0xFF6B2525), Color(0xFF6B2525),
    Color(0xFF4A4130), Color(0xFF2E2B25), Color(0xFF6B2525), Color(0xFF2E2B25), Color(0xFF6B2525),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius - 3);
    final slice = math.pi * 2 / _labels.length;
    for (var index = 0; index < _labels.length; index++) {
      final start = -math.pi / 2 + index * slice;
      canvas.drawArc(rect, start, slice, true, Paint()..color = _colors[index]);
      final angle = start + slice / 2;
      final textPainter = TextPainter(
        text: TextSpan(text: _labels[index], style: TextStyle(color: index == 3 || index == 6 || index == 8 || index == 11 || index == 13 || index == 14 || index == 17 || index == 19 ? Colors.white : Colors.black, fontSize: 7, fontWeight: FontWeight.w800)),
        textDirection: TextDirection.ltr,
      )..layout();
      final textCenter = Offset(center.dx + math.cos(angle) * radius * .61, center.dy + math.sin(angle) * radius * .61);
      textPainter.paint(canvas, textCenter - Offset(textPainter.width / 2, textPainter.height / 2));
    }
    canvas.drawCircle(center, radius - 3, Paint()..color = const Color(0xFFE6C44A)..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(border: Border.all(color: const Color(0xFF8C741A)), borderRadius: BorderRadius.circular(16)),
    child: Text(text, style: const TextStyle(color: Color(0xFFDDBA3E), fontSize: 11, fontWeight: FontWeight.w700)),
  );
}
