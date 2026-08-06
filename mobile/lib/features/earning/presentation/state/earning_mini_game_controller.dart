import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../domain/entities/earning_performance.dart';
import '../../domain/services/earning_mini_game_service.dart';

enum EarningMiniGamePhase { idle, playing, completed }

class EarningMiniGameState {
  const EarningMiniGameState({required this.phase, required this.hits, required this.secondsRemaining, this.targetCell = 0});

  static const initial = EarningMiniGameState(
    phase: EarningMiniGamePhase.idle,
    hits: 0,
    secondsRemaining: EarningMiniGameService.durationSeconds,
  );

  final EarningMiniGamePhase phase;
  final int hits;
  final int secondsRemaining;
  final int targetCell;

  EarningMiniGameState copyWith({EarningMiniGamePhase? phase, int? hits, int? secondsRemaining, int? targetCell}) {
    return EarningMiniGameState(
      phase: phase ?? this.phase,
      hits: hits ?? this.hits,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      targetCell: targetCell ?? this.targetCell,
    );
  }
}

class EarningMiniGameController extends ChangeNotifier {
  EarningMiniGameController({EarningMiniGameService? service, Random? random})
      : _service = service ?? EarningMiniGameService(),
        _random = random ?? Random();

  final EarningMiniGameService _service;
  final Random _random;
  Timer? _timer;
  EarningMiniGameState _state = EarningMiniGameState.initial;

  EarningMiniGameState get state => _state;
  EarningPerformance get performance => _service.performanceFor(_state.hits);
  int get bonusPercent => _service.bonusPercent(performance);

  void start() {
    _timer?.cancel();
    _state = EarningMiniGameState.initial.copyWith(
      phase: EarningMiniGamePhase.playing,
      targetCell: _random.nextInt(EarningMiniGameService.cellCount),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void hit() {
    if (_state.phase != EarningMiniGamePhase.playing || _state.hits >= EarningMiniGameService.maxHits) {
      return;
    }
    _state = _state.copyWith(hits: _state.hits + 1, targetCell: _nextTargetCell(_state.targetCell));
    notifyListeners();
  }

  void complete() {
    if (_state.phase != EarningMiniGamePhase.playing) {
      return;
    }
    _timer?.cancel();
    _timer = null;
    _state = _state.copyWith(phase: EarningMiniGamePhase.completed, secondsRemaining: 0);
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _state = EarningMiniGameState.initial;
    notifyListeners();
  }

  void _tick() {
    if (_state.secondsRemaining <= 1) {
      complete();
      return;
    }
    _state = _state.copyWith(secondsRemaining: _state.secondsRemaining - 1);
    notifyListeners();
  }

  int _nextTargetCell(int currentCell) {
    final candidate = _random.nextInt(EarningMiniGameService.cellCount - 1);
    return candidate >= currentCell ? candidate + 1 : candidate;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
