import 'package:flutter/material.dart';
import 'weev_colors.dart';
import 'weev_typography.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: WeevColors.primary,
      primary: WeevColors.primary,
      secondary: WeevColors.secondary,
      surface: WeevColors.surface,
      background: WeevColors.background,
      error: WeevColors.error,
    ),
    scaffoldBackgroundColor: WeevColors.background,
    textTheme: WeevTypography.textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: WeevColors.surface,
      foregroundColor: WeevColors.onSurface,
      centerTitle: true,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WeevColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: WeevColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: WeevColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: WeevColors.primary, width: 2),
      ),
    ),
  );
}
