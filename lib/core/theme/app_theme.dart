import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark  => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    ).copyWith(
      error: AppColors.danger,
      tertiary: AppColors.accent,
      outline: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );

    return ThemeData(
      useMaterial3:            true,
      brightness:              brightness,
      colorScheme:             colorScheme,
      textTheme:               _textTheme(isDark),
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      cardColor:
          isDark ? AppColors.darkSurface    : AppColors.lightSurface,
      dividerColor:
          isDark ? AppColors.darkBorder     : AppColors.lightBorder,

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),

      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // Bottom nav (student app)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
      ),
    );
  }

  static TextTheme _textTheme(bool isDark) {
    final primary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return TextTheme(
      displaySmall: AppTextStyles.heading1.copyWith(color: primary),
      headlineSmall: AppTextStyles.heading2.copyWith(color: primary),
      titleLarge: AppTextStyles.heading3.copyWith(color: primary),
      titleMedium: AppTextStyles.titleMd.copyWith(color: primary),
      titleSmall: AppTextStyles.titleSm.copyWith(color: primary),
      bodyMedium: AppTextStyles.bodyMd.copyWith(color: primary),
      bodySmall: AppTextStyles.bodySm.copyWith(color: secondary),
      labelMedium: AppTextStyles.caption.copyWith(color: secondary),
      labelSmall: AppTextStyles.label.copyWith(color: secondary),
    );
  }
}

// Old app_theme.dart
// import 'package:flutter/material.dart';
// import 'package:student_clearance_tracker/core/theme/app_colors.dart';

// class AppTheme {
//   AppTheme._();

//   // ── Seed & Brand ─────────────────────────────────────────
//   static const _seed = Color(0xFF1A73E8);
//   static const _danger = Color(0xFFEA4335);
//   static const _accent = Color(0xFF34A853);

//   // ── Shared component themes ───────────────────────────────
//   static ElevatedButtonThemeData get _buttonTheme => ElevatedButtonThemeData(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: _seed,
//       foregroundColor: Colors.white,
//       minimumSize: const Size(0, 48),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//     ),
//   );

//   static InputDecorationTheme _inputTheme(ColorScheme scheme) =>
//       InputDecorationTheme(
//         filled: true,
//         fillColor: scheme.surfaceContainerHighest,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: scheme.outline),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: scheme.outline),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: scheme.primary, width: 2),
//         ),
//       );

//   static NavigationBarThemeData _navBarTheme(ColorScheme scheme) =>
//       NavigationBarThemeData(
//         backgroundColor: scheme.surface,
//         indicatorColor: scheme.primary.withValues(alpha: 0.15),
//         labelTextStyle: WidgetStateProperty.all(TextStyle(fontSize: 12)),
//       );

//   // ── Color Schemes ─────────────────────────────────────────
//   static final _lightScheme = ColorScheme.fromSeed(
//     seedColor: _seed,
//     brightness: Brightness.light,
//   ).copyWith(error: _danger, tertiary: _accent);

//   static final _darkScheme = ColorScheme.fromSeed(
//     seedColor: _seed,
//     brightness: Brightness.dark,
//   ).copyWith(error: _danger, tertiary: _accent);

//   // ── Light Theme ───────────────────────────────────────────
//   static ThemeData get light => ThemeData(
//     useMaterial3: true,
//     colorScheme: _lightScheme,
//     elevatedButtonTheme: _buttonTheme,
//     inputDecorationTheme: _inputTheme(_lightScheme),
//     navigationBarTheme: _navBarTheme(_lightScheme),
//     appBarTheme: AppBarTheme(
//       backgroundColor: _lightScheme.surface,
//       foregroundColor: _lightScheme.onSurface,
//       elevation: 0,
//     ),
//     dividerTheme: DividerThemeData(color: _lightScheme.outline),
//     extensions: const [AppColors.light],
//   );

//   // ── Dark Theme ────────────────────────────────────────────
//   static ThemeData get dark => ThemeData(
//     useMaterial3: true,
//     colorScheme: _darkScheme,
//     elevatedButtonTheme: _buttonTheme,
//     inputDecorationTheme: _inputTheme(_darkScheme),
//     navigationBarTheme: _navBarTheme(_darkScheme),
//     appBarTheme: AppBarTheme(
//       backgroundColor: _darkScheme.surface,
//       foregroundColor: _darkScheme.onSurface,
//       elevation: 0,
//     ),
//     dividerTheme: DividerThemeData(color: _darkScheme.outline),
//     extensions: const [AppColors.dark],
//   );
// }
