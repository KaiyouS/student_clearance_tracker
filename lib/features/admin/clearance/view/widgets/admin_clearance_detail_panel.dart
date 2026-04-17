import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/core/widgets/status_badge.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/widgets/admin_clearance_actions.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/widgets/admin_clearance_step_row.dart';
import 'package:student_clearance_tracker/features/admin/clearance/viewmodel/admin_clearance_viewmodel.dart';

class AdminClearanceDetailPanel extends StatelessWidget {
  const AdminClearanceDetailPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminClearanceViewModel>();
    final student = vm.selectedStudent;

    if (student == null) {
      return const SizedBox.shrink();
    }

    final total = student['total_steps'] ?? 0;
    final signed = student['signed_steps'] ?? 0;
    final status = student['clearance_status'] ?? 'incomplete';
    final noSteps = total == 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['full_name'] ?? '-',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      noSteps
                          ? 'No clearance steps generated yet.'
                          : '$signed of $total offices signed',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (!noSteps) StatusBadge(status: status),
              const SizedBox(width: 8),
              if (noSteps || total < 20)
                TextButton.icon(
                  onPressed: vm.isSaving
                      ? null
                      : () => handleGenerateForStudentAction(
                          context,
                          student['student_id'],
                          student['full_name'] ?? 'Student',
                        ),
                  icon: const Icon(Icons.auto_awesome, size: 14),
                  label: const Text('Generate'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.of(context).info,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.of(context).border),
          const SizedBox(height: 8),
          if (vm.isLoadingSteps)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (vm.selectedSteps.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.checklist_outlined,
                      size: 48,
                      color: AppColors.of(context).border,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No clearance steps yet.',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: vm.isSaving
                          ? null
                          : () => handleGenerateForStudentAction(
                              context,
                              student['student_id'],
                              student['full_name'] ?? 'Student',
                            ),
                      child: const Text('Generate Clearance'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: vm.selectedSteps.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: AppColors.of(context).border),
                itemBuilder: (context, i) => AdminClearanceStepRow(index: i),
              ),
            ),
        ],
      ),
    );
  }
}
