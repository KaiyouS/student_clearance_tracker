import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';

class StaffOfficeBadge extends StatelessWidget {
  final String name;

  const StaffOfficeBadge({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.of(context).info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.of(context).info.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 11,
          color: AppColors.of(context).info,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
