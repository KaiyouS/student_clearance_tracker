import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/clearance_step.dart';
import 'package:student_clearance_tracker/features/staff/clearance/view/widgets/staff_flag_dialog.dart';
import 'package:student_clearance_tracker/features/staff/clearance/viewmodel/staff_clearance_viewmodel.dart';
import 'package:student_clearance_tracker/main.dart';

Future<void> handleSignAction(BuildContext context, ClearanceStep step) async {
  final vm = context.read<StaffClearanceViewModel>();
  final success = await vm.signStep(step, supabase.auth.currentUser!.id);

  if (!context.mounted) {
    return;
  }

  if (success) {
    _showSuccess(
      context,
      'Clearance signed for ${step.studentName ?? 'student'}.',
    );
  } else {
    _showError(context, vm.error ?? 'Failed to sign.');
  }
}

Future<void> handleFlagAction(BuildContext context, ClearanceStep step) async {
  final remark = await showStaffFlagDialog(context, step);
  if (remark == null) {
    return;
  }

  if (!context.mounted) {
    return;
  }

  final vm = context.read<StaffClearanceViewModel>();
  final success = await vm.flagStep(
    step,
    supabase.auth.currentUser!.id,
    remark,
  );

  if (!context.mounted) {
    return;
  }

  if (success) {
    _showSuccess(context, 'Step flagged.');
  } else {
    _showError(context, vm.error ?? 'Failed to flag.');
  }
}

void _showSuccess(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: Theme.of(context).colorScheme.tertiary,
    ),
  );
}

void _showError(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Theme.of(context).colorScheme.error),
  );
}

