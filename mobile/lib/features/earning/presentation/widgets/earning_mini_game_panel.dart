import 'package:flutter/material.dart';

import '../../../../app/theme/app_motion.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/services/earning_mini_game_service.dart';
import '../../domain/services/earning_service.dart';
import '../state/earning_mini_game_controller.dart';

const _targetCellCount = EarningMiniGameService.cellCount;

class EarningMiniGamePanel extends StatefulWidget {
  const EarningMiniGamePanel({required this.session, super.key});

  final GameSessionController session;

  @override
  State<EarningMiniGamePanel> createState() => _EarningMiniGamePanelState();
}

class _EarningMiniGamePanelState extends State<EarningMiniGamePanel> {
  final EarningMiniGameController _game = EarningMiniGameController();

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _game,
      builder: (context, _) => AppInfoCard(
        accent: AppPalette.primary,
        padding: const EdgeInsets.all(18),
        child: _content(context, _game.state),
      ),
    );
  }

  Widget _content(BuildContext context, EarningMiniGameState state) {
    return switch (state.phase) {
      EarningMiniGamePhase.idle => _idle(context),
      EarningMiniGamePhase.playing => _playing(context, state),
      EarningMiniGamePhase.completed => _completed(context, state),
    };
  }

  Widget _idle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppPalette.primary.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.touch_app_rounded,
                color: AppPalette.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Hızlı görev',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            const AppPill(label: '+ bonus', color: AppPalette.tertiary),
          ],
        ),
        const SizedBox(height: 13),
        const Text(
          'İlk 10 doğru dokunuş kazancı %50 artırır. Sonraki seri %10 büyür; ödül en fazla 3 katına çıkar. Günde 4 ücretli tur yapılabilir.',
          style: TextStyle(
            color: AppPalette.textSecondary,
            fontSize: 13,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 17),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed:
                widget.session.isBusy ||
                    !widget.session.state.hasActivityCapacity ||
                    widget.session.state.earningSessionsToday >=
                        EarningService.maxPaidSessionsPerDay
                ? null
                : _game.start,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Görevi başlat'),
          ),
        ),
      ],
    );
  }

  Widget _playing(BuildContext context, EarningMiniGameState state) {
    return Column(
      children: [
        Row(
          children: [
            const AppPill(
              label: 'HEDEFİ BUL',
              color: AppPalette.primary,
              icon: Icons.track_changes_rounded,
            ),
            const Spacer(),
            Text(
              '${state.secondsRemaining}s',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 12),
            Text(
              '${state.hits} seri',
              style: const TextStyle(
                color: AppPalette.tertiary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 228,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _targetCellCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: 70,
            ),
            itemBuilder: (context, index) => _TargetCell(
              active: index == state.targetCell,
              onTap: _game.hit,
            ),
          ),
        ),
      ],
    );
  }

  Widget _completed(BuildContext context, EarningMiniGameState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppPalette.tertiary.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.celebration_rounded,
                color: AppPalette.tertiary,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Tur tamamlandı',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '+%${_game.bonusPercent}',
              style: const TextStyle(
                color: AppPalette.tertiary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '${state.hits} doğru dokunuş yaptın. Seri bonusun kazanca eklendi.',
          style: const TextStyle(color: AppPalette.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed:
                widget.session.isBusy ||
                    !widget.session.state.hasActivityCapacity
                ? null
                : _collect,
            icon: const Icon(Icons.payments_rounded),
            label: const Text('Kazancı al'),
          ),
        ),
      ],
    );
  }

  Future<void> _collect() async {
    final message = await widget.session.earnMoney(
      performance: _game.performance,
    );
    if (!mounted) return;
    _game.reset();
    if (message != null) AppFeedback.show(context, message);
  }
}

class _TargetCell extends StatelessWidget {
  const _TargetCell({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.duration(context, AppMotion.fast),
      decoration: BoxDecoration(
        color: active
            ? AppPalette.primary.withValues(alpha: .13)
            : AppPalette.surfaceMuted,
        border: Border.all(
          color: active ? AppPalette.primary : AppPalette.outlineMuted,
          width: active ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: AppMotion.duration(context, AppMotion.fast),
          child: active
              ? SizedBox(
                  key: const ValueKey('target'),
                  width: 54,
                  height: 54,
                  child: FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.touch_app_rounded, size: 24),
                  ),
                )
              : const SizedBox(key: ValueKey('empty')),
        ),
      ),
    );
  }
}
