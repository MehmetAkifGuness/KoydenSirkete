import 'package:flutter/material.dart';

class AppPaletteScheme {
  const AppPaletteScheme({
    required this.id,
    required this.name,
    required this.background,
    required this.surface,
  });

  final int id;
  final String name;
  final Color background;
  final Color surface;
}

abstract final class AppPalette {
  static const background = Color(0xFF171D2B);
  static const surface = Color(0xFF202839);
  static const surfaceElevated = Color(0xFF283245);
  static const surfaceMuted = Color(0xFF30384A);
  static const outline = Color(0xFF4A5364);
  static const outlineMuted = Color(0xFF343D4F);
  static const track = Color(0xFF30384A);

  static const primary = Color(0xFFE1C878);
  static const primaryBright = Color(0xFFF4DEA0);
  static const primaryDim = Color(0xFFAF9955);
  static const secondary = Color(0xFF30384A);
  static const tertiary = Color(0xFFE3A15A);

  static const textPrimary = Color(0xFFF4F0E6);
  static const textSecondary = Color(0xFFB4BAC5);
  static const textMuted = Color(0xFF7E8798);
  static const success = Color(0xFF72C59B);
  static const warning = Color(0xFFE2B65B);
  static const error = Color(0xFFDC716C);
  static const wheelNeutral = Color(0xFF566277);
  static const wheelRisk = Color(0xFF9E5E66);

  static final schemes = List<AppPaletteScheme>.unmodifiable([
    for (var id = 0; id < 10; id++)
      AppPaletteScheme(
        id: id,
        name: 'Legacy $id',
        background: Color(0xFF171D2B + id),
        surface: Color(0xFF202839 + id),
      ),
  ]);
}
