import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';

class StepStatusCircle extends StatelessWidget {
  final String status;

  const StepStatusCircle({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forStatus(status);
    final icon = switch (status) {
      'signed' => PhosphorIconsRegular.check,
      'flagged' => PhosphorIconsRegular.flag,
      _ => PhosphorIconsRegular.circle,
    };

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: PhosphorIcon(icon, size: 14, color: color),
    );
  }
}
