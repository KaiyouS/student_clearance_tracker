import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/clearance_step.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/widgets/status_badge.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/widgets/admin_clearance_actions.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/widgets/admin_clearance_step_status_icon.dart';
import 'package:student_clearance_tracker/features/admin/clearance/viewmodel/admin_clearance_viewmodel.dart';

class AdminClearanceStepRow extends StatelessWidget {
  final int index;

  const AdminClearanceStepRow({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final step = context.select<AdminClearanceViewModel, ClearanceStep?>((vm) {
      if (index >= vm.selectedSteps.length) {
        return null;
      }
      return vm.selectedSteps[index];
    });

    if (step == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          AdminClearanceStepStatusIcon(status: step.status),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.officeName ?? 'Unknown Office',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                  ),
                ),
                if (step.remarks != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.remarks!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.of(context).statusFlagged,
                    ),
                  ),
                ],
                if (step.updatedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Updated ${_formatDateTime(step.updatedAt!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ],
            ),
          ),
          StatusBadge(status: step.status),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              size: 18,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.65),
            ),
            tooltip: 'Override',
            onSelected: (action) {
              if (action == 'flag') {
                handleFlagStepAction(context, step);
              } else {
                handleOverrideStepAction(context, step, action);
              }
            },
            itemBuilder: (_) => [
              if (!step.isSigned)
                PopupMenuItem(
                  value: 'signed',
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.of(context).statusSigned,
                      ),
                      const SizedBox(width: 8),
                      const Text('Mark as Signed'),
                    ],
                  ),
                ),
              if (!step.isFlagged)
                PopupMenuItem(
                  value: 'flag',
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 16,
                        color: AppColors.of(context).statusFlagged,
                      ),
                      const SizedBox(width: 8),
                      const Text('Flag'),
                    ],
                  ),
                ),
              if (!step.isPending)
                PopupMenuItem(
                  value: 'pending',
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                      const SizedBox(width: 8),
                      const Text('Reset to Pending'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  return '${dt.day}/${dt.month}/${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}
