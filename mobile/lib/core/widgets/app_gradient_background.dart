import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';

class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, .42, 1],
          colors: [
            AppPalette.background,
            AppPalette.surface,
            AppPalette.surfaceElevated,
          ],
        ),
      ),
      child: child,
    );
  }
}
