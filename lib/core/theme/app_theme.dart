import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
          surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        ).copyWith(
          error: AppColors.danger,
          tertiary: AppColors.accent,
          outline: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: _textTheme(isDark),
      scaffoldBackgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      cardColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      dividerColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
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
          // minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          minimumSize: Size(0, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),

      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        foregroundColor: isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // Bottom nav (student app)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
      ),
    );
  }

  static TextTheme _textTheme(bool isDark) {
    final primary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

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
