import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';

class StepStatusCircle extends StatelessWidget {
  final String status;

  const StepStatusCircle({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColorFromString(context, status);
    final icon = switch (status) {
      'signed' => Icons.check,
      'flagged' => Icons.flag,
      _ => Icons.circle_outlined,
    };

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
