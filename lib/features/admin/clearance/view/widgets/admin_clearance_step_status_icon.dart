import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';

class AdminClearanceStepStatusIcon extends StatelessWidget {
  final String status;

  const AdminClearanceStepStatusIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColorFromString(context, status);
    final icon = switch (status) {
      'signed' => Icons.check_circle,
      'flagged' => Icons.flag,
      _ => Icons.hourglass_empty_outlined,
    };

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}
