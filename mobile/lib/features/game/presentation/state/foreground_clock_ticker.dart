import 'dart:async';

class ForegroundClockTicker {
  ForegroundClockTicker({required this.onTick, required this.interval});

  final Future<void> Function() onTick;
  final Duration interval;
  Timer? _timer;
  bool _tickInProgress = false;

  void start() {
    if (_timer != null) {
      return;
    }
    _timer = Timer.periodic(interval, (_) => _runTick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => stop();

  void _runTick() {
    if (_tickInProgress) {
      return;
    }
    _tickInProgress = true;
    unawaited(onTick().whenComplete(() => _tickInProgress = false));
  }
}
