import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';

class AccountStatusBadge extends StatelessWidget {
  final String status;

  const AccountStatusBadge({super.key, required this.status});

  PhosphorIconData get _icon => switch (status) {
    'active' => PhosphorIconsLight.checkCircle,
    'inactive' => PhosphorIconsLight.pauseCircle,
    'locked' => PhosphorIconsLight.lock,
    'pending' => PhosphorIconsLight.hourglass,
    _ => PhosphorIconsLight.question,
  };

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'active' => Theme.of(context).colorScheme.tertiary,
      'inactive' => AppColors.contentSecondary(context),
      'locked' => Theme.of(context).colorScheme.error,
      'pending' => AppColors.warning,
      _ => AppColors.contentSecondary(context),
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
          PhosphorIcon(_icon, size: 12, color: color),
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
