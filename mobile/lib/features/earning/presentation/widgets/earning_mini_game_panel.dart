import 'package:flutter/material.dart';

import '../../../game/presentation/state/game_session_controller.dart';
import '../state/earning_mini_game_controller.dart';

const _targetPositions = [
  Alignment.center,
  Alignment.topLeft,
  Alignment.bottomRight,
  Alignment.topRight,
  Alignment.bottomLeft,
];

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
      builder: (context, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: _content(context, _game.state),
        ),
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
        const Text('Hızlı görev', style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 8),
        const Text('8 saniye içinde hedefe dokun. Seri yaptıkça kazanç bonusun artar.'),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: widget.session.isBusy || widget.session.state.activeActivity != null ? null : _game.start,
            icon: const Icon(Icons.bolt),
            label: const Text('Görevi başlat'),
          ),
        ),
      ],
    );
  }

  Widget _playing(BuildContext context, EarningMiniGameState state) {
    final position = _targetPositions[state.hits % _targetPositions.length];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Süre: ${state.secondsRemaining}s'),
            Text('Seri: ${state.hits}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: AnimatedAlign(
            alignment: position,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: SizedBox(
              width: 92,
              height: 92,
              child: FilledButton(
                onPressed: _game.hit,
                style: FilledButton.styleFrom(shape: const CircleBorder(), padding: EdgeInsets.zero),
                child: const Icon(Icons.touch_app_outlined, size: 32),
              ),
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
        const Text('Tur tamamlandı', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 8),
        Text('${state.hits} dokunuş · +%${_game.bonusPercent} seri bonusu'),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: widget.session.isBusy || widget.session.state.activeActivity != null ? null : _collect,
            icon: const Icon(Icons.payments_outlined),
            label: const Text('Kazancı al'),
          ),
        ),
      ],
    );
  }

  Future<void> _collect() async {
    final message = await widget.session.earnMoney(performance: _game.performance);
    if (!mounted) {
      return;
    }
    _game.reset();
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
