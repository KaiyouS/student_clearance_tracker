import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/clearance_step.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/theme/app_dimensions.dart';
import 'package:student_clearance_tracker/core/theme/app_text_styles.dart';
import 'package:student_clearance_tracker/core/widgets/status_badge.dart';
import 'package:student_clearance_tracker/features/student/clearance/view/widgets/detail_row.dart';
import 'package:student_clearance_tracker/features/student/clearance/viewmodel/step_detail_viewmodel.dart';

class StatusDetailCard extends StatelessWidget {
  const StatusDetailCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StepDetailViewModel>();
    final step = vm.step;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Details',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.md),
          ..._buildRows(context, step, vm.isBlocked),
        ],
      ),
    );
  }

  List<Widget> _buildRows(
    BuildContext context,
    ClearanceStep step,
    bool isBlocked,
  ) {
    if (step.isSigned) {
      return [
        DetailRow(
          label: 'Status',
          child: StatusBadge(status: step.status),
        ),
        if (step.updatedAt != null)
          DetailRow(
            label: 'Signed on',
            value: _formatDateTime(step.updatedAt!),
          ),
      ];
    }

    if (step.isFlagged) {
      return [
        DetailRow(
          label: 'Status',
          child: StatusBadge(status: step.status),
        ),
        if (step.updatedAt != null)
          DetailRow(
            label: 'Flagged on',
            value: _formatDateTime(step.updatedAt!),
          ),
        if (step.remarks != null)
          DetailRow(label: 'Reason', value: step.remarks!, isRed: true),
        const SizedBox(height: AppDimensions.sm),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  'Visit this office to resolve the flag before '
                  'your clearance can proceed.',
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return [
      DetailRow(
        label: 'Status',
        child: StatusBadge(status: step.status),
      ),
      const SizedBox(height: AppDimensions.sm),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isBlocked
              ? AppColors.warning.withValues(alpha: 0.06)
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isBlocked
                ? AppColors.warning.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isBlocked ? Icons.lock_outline : Icons.directions_walk_outlined,
              size: 14,
              color: isBlocked
                  ? AppColors.warning
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Text(
                isBlocked
                    ? 'This step is locked until prerequisites are complete.'
                    : 'Visit this office in person to get your clearance signed.',
                style: AppTextStyles.caption.copyWith(
                  color: isBlocked
                      ? AppColors.warning
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  String _formatDateTime(DateTime dt) {
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
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
