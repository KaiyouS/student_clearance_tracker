import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/core/models/clearance_step.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/theme/app_dimensions.dart';
import 'package:student_clearance_tracker/core/theme/app_text_styles.dart';
import 'package:student_clearance_tracker/core/widgets/status_badge.dart';
import 'package:student_clearance_tracker/features/staff/clearance/view/widgets/staff_clearance_actions.dart';
import 'package:student_clearance_tracker/features/staff/clearance/viewmodel/staff_clearance_viewmodel.dart';

class StaffClearanceStepRow extends StatelessWidget {
  final ClearanceStep step;

  const StaffClearanceStepRow({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StaffClearanceViewModel>();
    final canSign = vm.prereqCache[step.id] ?? false;
    final isPending = step.isPending;
    final isFlagged = step.isFlagged;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.studentName ?? '-',
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.studentNo ?? '-',
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                if (isPending && !canSign) ...[
                  const SizedBox(height: AppDimensions.xs),
                  Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIconsLight.lock,
                        size: 12,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppDimensions.xs),
                      Text(
                        'Prerequisites not yet complete',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
                if (isFlagged && step.remarks != null) ...[
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    step.remarks!,
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          StatusBadge(status: step.status),
          const SizedBox(width: 12),
          if (isPending) ...[
            ElevatedButton(
              onPressed: (vm.isSaving || !canSign)
                  ? null
                  : () => handleSignAction(context, step),
              style: ElevatedButton.styleFrom(
                backgroundColor: canSign
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).dividerColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(72, 36),
              ),
              child: const Text('Sign', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: vm.isSaving
                  ? null
                  : () => handleFlagAction(context, step),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
                minimumSize: const Size(72, 36),
              ),
              child: const Text('Flag', style: TextStyle(fontSize: 13)),
            ),
          ] else if (isFlagged) ...[
            ElevatedButton(
              onPressed: vm.isSaving
                  ? null
                  : () => handleSignAction(context, step),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 36),
              ),
              child: const Text('Sign', style: TextStyle(fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}
