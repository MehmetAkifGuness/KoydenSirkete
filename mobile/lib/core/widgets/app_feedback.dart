import 'package:flutter/material.dart';

class AppFeedback {
  AppFeedback._();

  static final Expando<_FeedbackState> _states = Expando<_FeedbackState>();

  static void show(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null || message.trim().isEmpty) return;

    final state = _states[messenger] ??= _FeedbackState();
    final now = DateTime.now();
    if (state.message == message &&
        state.shownAt != null &&
        now.difference(state.shownAt!) < const Duration(milliseconds: 700)) {
      return;
    }
    state.message = message;
    state.shownAt = now;
    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

class _FeedbackState {
  String? message;
  DateTime? shownAt;
}
