import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/student/clearance/view/widgets/clearance_empty_state.dart';
import 'package:student_clearance_tracker/features/student/clearance/view/widgets/clearance_steps_list.dart';
import 'package:student_clearance_tracker/features/student/shell/viewmodel/student_shell_viewmodel.dart';
import 'package:student_clearance_tracker/main.dart';

class StudentClearanceBody extends StatelessWidget {
  const StudentClearanceBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<StudentShellViewModel, bool>(
      (p) => p.isLoading,
    );
    final stepCount = context.select<StudentShellViewModel, int>(
      (p) => p.steps.length,
    );

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => context.read<StudentShellViewModel>().loadData(
        supabase.auth.currentUser!.id,
      ),
      child: stepCount == 0
          ? const ClearanceEmptyState()
          : const ClearanceStepsList(),
    );
  }
}
