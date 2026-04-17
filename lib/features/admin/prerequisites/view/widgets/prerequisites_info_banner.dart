import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';

class PrerequisitesInfoBanner extends StatelessWidget {
  final String officeName;

  const PrerequisitesInfoBanner({super.key, required this.officeName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.of(context).info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.of(context).info.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.of(context).info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'The listed offices must sign the student\'s clearance before "$officeName" can sign.',
              style: TextStyle(fontSize: 12, color: AppColors.of(context).info),
            ),
          ),
        ],
      ),
    );
  }
}
