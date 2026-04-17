import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ────────────────────────────────────────────────
  static const primary     = Color(0xFF1A73E8);
  static const primaryDark = Color(0xFF1557B0);
  static const accent      = Color(0xFF34A853); // success / signed
  static const danger      = Color(0xFFEA4335); // error / flagged
  static const warning     = Color(0xFFFBBC04); // pending

  // ── Light tokens ─────────────────────────────────────────
  static const lightBackground    = Color(0xFFF5F7FA);
  static const lightSurface       = Color(0xFFFFFFFF);
  static const lightTextPrimary   = Color(0xFF1F2937);
  static const lightTextSecondary = Color(0xFF6B7280);
  static const lightBorder        = Color(0xFFE5E7EB);

  // ── Dark tokens ───────────────────────────────────────────
  static const darkBackground    = Color(0xFF0F1117);
  static const darkSurface       = Color(0xFF1A1D24);
  static const darkTextPrimary   = Color(0xFFF9FAFB);
  static const darkTextSecondary = Color(0xFF9CA3AF);
  static const darkBorder        = Color(0xFF2D3748);

  // ── Semantic helpers ──────────────────────────────────────
  static Color forStatus(String status) => switch (status) {
    'signed'  => accent,
    'flagged' => danger,
    _         => warning,
  };

  static Color contentSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }
}
