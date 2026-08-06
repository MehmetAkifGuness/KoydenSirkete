import 'dart:async';

class ForegroundClockTicker {
  ForegroundClockTicker({required this.onTick});

  static const tickInterval = Duration(seconds: 20);
  final Future<void> Function() onTick;
  Timer? _timer;

  void start() {
    if (_timer != null) {
      return;
    }
    _timer = Timer.periodic(tickInterval, (_) => unawaited(onTick()));
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => stop();
}
