import 'package:flutter/material.dart';

class AppTheme {
  // --------------------------------------------------------
  // Brand Colors
  // --------------------------------------------------------
  static const Color primary       = Color(0xFF1A73E8); // blue
  static const Color primaryDark   = Color(0xFF1557B0);
  static const Color accent        = Color(0xFF34A853); // green (signed/success)
  static const Color danger        = Color(0xFFEA4335); // red (flagged/error)
  static const Color warning       = Color(0xFFFBBC04); // yellow (pending)
  static const Color background    = Color(0xFFF5F7FA);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border        = Color(0xFFE5E7EB);

  // --------------------------------------------------------
  // Clearance Status Colors (used in both apps)
  // --------------------------------------------------------
  static const Color statusPending = warning;
  static const Color statusSigned  = accent;
  static const Color statusFlagged = danger;

  static Color statusColor(String status) {
    switch (status) {
      case 'signed':  return statusSigned;
      case 'flagged': return statusFlagged;
      default:        return statusPending;
    }
  }

  // --------------------------------------------------------
  // Theme Data
  // --------------------------------------------------------
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      surface: surface,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      filled: true,
      fillColor: surface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: surface,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}