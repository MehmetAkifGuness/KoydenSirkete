import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 460);
  static const enterCurve = Curves.easeOutCubic;
  static const exitCurve = Curves.easeInCubic;

  static bool isReduced(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  static Duration duration(BuildContext context, Duration value) =>
      isReduced(context) ? Duration.zero : value;

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

class AppReveal extends StatelessWidget {
  const AppReveal({required this.child, this.offset = 8, super.key});

  final Widget child;
  final double offset;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: AppMotion.duration(context, AppMotion.standard),
    curve: AppMotion.enterCurve,
    child: child,
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, (1 - value) * offset),
        child: child,
      ),
    ),
  );
}
