import 'package:flutter/material.dart';

import 'app_motion.dart';

class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return child;
    final exitScale = Tween<double>(begin: 1, end: .985).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOutCubic),
    );
    return ScaleTransition(
      scale: exitScale,
      child: AppMotion.fadeSlide(
        child,
        animation,
        begin: const Offset(.055, 0),
      ),
    );
  }
}
