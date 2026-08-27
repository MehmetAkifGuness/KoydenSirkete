import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';

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
          colors: [
            AppPalette.background,
            AppPalette.backgroundElevated,
            AppPalette.background,
          ],
          stops: [0, .48, 1],
        ),
      ),
      child: child,
    );
  }
}
