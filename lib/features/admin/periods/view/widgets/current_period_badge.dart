import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';

class CurrentPeriodBadge extends StatelessWidget {
  const CurrentPeriodBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.of(context).info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.of(context).info.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.radio_button_checked,
            size: 12,
            color: AppColors.of(context).info,
          ),
          const SizedBox(width: 4),
          Text(
            'Current',
            style: TextStyle(
              color: AppColors.of(context).info,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
