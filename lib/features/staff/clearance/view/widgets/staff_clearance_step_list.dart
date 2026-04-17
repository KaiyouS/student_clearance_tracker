import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/clearance_step.dart';
import 'package:student_clearance_tracker/features/staff/clearance/view/widgets/staff_clearance_step_row.dart';
import 'package:student_clearance_tracker/features/staff/clearance/viewmodel/staff_clearance_viewmodel.dart';

class StaffClearanceStepList extends StatelessWidget {
  final String status;

  const StaffClearanceStepList({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = context.select<StaffClearanceViewModel, List<ClearanceStep>>(
      (vm) => vm.filteredByStatus[status] ?? const <ClearanceStep>[],
    );

    if (steps.isEmpty) {
      return Center(
        child: Text(
          'No steps found.',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(0),
      itemCount: steps.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: Theme.of(context).dividerColor),
      itemBuilder: (context, i) => StaffClearanceStepRow(step: steps[i]),
    );
  }
}

