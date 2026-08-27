import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 460);
  static const enterCurve = Curves.easeOutCubic;
  static const exitCurve = Curves.easeInCubic;

  static Widget fadeSlide(
    Widget child,
    Animation<double> animation, {
    Offset begin = const Offset(0, .025),
  }) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: enterCurve,
      reverseCurve: exitCurve,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  }
}
