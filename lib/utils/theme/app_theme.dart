import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF006D77);
  static const Color secondaryTeal = Color(0xFF83C5BE);
  static const Color backgroundLight = Color(0xFFEDF6F9);
  static const Color surfaceLight = Colors.white;

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color primaryTealDark = Color(0xFF83C5BE);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryTeal,
      primary: primaryTeal,
      onPrimary: Colors.white,
      secondary: secondaryTeal,
      onSecondary: Colors.black,
      surface: surfaceLight,
      onSurface: Colors.black,
      error: Colors.redAccent,
      onError: Colors.white,
      background: backgroundLight,
      onBackground: Colors.black,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryTeal,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryTealDark,
      onPrimary: Colors.black,
      secondary: secondaryTeal,
      onSecondary: Colors.black,
      surface: surfaceDark,
      onSurface: Colors.white70,
      error: Color(0xFFCF6679),
      onError: Colors.black,
      surfaceContainerHighest: surfaceDark, // Fallback for surfaceVariant in newer Flutter
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
