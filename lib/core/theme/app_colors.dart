import 'package:flutter/material.dart';

enum ClearanceStepStatus { pending, signed, flagged, inactive }

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.info,
    required this.success,
    required this.warning,
    required this.danger,
    required this.neutral,
    required this.statusPending,
    required this.statusSigned,
    required this.statusFlagged,
    required this.statusInactive,
    required this.border,
  });

  final Color info;
  final Color success;
  final Color warning;
  final Color danger;
  final Color neutral;

  // Domain-specific status tokens for clearance flows.
  final Color statusPending;
  final Color statusSigned;
  final Color statusFlagged;
  final Color statusInactive;
  final Color border;

  static const light = AppColors(
    info: Color(0xFF1A73E8),
    success: Color(0xFF34A853),
    warning: Color(0xFFFBBC04),
    danger: Color(0xFFEA4335),
    neutral: Color(0xFF6B7280),
    statusPending: Color(0xFFFBBC04),
    statusSigned: Color(0xFF34A853),
    statusFlagged: Color(0xFFEA4335),
    statusInactive: Color(0xFFC5CCD1),
    border: Color(0xFFE5E7EB),
  );

  static const dark = AppColors(
    info: Color(0xFF8AB4F8),
    success: Color(0xFF81C995),
    warning: Color(0xFFFDD663),
    danger: Color(0xFFF28B82),
    neutral: Color(0xFF9CA3AF),
    statusPending: Color(0xFFFBBC04),
    statusSigned: Color(0xFF34A853),
    statusFlagged: Color(0xFFEA4335),
    statusInactive: Color(0xFFC5CCD1),
    border: Color(0xFF2D3748),
  );

  static AppColors fallbackFor(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  // Convenience accessor
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ??
      fallbackFor(Theme.of(context).brightness);

  // Strongly typed status color helper.
  static Color statusColor(BuildContext context, ClearanceStepStatus status) {
    final c = AppColors.of(context);
    switch (status) {
      case ClearanceStepStatus.signed:
        return c.statusSigned;
      case ClearanceStepStatus.flagged:
        return c.statusFlagged;
      case ClearanceStepStatus.inactive:
        return c.statusInactive;
      case ClearanceStepStatus.pending:
        return c.statusPending;
    }
  }

  // Backward-compatible helper for string statuses during migration.
  static Color statusColorFromString(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'signed':
        return statusColor(context, ClearanceStepStatus.signed);
      case 'flagged':
        return statusColor(context, ClearanceStepStatus.flagged);
      case 'inactive':
      case 'disabled':
        return statusColor(context, ClearanceStepStatus.inactive);
      default:
        return statusColor(context, ClearanceStepStatus.pending);
    }
  }

  @override
  AppColors copyWith({
    Color? info,
    Color? success,
    Color? warning,
    Color? danger,
    Color? neutral,
    Color? statusPending,
    Color? statusSigned,
    Color? statusFlagged,
    Color? statusInactive,
    Color? border,
  }) => AppColors(
    info: info ?? this.info,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    neutral: neutral ?? this.neutral,
    statusPending: statusPending ?? this.statusPending,
    statusSigned: statusSigned ?? this.statusSigned,
    statusFlagged: statusFlagged ?? this.statusFlagged,
    statusInactive: statusInactive ?? this.statusInactive,
    border: border ?? this.border,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      info: Color.lerp(info, other.info, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      statusPending: Color.lerp(statusPending, other.statusPending, t)!,
      statusSigned: Color.lerp(statusSigned, other.statusSigned, t)!,
      statusFlagged: Color.lerp(statusFlagged, other.statusFlagged, t)!,
      statusInactive: Color.lerp(statusInactive, other.statusInactive, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}
