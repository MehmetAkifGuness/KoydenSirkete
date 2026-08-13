import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';

class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: AppPalette.background, child: child);
  }
}
