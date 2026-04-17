import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/clearance_step.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
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
                  step.studentName ?? '—',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.studentNo ?? '—',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                if (isPending && !canSign) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 12,
                        color: AppColors.of(context).warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Prerequisites not yet complete',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.of(context).warning,
                        ),
                      ),
                    ],
                  ),
                ],
                if (isFlagged && step.remarks != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.remarks!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.of(context).statusFlagged,
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
                    ? AppColors.of(context).statusSigned
                    : AppColors.of(context).border,
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
                foregroundColor: AppColors.of(context).danger,
                side: BorderSide(color: AppColors.of(context).danger),
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
                backgroundColor: AppColors.of(context).statusSigned,
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
