import 'package:flutter/material.dart';

abstract final class NetubeColors {
  static const background = Color(0xFF050505);
  static const surface = Color(0xFF111111);
  static const surfaceHigh = Color(0xFF1A1A1A);
  static const accent = Color(0xFFE50914);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
  static const divider = Color(0xFF292929);
}

abstract final class NetubeTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: NetubeColors.accent,
      brightness: Brightness.dark,
      surface: NetubeColors.surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme.copyWith(primary: NetubeColors.accent),
      scaffoldBackgroundColor: NetubeColors.background,
      canvasColor: NetubeColors.background,
      dividerColor: NetubeColors.divider,
      appBarTheme: const AppBarTheme(
        backgroundColor: NetubeColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        headlineSmall: TextStyle(fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: NetubeColors.textSecondary, height: 1.45),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NetubeColors.surfaceHigh,
        hintStyle: const TextStyle(color: NetubeColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NetubeColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: NetubeColors.accent,
      ),
    );
  }
}
