import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand Colors (shared across both themes) ──────────────
  static const Color primary        = Color(0xFF1A73E8);
  static const Color primaryDark    = Color(0xFF1557B0);
  static const Color accent         = Color(0xFF34A853);
  static const Color danger         = Color(0xFFEA4335);
  static const Color warning        = Color(0xFFFBBC04);
  static const Color statusPending  = warning;
  static const Color statusSigned   = accent;
  static const Color statusFlagged  = danger;

  // ── Light theme colors ────────────────────────────────────
  static const Color background     = Color(0xFFF5F7FA);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color textPrimary    = Color(0xFF1F2937);
  static const Color textSecondary  = Color(0xFF6B7280);
  static const Color border         = Color(0xFFE5E7EB);

  // ── Dark theme colors ─────────────────────────────────────
  static const Color darkBackground    = Color(0xFF0F1117);
  static const Color darkSurface       = Color(0xFF1A1D24);
  static const Color darkTextPrimary   = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkBorder        = Color(0xFF2D3748);

  // ── Status color helper ───────────────────────────────────
  static Color statusColor(String status) {
    switch (status) {
      case 'signed':  return statusSigned;
      case 'flagged': return statusFlagged;
      default:        return statusPending;
    }
  }

  // ── Input decoration shared logic ─────────────────────────
  static InputDecorationTheme _inputTheme(Color fill, Color borderColor) {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      filled:    true,
      fillColor: fill,
    );
  }

  static ElevatedButtonThemeData get _buttonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: surface,
      minimumSize: const Size(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  // ── Light Theme ───────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3:           true,
    brightness:             Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor:  primary,
      surface:    surface,
    ),
    scaffoldBackgroundColor: background,
    cardColor:               surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation:       0,
    ),
    inputDecorationTheme: _inputTheme(surface, border),
    elevatedButtonTheme:  _buttonTheme,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor:       surface,
      indicatorColor:        primary.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12),
      ),
    ),
  );

  // ── Dark Theme ────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3:           true,
    brightness:             Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor:  primary,
      brightness: Brightness.dark,
      surface:    darkSurface,
    ),
    scaffoldBackgroundColor: darkBackground,
    cardColor:               darkSurface,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkTextPrimary,
      elevation:       0,
    ),
    inputDecorationTheme: _inputTheme(darkSurface, darkBorder),
    elevatedButtonTheme:  _buttonTheme,
    dividerColor:         darkBorder,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkSurface,
      indicatorColor:  primary.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12),
      ),
    ),
  );
}