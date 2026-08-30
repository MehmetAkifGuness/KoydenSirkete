import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppFeedbackPreferences extends ChangeNotifier {
  AppFeedbackPreferences._();

  static final instance = AppFeedbackPreferences._();

  bool soundEffectsEnabled = true;
  bool hapticsEnabled = true;

  static const _channel = MethodChannel('com.koydensirkete/feedback');

  void configure({required bool soundEffects, required bool haptics}) {
    soundEffectsEnabled = soundEffects;
    hapticsEnabled = haptics;
  }

  void setSoundEffects(bool value) {
    if (soundEffectsEnabled == value) return;
    soundEffectsEnabled = value;
    notifyListeners();
  }

  void setHaptics(bool value) {
    if (hapticsEnabled == value) return;
    hapticsEnabled = value;
    notifyListeners();
  }

  void emitInteraction() {
    if (soundEffectsEnabled) unawaited(_playSound());
    if (hapticsEnabled) unawaited(_vibrate());
  }

  Future<void> previewSound() => _playSound();

  Future<void> previewHaptic() => _vibrate();

  Future<void> _playSound() async {
    try {
      await _channel.invokeMethod<void>('playClick');
    } on MissingPluginException {
      await SystemSound.play(SystemSoundType.click);
    } on PlatformException {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> _vibrate() async {
    try {
      await _channel.invokeMethod<void>('vibrate');
    } on MissingPluginException {
      await HapticFeedback.mediumImpact();
    } on PlatformException {
      await HapticFeedback.mediumImpact();
    }
  }
}
