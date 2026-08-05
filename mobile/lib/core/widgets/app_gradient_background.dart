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
          stops: [0, .34, .7, 1],
          colors: [
            Color(0xFF06150E),
            Color(0xFF0B2D1C),
            Color(0xFF145536),
            Color(0xFF2D8A58),
          ],
        ),
      ),
      child: child,
    );
  }
}
