import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/core/models/step_with_info.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/theme/app_dimensions.dart';
import 'package:student_clearance_tracker/core/theme/app_text_styles.dart';
import 'package:student_clearance_tracker/core/widgets/status_badge.dart';
import 'package:student_clearance_tracker/features/student/clearance/view/step_detail_screen.dart';
import 'package:student_clearance_tracker/features/student/clearance/view/widgets/step_detail_row.dart';
import 'package:student_clearance_tracker/features/student/clearance/view/widgets/step_status_circle.dart';
import 'package:student_clearance_tracker/features/student/shell/viewmodel/student_shell_viewmodel.dart';

class ClearanceStepCard extends StatelessWidget {
  final int index;
  final bool isLast;

  const ClearanceStepCard({
    super.key,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final item = context.select<StudentShellViewModel, StepWithInfo?>(
      (p) => index < p.steps.length ? p.steps[index] : null,
    );
    if (item == null) {
      return const SizedBox.shrink();
    }

    final prevLevel = context.select<StudentShellViewModel, int?>(
      (p) => index > 0 && index - 1 < p.steps.length
          ? p.steps[index - 1].level
          : null,
    );
    final wasChanged = context.select<StudentShellViewModel, bool>((p) {
      final _ = p.changedStepsVersion;
      if (index >= p.steps.length) return false;
      return p.wasStepChanged(p.steps[index].step.id);
    });

    final step = item.step;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNewLevel = prevLevel != null && item.level != prevLevel;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => StepDetailScreen(stepWithInfo: item)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNewLevel) ...[
            const SizedBox(height: AppDimensions.sm),
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.sm),
              child: Row(
                children: [
                  PhosphorIcon(
                    PhosphorIconsLight.arrowDown,
                    size: 14,
                    color: AppColors.contentSecondary(context),
                  ),
                  const SizedBox(width: AppDimensions.xs),
                  Text(
                    'Requires above steps',
                    style: AppTextStyles.label.copyWith(
                      color: isDark
                          ? AppColors.contentSecondary(context)
                          : AppColors.contentSecondary(context),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  StepStatusCircle(status: step.status),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 60,
                      color: isDark
                          ? Theme.of(context).dividerColor
                          : Theme.of(context).dividerColor,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppDimensions.sm),
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Theme.of(context).colorScheme.surfaceContainer
                        : Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(
                      color: step.status == 'flagged'
                          ? Theme.of(
                              context,
                            ).colorScheme.error.withValues(alpha: 0.5)
                          : isDark
                          ? Theme.of(context).dividerColor
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              step.officeName ?? '-',
                              style: AppTextStyles.titleSm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          if (wasChanged)
                            Container(
                              margin: const EdgeInsets.only(
                                right: AppDimensions.sm,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.sm,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                'Updated',
                                style: AppTextStyles.label.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          StatusBadge(status: step.status),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      ..._buildDetails(context, item),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDetails(BuildContext context, StepWithInfo item) {
    final step = item.step;
    final details = <Widget>[];

    if (step.isSigned) {
      details.add(
        StepDetailRow(
          icon: PhosphorIconsLight.checkCircle,
          color: Theme.of(context).colorScheme.tertiary,
          text: step.updatedAt != null
              ? 'Signed on ${_formatDate(step.updatedAt!)}'
              : 'Signed',
        ),
      );
    } else if (step.isFlagged) {
      details.add(
        StepDetailRow(
          icon: PhosphorIconsLight.flag,
          color: Theme.of(context).colorScheme.error,
          text: step.remarks != null
              ? 'Flagged: ${step.remarks}'
              : 'This step has been flagged.',
        ),
      );
    } else if (item.isBlocked) {
      details.add(
        StepDetailRow(
          icon: PhosphorIconsLight.lock,
          color: AppColors.warning,
          text: 'Waiting for: ${item.waitingFor.join(', ')}',
        ),
      );
    } else {
      details.add(
        StepDetailRow(
          icon: PhosphorIconsLight.hourglass,
          color: AppColors.warning,
          text: 'Visit this office to get your clearance signed.',
        ),
      );
    }

    return details;
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
