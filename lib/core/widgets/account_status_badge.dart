import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';

class AccountStatusBadge extends StatelessWidget {
  final String status;

  const AccountStatusBadge({super.key, required this.status});

  IconData get _icon => switch (status) {
    'active' => Icons.check_circle_outline,
    'inactive' => Icons.pause_circle_outline,
    'locked' => Icons.lock_outline,
    'pending' => Icons.hourglass_empty_outlined,
    _ => Icons.help_outline,
  };

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'active' => AppColors.of(context).statusSigned,
      'inactive' => AppColors.of(context).neutral,
      'locked' => AppColors.of(context).danger,
      'pending' => AppColors.of(context).statusPending,
      _ => AppColors.of(context).neutral,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
