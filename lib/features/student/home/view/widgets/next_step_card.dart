import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/core/models/step_with_info.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/theme/app_dimensions.dart';
import 'package:student_clearance_tracker/core/theme/app_text_styles.dart';
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
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isDark
                ? Theme.of(context).dividerColor
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          children: [
            PhosphorIcon(
              PhosphorIconsLight.lockKey,
              color: AppColors.warning,
              size: AppDimensions.iconMd,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No steps are ready to sign yet - '
                'waiting for prerequisites.',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.contentSecondary(context),
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
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: PhosphorIcon(
                PhosphorIconsLight.arrowCircleRight,
                color: Theme.of(context).colorScheme.primary,
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
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.step.officeName ?? '-',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to view clearance steps ->',
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.primary,
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
