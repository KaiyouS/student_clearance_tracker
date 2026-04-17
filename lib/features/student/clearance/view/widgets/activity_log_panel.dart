import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/student/clearance/view/widgets/activity_log_item.dart';
import 'package:student_clearance_tracker/features/student/clearance/viewmodel/step_detail_viewmodel.dart';

class ActivityLogPanel extends StatelessWidget {
  const ActivityLogPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final logCount = context.select<StepDetailViewModel, int>(
      (vm) => vm.logs.length,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: List.generate(
          logCount,
          (index) =>
              ActivityLogItem(index: index, isLast: index == logCount - 1),
        ),
      ),
    );
  }
}

