import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/earning_performance.dart';
import '../../domain/services/earning_mini_game_service.dart';

enum EarningMiniGamePhase { idle, playing, completed }

class EarningMiniGameState {
  const EarningMiniGameState({required this.phase, required this.hits, required this.secondsRemaining});

  static const initial = EarningMiniGameState(
    phase: EarningMiniGamePhase.idle,
    hits: 0,
    secondsRemaining: EarningMiniGameService.durationSeconds,
  );

  final EarningMiniGamePhase phase;
  final int hits;
  final int secondsRemaining;

  EarningMiniGameState copyWith({EarningMiniGamePhase? phase, int? hits, int? secondsRemaining}) {
    return EarningMiniGameState(
      phase: phase ?? this.phase,
      hits: hits ?? this.hits,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    );
  }
}

class EarningMiniGameController extends ChangeNotifier {
  EarningMiniGameController({EarningMiniGameService? service}) : _service = service ?? EarningMiniGameService();

  final EarningMiniGameService _service;
  Timer? _timer;
  EarningMiniGameState _state = EarningMiniGameState.initial;

  EarningMiniGameState get state => _state;
  EarningPerformance get performance => _service.performanceFor(_state.hits);
  int get bonusPercent => _service.bonusPercent(performance);

  void start() {
    _timer?.cancel();
    _state = EarningMiniGameState.initial.copyWith(phase: EarningMiniGamePhase.playing);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void hit() {
    if (_state.phase != EarningMiniGamePhase.playing || _state.hits >= EarningMiniGameService.maxHits) {
      return;
    }
    _state = _state.copyWith(hits: _state.hits + 1);
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
