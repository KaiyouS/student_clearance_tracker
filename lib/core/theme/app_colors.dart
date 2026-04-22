import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand (New Palette) ────────────────────────────────────────────────────
  static const primary = Color.fromARGB(255, 8, 171, 200); // Tory Blue
  static const primarydark = Color(0xFF0F598E); // Tory Blue
  static const primaryLight = Color(0xFF26A6C0); // Curious Blue
  static const accent = Color(0xFF1FC481); // Mountain Meadow
  static const accentLight = Color(0xFF5CD9A1); // Shamrock (Optional)
  static const danger = Color(0xFFEA4335); // error / flagged
  static const warning = Color(0xFFFBBC04); // pending

  // ── Light Tokens ───────────────────────────────────────────────────────────
  static const lightBackground = Color(0xFFF5F7FA); // App "Floor"
  static const lightSurfaceBase = Color(0xFFFFFFFF); // Default Cards
  static const lightSurfaceElevated = Color(0xFFF9FAFB); // Important Cards
  static const lightSurfaceOverlay = Color(0xFFF3F4F6); // Dialogs/Dropdowns
  
  static const lightTextPrimary = Color(0xFF1F2937);
  static const lightTextSecondary = Color(0xFF6B7280);
  static const lightBorder = Color(0xFFE5E7EB);

  // ── Dark Tokens (FoodPanda Stepping) ───────────────────────────────────────
  static const darkBackground = Color(0xFF121212); // App "Floor"
  static const darkSurfaceBase = Color(0xFF1E1E1E); // Default Cards (Level 1)
  static const darkSurfaceElevated = Color(0xFF2C2C2C); // Important Cards (Level 2)
  static const darkSurfaceOverlay = Color(0xFF383838); // Dialogs/Dropdowns (Level 3)
  
  static const darkTextPrimary = Color(0xFFF9FAFB);
  static const darkTextSecondary = Color(0xFF9CA3AF);
  static const darkBorder = Color(0xFF2D3748);

  // ── Semantic Helpers ───────────────────────────────────────────────────────
  static Color forStatus(String status) => switch (status) {
    'signed' => accent,
    'flagged' => danger,
    _ => warning,
  };

  static Color contentSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }
}