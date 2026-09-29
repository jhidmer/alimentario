import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _primary = Color(0xFF176B5A);
  static const _surface = Color(0xFFF7FAF8);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: _primary);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: _surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: Color(0xFFE3EAE6)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE3EAE6)),
        ),
      ),
    );
  }

  static ThemeData get dark => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _primary, brightness: Brightness.dark),
        useMaterial3: true,
        cardTheme: CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      );
}
