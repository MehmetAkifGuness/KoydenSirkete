import 'dart:async';

class ForegroundClockTicker {
  ForegroundClockTicker({required this.onTick, required this.interval});

  final Future<void> Function() onTick;
  final Duration interval;
  Timer? _timer;

  void start() {
    if (_timer != null) {
      return;
    }
    _timer = Timer.periodic(interval, (_) => unawaited(onTick()));
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => stop();
}
