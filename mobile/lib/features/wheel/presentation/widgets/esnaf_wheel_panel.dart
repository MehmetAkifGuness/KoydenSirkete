import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/esnaf_wheel_reward.dart';

class EsnafWheelPanel extends StatefulWidget {
  const EsnafWheelPanel({required this.session, super.key});

  final GameSessionController session;

  @override
  State<EsnafWheelPanel> createState() => _EsnafWheelPanelState();
}

class _EsnafWheelPanelState extends State<EsnafWheelPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  late final CurvedAnimation _spinAnimation;
  bool _isSpinning = false;
  double _wheelStartAngle = 0;
  double _wheelEndAngle = 0;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    );
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
    return AppInfoCard(
      accent: AppPalette.tertiary,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppPalette.tertiary.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.casino_rounded,
                  color: AppPalette.tertiary,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Esnaf çarkı',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Şansını dene, avantaj kazan',
                      style: TextStyle(
                        color: AppPalette.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              AppPill(
                label: '${state.wheelMajorRewardsToday}/3 büyük ödül',
                color: AppPalette.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: _WheelView(
              animation: _spinAnimation,
              startAngle: _wheelStartAngle,
              endAngle: _wheelEndAngle,
            ),
          ),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: const [
              AppPill(label: '₺50', color: AppPalette.tertiary),
              AppPill(label: 'Bekleme yok', color: AppPalette.textSecondary),
              AppPill(label: 'İş gerektirmez', color: AppPalette.primary),
            ],
          ),
          if (state.wheelDurationBuffTasks > 0 ||
              state.wheelEnergyBuffTasks > 0 ||
              state.wheelRewardBuffTasks > 0) ...[
            const SizedBox(height: 11),
            Text(
              _buffText(state),
              style: const TextStyle(
                color: AppPalette.primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed:
                  availability.isAvailable &&
                      !_isSpinning &&
                      !widget.session.isBusy
                  ? () => _spin(context)
                  : null,
              icon: Icon(
                _isSpinning
                    ? Icons.hourglass_top_rounded
                    : Icons.casino_rounded,
              ),
              label: Text(_isSpinning ? 'Çark dönüyor…' : 'Çarkı çevir · ₺50'),
            ),
          ),
          if (!availability.isAvailable && !_isSpinning) ...[
            const SizedBox(height: 8),
            Text(
              availability.reason,
              style: const TextStyle(color: AppPalette.warning, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  String _buffText(PlayerState state) {
    final parts = <String>[];
    if (state.wheelDurationBuffTasks > 0) {
      parts.add(
        'Süre -%${state.wheelDurationBuffPercent} · ${state.wheelDurationBuffTasks} görev',
      );
    }
    if (state.wheelEnergyBuffTasks > 0) {
      parts.add(
        'Enerji -%${state.wheelEnergyBuffPercent} · ${state.wheelEnergyBuffTasks} görev',
      );
    }
    if (state.wheelRewardBuffTasks > 0) {
      parts.add('Kazanç x2 · ${state.wheelRewardBuffTasks} görev');
    }
    return parts.join('  |  ');
  }

  Future<void> _spin(BuildContext context) async {
    setState(() => _isSpinning = true);
    final outcome = await widget.session.spinWheel();
    if (!mounted) return;
    if (outcome == null) {
      setState(() => _isSpinning = false);
      return;
    }
    setState(() {
      _wheelStartAngle = _wheelEndAngle;
      _wheelEndAngle = _nextAngle(outcome.sectorIndex);
    });
    await _spinController.forward(from: 0);
    if (!context.mounted) return;
    setState(() => _isSpinning = false);
    AppFeedback.show(context, outcome.message);
  }

  double _nextAngle(int sectorIndex) {
    const fullTurn = math.pi * 2;
    final slice = fullTurn / EsnafWheelRewardCatalog.sectorTypes.length;
    final targetAngle = -((sectorIndex + .5) * slice);
    final currentAngle = _wheelEndAngle % fullTurn;
    return _wheelEndAngle +
        fullTurn * 6 +
        (targetAngle - currentAngle) % fullTurn;
  }
}

class _WheelView extends StatelessWidget {
  const _WheelView({
    required this.animation,
    required this.startAngle,
    required this.endAngle,
  });

  final Animation<double> animation;
  final double startAngle;
  final double endAngle;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 224,
    height: 224,
    child: Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: animation,
          builder: (_, _) => Transform.rotate(
            angle: startAngle + (endAngle - startAngle) * animation.value,
            child: const CustomPaint(
              size: Size.square(208),
              painter: _WheelPainter(),
            ),
          ),
        ),
        const Align(
          alignment: Alignment.topCenter,
          child: Icon(
            Icons.arrow_drop_down_rounded,
            size: 32,
            color: AppPalette.primaryBright,
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppPalette.surfaceMuted,
            shape: BoxShape.circle,
            border: Border.all(color: AppPalette.primaryBright, width: 2),
          ),
          child: const Icon(
            Icons.casino_rounded,
            size: 16,
            color: AppPalette.primaryBright,
          ),
        ),
      ],
    ),
  );
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sectors = EsnafWheelRewardCatalog.sectorTypes;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius - 3);
    final slice = math.pi * 2 / sectors.length;
    for (var index = 0; index < sectors.length; index++) {
      final type = sectors[index];
      final start = -math.pi / 2 + index * slice;
      canvas.drawArc(rect, start, slice, true, Paint()..color = _color(type));
      canvas.drawArc(
        rect,
        start,
        slice,
        true,
        Paint()
          ..color = AppPalette.background.withValues(alpha: .72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: EsnafWheelRewardCatalog.byType(type).title.toUpperCase(),
          style: TextStyle(
            color: type == EsnafWheelRewardType.bigTender
                ? AppPalette.background
                : AppPalette.textPrimary,
            fontSize: 7,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final angle = start + slice / 2;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      textPainter.paint(
        canvas,
        Offset(radius * .58 - textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
    canvas.drawCircle(
      center,
      radius - 3,
      Paint()
        ..color = AppPalette.primaryBright
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  Color _color(EsnafWheelRewardType type) => switch (type) {
    EsnafWheelRewardType.empty => AppPalette.wheelEmpty,
    EsnafWheelRewardType.bigTender => AppPalette.wheelTender,
    EsnafWheelRewardType.luckyDay => AppPalette.wheelChance,
    EsnafWheelRewardType.tipRain => AppPalette.wheelGain,
    EsnafWheelRewardType.smallTip => AppPalette.wheelSmallGain,
    EsnafWheelRewardType.customerPenalty => AppPalette.wheelPenalty,
    EsnafWheelRewardType.majorPenalty => AppPalette.wheelMajorPenalty,
  };

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}
