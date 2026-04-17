import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/step_with_info.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/features/student/shell/viewmodel/student_shell_viewmodel.dart';

class NextStepCard extends StatelessWidget {
  const NextStepCard({super.key});

  @override
  Widget build(BuildContext context) {
    final step = context.select<StudentShellViewModel, StepWithInfo?>(
      (p) => p.nextActionableStep,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (step == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppColors.of(context).border
                : AppColors.of(context).border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.lock_clock_outlined,
              color: AppColors.of(context).warning,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No steps are ready to sign yet — '
                'waiting for prerequisites.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.of(context).neutral
                      : AppColors.of(context).neutral,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => context.go('/student/clearance'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.of(context).info.withValues(alpha: 0.12),
              AppColors.of(context).info.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.of(context).info.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.of(context).info.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_circle_right_outlined,
                color: AppColors.of(context).info,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Step',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.of(context).info,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.step.officeName ?? '—',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).info,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to view clearance steps →',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.of(context).info,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
