import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/widgets/admin_clearance_student_tile.dart';
import 'package:student_clearance_tracker/features/admin/clearance/viewmodel/admin_clearance_viewmodel.dart';

class AdminClearanceStudentList extends StatelessWidget {
  const AdminClearanceStudentList({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select<AdminClearanceViewModel, int>(
      (vm) => vm.filtered.length,
    );

    if (count == 0) {
      return Center(
        child: Text(
          'No students match filters.',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: count,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: Theme.of(context).dividerColor),
      itemBuilder: (context, i) => AdminClearanceStudentTile(index: i),
    );
  }
}

