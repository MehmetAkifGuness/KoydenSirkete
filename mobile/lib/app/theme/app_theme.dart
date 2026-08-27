import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_page_transitions_builder.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    final colors =
        ColorScheme.fromSeed(
          seedColor: AppPalette.primary,
          brightness: Brightness.dark,
          surface: AppPalette.background,
        ).copyWith(
          primary: AppPalette.primary,
          onPrimary: AppPalette.background,
          primaryContainer: AppPalette.surfaceMuted,
          onPrimaryContainer: AppPalette.textPrimary,
          secondary: AppPalette.secondary,
          onSecondary: AppPalette.background,
          secondaryContainer: AppPalette.surfaceMuted,
          onSecondaryContainer: AppPalette.textPrimary,
          tertiary: AppPalette.tertiary,
          onTertiary: AppPalette.background,
          surface: AppPalette.background,
          surfaceContainer: AppPalette.surface,
          surfaceContainerHighest: AppPalette.surfaceElevated,
          onSurface: AppPalette.textPrimary,
          onSurfaceVariant: AppPalette.textSecondary,
          outline: AppPalette.outline,
          error: AppPalette.error,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: AppPalette.background,
      fontFamily: 'sans-serif',
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppPageTransitionsBuilder(),
          TargetPlatform.iOS: AppPageTransitionsBuilder(),
          TargetPlatform.windows: AppPageTransitionsBuilder(),
          TargetPlatform.macOS: AppPageTransitionsBuilder(),
          TargetPlatform.linux: AppPageTransitionsBuilder(),
        },
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: AppPalette.textPrimary,
          fontSize: 36,
          fontWeight: FontWeight.w800,
          letterSpacing: -.8,
        ),
        headlineMedium: TextStyle(
          color: AppPalette.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -.5,
        ),
        headlineSmall: TextStyle(
          color: AppPalette.textPrimary,
          fontSize: 23,
          fontWeight: FontWeight.w800,
          letterSpacing: -.3,
        ),
        titleLarge: TextStyle(
          color: AppPalette.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: AppPalette.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        titleSmall: TextStyle(
          color: AppPalette.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: AppPalette.textPrimary,
          fontSize: 16,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          color: AppPalette.textSecondary,
          fontSize: 14,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: AppPalette.textMuted,
          fontSize: 12,
          height: 1.35,
        ),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppPalette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppPalette.textSecondary),
        titleTextStyle: TextStyle(
          color: AppPalette.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppPalette.surface,
        margin: EdgeInsets.zero,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppPalette.outlineMuted),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.primary,
          foregroundColor: AppPalette.background,
          disabledBackgroundColor: AppPalette.surfaceMuted,
          disabledForegroundColor: AppPalette.textDisabled,
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.textPrimary,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: const BorderSide(color: AppPalette.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppPalette.primary,
          minimumSize: const Size(0, 42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppPalette.textSecondary),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppPalette.primary,
        textColor: AppPalette.textPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        subtitleTextStyle: const TextStyle(
          color: AppPalette.textSecondary,
          height: 1.35,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.surfaceMuted,
        labelStyle: const TextStyle(color: AppPalette.textMuted),
        floatingLabelStyle: const TextStyle(color: AppPalette.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.outlineMuted),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.outlineMuted),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.primary, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppPalette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titleTextStyle: const TextStyle(
          color: AppPalette.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: const TextStyle(
          color: AppPalette.textSecondary,
          height: 1.4,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppPalette.surfaceMuted,
        selectedColor: AppPalette.primary.withValues(alpha: .18),
        side: const BorderSide(color: AppPalette.outlineMuted),
        labelStyle: const TextStyle(
          color: AppPalette.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppPalette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? AppPalette.primary
                : AppPalette.textMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppPalette.primary
                : AppPalette.textMuted,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppPalette.primary,
        linearTrackColor: AppPalette.track,
      ),
      dividerColor: AppPalette.outlineMuted,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppPalette.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: const TextStyle(
          color: AppPalette.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
