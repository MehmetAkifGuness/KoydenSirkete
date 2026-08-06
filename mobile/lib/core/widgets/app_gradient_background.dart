import 'package:flutter/material.dart';

class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, .42, 1],
          colors: [
            Color(0xFF050505),
            Color(0xFF0B0A06),
            Color(0xFF050505),
          ],
        ),
      ),
      child: child,
    );
  }
}
