import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';

class AdminClearanceStepStatusIcon extends StatelessWidget {
  final String status;

  const AdminClearanceStepStatusIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forStatus(status);
    final icon = switch (status) {
      'signed' => PhosphorIconsLight.checkCircle,
      'flagged' => PhosphorIconsLight.flag,
      _ => PhosphorIconsLight.hourglass,
    };

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: PhosphorIcon(icon, size: 16, color: color),
    );
  }
}
