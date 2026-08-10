import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../app/theme/app_palette.dart';

import '../../../../core/widgets/app_feedback.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/esnaf_wheel_reward.dart';

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
  double _wheelStartAngle = 0;
  double _wheelEndAngle = 0;

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
            const Expanded(child: Text('İş Çarkı', style: TextStyle(fontFamily: 'serif', fontSize: 19, fontWeight: FontWeight.w700))),
            Text('${state.wheelMajorRewardsToday}/3 büyük ödül', style: TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          const Text('20 dilimde şansını dene.', style: TextStyle(color: AppPalette.textSecondary)),
          const SizedBox(height: 10),
          Center(child: _Wheel(animation: _spinAnimation, startAngle: _wheelStartAngle, endAngle: _wheelEndAngle)),
          Wrap(spacing: 8, runSpacing: 8, children: [
            const _InfoPill(text: '50 TL'),
            const _InfoPill(text: 'Bekleme yok'),
            const _InfoPill(text: 'İş gerektirmez'),
          ]),
          if (state.wheelDurationBuffTasks > 0 || state.wheelEnergyBuffTasks > 0 || state.wheelRewardBuffTasks > 0) ...[
            const SizedBox(height: 10),
            Text(_buffText(state), style: TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: availability.isAvailable && !_isSpinning && !widget.session.isBusy ? () => _spin(context) : null,
              icon: Icon(_isSpinning ? Icons.hourglass_top : Icons.casino_outlined),
              label: Text(_isSpinning ? 'Çark dönüyor...' : 'Çarkı çevir · 50 TL'),
            ),
          ),
          if (!availability.isAvailable && !_isSpinning) ...[
            const SizedBox(height: 8),
            Text(availability.reason, style: const TextStyle(color: AppPalette.warning, fontSize: 12)),
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
    if (state.wheelRewardBuffTasks > 0) {
      parts.add('Kazanç x2 · ${state.wheelRewardBuffTasks} görev');
    }
    return parts.join('  |  ');
  }

  Future<void> _spin(BuildContext context) async {
    setState(() => _isSpinning = true);
    final outcome = await widget.session.spinWheel();
    if (!mounted) {
      return;
    }
    if (outcome == null) {
      setState(() => _isSpinning = false);
      return;
    }
    setState(() {
      _wheelStartAngle = _wheelEndAngle;
      _wheelEndAngle = _nextAngle(outcome.sectorIndex);
    });
    await _spinController.forward(from: 0);
    if (!context.mounted) {
      return;
    }
    setState(() => _isSpinning = false);
    AppFeedback.show(context, outcome.message);
  }

  double _nextAngle(int sectorIndex) {
    const fullTurn = math.pi * 2;
    final slice = fullTurn / EsnafWheelRewardCatalog.sectorTypes.length;
    final targetAngle = -((sectorIndex + .5) * slice);
    final currentAngle = _wheelEndAngle % fullTurn;
    final correction = (targetAngle - currentAngle) % fullTurn;
    return _wheelEndAngle + fullTurn * 6 + correction;
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel({required this.animation, required this.startAngle, required this.endAngle});

  final Animation<double> animation;
  final double startAngle;
  final double endAngle;

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
              angle: startAngle + (endAngle - startAngle) * animation.value,
              child: const CustomPaint(size: Size.square(220), painter: _WheelPainter()),
            ),
          ),
          Align(alignment: Alignment.topCenter, child: Icon(Icons.arrow_drop_down, size: 34, color: AppPalette.primaryBright)),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: AppPalette.surfaceMuted, shape: BoxShape.circle, border: Border.all(color: AppPalette.primaryBright, width: 2)),
            child: Icon(Icons.casino, size: 17, color: AppPalette.primaryBright),
          ),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter();

  static const _labels = [
    'İHALE', 'BOŞ', '-50 TL', 'BOŞ', '-50 TL', 'ŞANS', 'BOŞ', '-50 TL', 'BOŞ', 'BOŞ',
    '100 TL', 'BOŞ', '-50 TL', 'BOŞ', 'BOŞ', '100 TL', 'BOŞ', '-50 TL', 'BOŞ', 'BOŞ',
  ];
  static List<Color> get _colors => [
    AppPalette.primaryBright, AppPalette.wheelRisk, AppPalette.wheelNeutral, AppPalette.surfaceElevated, AppPalette.wheelRisk,
    AppPalette.primaryDim, AppPalette.wheelRisk, AppPalette.wheelNeutral, AppPalette.surfaceElevated, AppPalette.wheelRisk,
    AppPalette.primary, AppPalette.wheelNeutral, AppPalette.wheelRisk, AppPalette.surfaceElevated, AppPalette.wheelRisk,
    AppPalette.primaryBright, AppPalette.wheelNeutral, AppPalette.wheelRisk, AppPalette.surfaceElevated, AppPalette.wheelRisk,
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
        text: TextSpan(text: _labels[index], style: TextStyle(color: index == 0 || index == 5 || index == 10 || index == 15 ? AppPalette.background : AppPalette.textPrimary, fontSize: 7, fontWeight: FontWeight.w800)),
        textDirection: TextDirection.ltr,
      )..layout();
      final textCenter = Offset(center.dx + math.cos(angle) * radius * .61, center.dy + math.sin(angle) * radius * .61);
      textPainter.paint(canvas, textCenter - Offset(textPainter.width / 2, textPainter.height / 2));
    }
    canvas.drawCircle(center, radius - 3, Paint()..color = AppPalette.primaryBright..style = PaintingStyle.stroke..strokeWidth = 3);
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
    decoration: BoxDecoration(border: Border.all(color: AppPalette.outline), borderRadius: BorderRadius.circular(16)),
    child: Text(text, style: TextStyle(color: AppPalette.primary, fontSize: 11, fontWeight: FontWeight.w700)),
  );
}
