import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/admin/clearance/viewmodel/admin_clearance_viewmodel.dart';

class AdminClearanceStudentTile extends StatelessWidget {
  final int index;

  const AdminClearanceStudentTile({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final student = context
        .select<AdminClearanceViewModel, Map<String, dynamic>?>((vm) {
          if (index >= vm.filtered.length) return null;
          return vm.filtered[index];
        });

    if (student == null) {
      return const SizedBox.shrink();
    }

    final selectedStudentId = context.select<AdminClearanceViewModel, String?>(
      (vm) => vm.selectedStudent?['student_id'] as String?,
    );
    final isSelected = selectedStudentId == student['student_id'];

    final total = student['total_steps'] ?? 0;
    final signed = student['signed_steps'] ?? 0;
    final flagged = student['flagged_steps'] ?? 0;
    final status = student['clearance_status'] ?? 'incomplete';
    final isComplete = status == 'complete';
    final noSteps = total == 0;

    return InkWell(
      onTap: () =>
          context.read<AdminClearanceViewModel>().selectStudent(student),
      child: Container(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          student['full_name'] ?? '-',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (flagged > 0)
                        Icon(
                          Icons.flag,
                          size: 14,
                          color: Theme.of(context).colorScheme.error,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (noSteps)
                    Text(
                      'No clearance generated',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    )
                  else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? signed / total : 0,
                        backgroundColor: Theme.of(context).dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isComplete
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.primary,
                        ),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$signed / $total offices signed',
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
          ],
        ),
      ),
    );
  }
}

