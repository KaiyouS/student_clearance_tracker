import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      surface: isDark ? AppColors.darkBackground : AppColors.lightBackground,
    ).copyWith(
      primary: AppColors.primary,
      error: AppColors.danger,
      tertiary: AppColors.accent,
      outline: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      surfaceContainer: isDark ? AppColors.darkSurfaceBase : AppColors.lightSurfaceBase,
      surfaceContainerHigh: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
      surfaceContainerHighest: isDark ? AppColors.darkSurfaceOverlay : AppColors.lightSurfaceOverlay,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: _textTheme(isDark),
      scaffoldBackgroundColor: colorScheme.surface,
      dividerColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,

      // ── Cards ──
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: BorderSide.none,
        ),
      ),

      // ── Input Fields ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingHorizontal,
          vertical: AppDimensions.paddingVertical,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),

      // ── Buttons ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingHorizontal,
            vertical: AppDimensions.paddingVertical,
          ),
          minimumSize: const Size(0, AppDimensions.buttonHeight),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),

      // ── Overlays (Dialogs & Bottom Sheets) ──
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
        ),
      ),

      // ── Navigation ──
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainer,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
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