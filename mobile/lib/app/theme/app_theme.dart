import 'package:flutter/material.dart';

import 'app_palette.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    final seed = AppPalette.primary;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      surface: AppPalette.background,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: AppPalette.primary,
        onPrimary: AppPalette.background,
        primaryContainer: AppPalette.primaryDim,
        onPrimaryContainer: AppPalette.textPrimary,
        secondary: AppPalette.secondary,
        onSecondary: AppPalette.background,
        secondaryContainer: AppPalette.surfaceElevated,
        onSecondaryContainer: AppPalette.textPrimary,
        tertiary: AppPalette.tertiary,
        onTertiary: AppPalette.background,
        surface: AppPalette.background,
        onSurface: AppPalette.textPrimary,
        surfaceContainerHighest: AppPalette.surfaceElevated,
        outline: AppPalette.outline,
        error: AppPalette.error,
      ),
      scaffoldBackgroundColor: AppPalette.background.withValues(alpha: .94),
      canvasColor: AppPalette.background.withValues(alpha: .94),
      fontFamily: 'sans-serif',
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: AppPalette.textPrimary, fontSize: 16, height: 1.45),
        bodyMedium: TextStyle(color: AppPalette.textSecondary, fontSize: 14, height: 1.4),
        bodySmall: TextStyle(color: AppPalette.textMuted, fontSize: 12),
        titleLarge: TextStyle(color: AppPalette.textPrimary, fontFamily: 'serif', fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: AppPalette.textPrimary, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: AppPalette.primary, fontFamily: 'serif', fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: AppPalette.primary, fontFamily: 'serif', fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppPalette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppPalette.primary),
        titleTextStyle: TextStyle(color: AppPalette.primary, fontFamily: 'serif', fontSize: 23, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: AppPalette.surface,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppPalette.outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.primary,
          foregroundColor: AppPalette.background,
          disabledBackgroundColor: AppPalette.primaryDim,
          disabledForegroundColor: AppPalette.textMuted,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.primary,
          minimumSize: const Size(0, 48),
          side: BorderSide(color: AppPalette.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppPalette.primary,
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppPalette.primary),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppPalette.primary,
        textColor: AppPalette.textPrimary,
        subtitleTextStyle: const TextStyle(color: AppPalette.textSecondary, height: 1.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.surfaceMuted,
        labelStyle: const TextStyle(color: AppPalette.textMuted),
        floatingLabelStyle: TextStyle(color: AppPalette.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppPalette.outlineMuted)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppPalette.outlineMuted)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppPalette.primary, width: 2)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppPalette.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(color: AppPalette.textPrimary, fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.w700),
        contentTextStyle: const TextStyle(color: AppPalette.textSecondary, height: 1.4),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppPalette.surfaceMuted,
        side: BorderSide(color: AppPalette.outline),
        labelStyle: TextStyle(color: AppPalette.primary, fontSize: 11, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppPalette.background,
        surfaceTintColor: Colors.transparent,
        height: 76,
        indicatorColor: AppPalette.primary.withValues(alpha: .2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: states.contains(WidgetState.selected) ? AppPalette.primary : AppPalette.textMuted)),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(color: states.contains(WidgetState.selected) ? AppPalette.primary : AppPalette.textMuted)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: AppPalette.primary, linearTrackColor: AppPalette.track),
      dividerColor: AppPalette.outlineMuted,
      snackBarTheme: SnackBarThemeData(backgroundColor: AppPalette.surfaceElevated, contentTextStyle: TextStyle(color: AppPalette.textPrimary)),
    );
  }
}
