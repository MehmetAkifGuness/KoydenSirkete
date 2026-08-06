import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    const seed = Color(0xFFDDBA3E);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      surface: Color(0xFF050505),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: const Color(0xFFDDBA3E),
        onPrimary: const Color(0xFF080808),
        secondary: const Color(0xFFDDBA3E),
        surface: const Color(0xFF050505),
        onSurface: const Color(0xFFE8E2D5),
      ),
      scaffoldBackgroundColor: const Color(0xFF050505),
      canvasColor: const Color(0xFF050505),
      fontFamily: 'sans-serif',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFE8E2D5), fontSize: 16, height: 1.45),
        bodyMedium: TextStyle(color: Color(0xFFD1C9B8), fontSize: 14, height: 1.4),
        bodySmall: TextStyle(color: Color(0xFF9F988B), fontSize: 12),
        titleLarge: TextStyle(color: Color(0xFFE8E2D5), fontFamily: 'serif', fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: Color(0xFFE8E2D5), fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: Color(0xFFDDBA3E), fontFamily: 'serif', fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: Color(0xFFDDBA3E), fontFamily: 'serif', fontWeight: FontWeight.w700),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF050505),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFFDDBA3E)),
        titleTextStyle: TextStyle(color: Color(0xFFDDBA3E), fontFamily: 'serif', fontSize: 23, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF050505),
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFDDBA3E)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFDDBA3E),
          foregroundColor: const Color(0xFF080808),
          disabledBackgroundColor: const Color(0xFF544A23),
          disabledForegroundColor: const Color(0xFF171511),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFDDBA3E),
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: Color(0xFFDDBA3E)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF090909),
        side: const BorderSide(color: Color(0xFFDDBA3E)),
        labelStyle: const TextStyle(color: Color(0xFFDDBA3E), fontSize: 11, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF050505),
        surfaceTintColor: Colors.transparent,
        height: 76,
        indicatorColor: const Color(0x332D2607),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: states.contains(WidgetState.selected) ? const Color(0xFFDDBA3E) : const Color(0xFF9F988B))),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(color: states.contains(WidgetState.selected) ? const Color(0xFFDDBA3E) : const Color(0xFF9F988B))),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: Color(0xFFDDBA3E), linearTrackColor: Color(0xFF393B3D)),
      dividerColor: const Color(0xFF302A12),
      snackBarTheme: const SnackBarThemeData(backgroundColor: Color(0xFF19160D), contentTextStyle: TextStyle(color: Color(0xFFE8E2D5))),
    );
  }
}
