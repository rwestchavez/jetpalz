import 'package:flutter/material.dart';

class lightModeTheme {
  // Light mode colors
  static const Color primary = Color(0xFF105DFB);
  static const Color secondary = Color(0xFF8AC7FF);
  static const Color tertiary = Color(0xFFEE8B60);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF12151C);
  static const Color secondaryText = Color(0xFF5A5C60);
  static const Color error = Color(0xFFE65454);
  static const Color onSurface = Color(0xFF12151C);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onError = Color(0xFFFFFFFF);

  // ThemeData for light mode
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: onSecondary,
        surface: surface,
        onSurface: onSurface,
        error: error,
        onError: onError,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: primaryText),
        bodyMedium: TextStyle(color: secondaryText),
      ),
    );
  }
}
