import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppFeedbackPreferences extends ChangeNotifier {
  AppFeedbackPreferences._();

  static final instance = AppFeedbackPreferences._();

  bool soundEffectsEnabled = true;
  bool hapticsEnabled = true;

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

  Future<void> _playSound() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } on PlatformException {
      // Unsupported platforms continue without optional feedback.
    }
  }

  Future<void> _vibrate() async {
    try {
      await HapticFeedback.selectionClick();
    } on PlatformException {
      // Unsupported platforms continue without optional feedback.
    }
  }
}
