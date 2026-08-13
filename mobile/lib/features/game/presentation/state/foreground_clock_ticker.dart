import 'dart:async';

class ForegroundClockTicker {
  ForegroundClockTicker({required this.onTick, required this.interval});

  final Future<void> Function() onTick;
  Duration interval;
  Timer? _timer;
  bool _tickInProgress = false;

  bool get isRunning => _timer != null;

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

  void updateInterval(Duration value) {
    if (interval == value) {
      return;
    }
    final wasRunning = isRunning;
    stop();
    interval = value;
    if (wasRunning) {
      start();
    }
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
