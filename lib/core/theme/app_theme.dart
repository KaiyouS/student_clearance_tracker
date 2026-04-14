import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ── Seed & Brand ─────────────────────────────────────────
  static const _seed = Color(0xFF1A73E8);
  static const _danger = Color(0xFFEA4335);
  static const _accent = Color(0xFF34A853);

  // ── Shared component themes ───────────────────────────────
  static ElevatedButtonThemeData get _buttonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _seed,
      foregroundColor: Colors.white,
      minimumSize: const Size(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static InputDecorationTheme _inputTheme(ColorScheme scheme) =>
      InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      );

  static NavigationBarThemeData _navBarTheme(ColorScheme scheme) =>
      NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(TextStyle(fontSize: 12)),
      );

  // ── Color Schemes ─────────────────────────────────────────
  static final _lightScheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.light,
  ).copyWith(error: _danger, tertiary: _accent);

  static final _darkScheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
  ).copyWith(error: _danger, tertiary: _accent);

  // ── Light Theme ───────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: _lightScheme,
    elevatedButtonTheme: _buttonTheme,
    inputDecorationTheme: _inputTheme(_lightScheme),
    navigationBarTheme: _navBarTheme(_lightScheme),
    appBarTheme: AppBarTheme(
      backgroundColor: _lightScheme.surface,
      foregroundColor: _lightScheme.onSurface,
      elevation: 0,
    ),
    dividerTheme: DividerThemeData(color: _lightScheme.outline),
    extensions: const [AppColors.light],
  );

  // ── Dark Theme ────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: _darkScheme,
    elevatedButtonTheme: _buttonTheme,
    inputDecorationTheme: _inputTheme(_darkScheme),
    navigationBarTheme: _navBarTheme(_darkScheme),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkScheme.surface,
      foregroundColor: _darkScheme.onSurface,
      elevation: 0,
    ),
    dividerTheme: DividerThemeData(color: _darkScheme.outline),
    extensions: const [AppColors.dark],
  );
}
