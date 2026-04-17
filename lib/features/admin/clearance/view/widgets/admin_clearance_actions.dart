import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/clearance_step.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/widgets/admin_clearance_dialogs.dart';
import 'package:student_clearance_tracker/features/admin/clearance/viewmodel/admin_clearance_viewmodel.dart';
import 'package:student_clearance_tracker/main.dart';

Future<void> handleGenerateForStudentAction(
  BuildContext context,
  String studentId,
  String name,
) async {
  final vm = context.read<AdminClearanceViewModel>();
  final confirmed = await confirmGenerateForStudent(context, name);
  if (!confirmed) {
    return;
  }

  final success = await vm.generateForStudent(studentId, name);
  if (!context.mounted) {
    return;
  }
  _showActionResult(context, vm, success);
}

Future<void> handleGenerateForAllAction(BuildContext context) async {
  final vm = context.read<AdminClearanceViewModel>();
  final confirmed = await confirmGenerateForAll(context);
  if (!confirmed) {
    return;
  }

  final success = await vm.generateForAll();
  if (!context.mounted) {
    return;
  }
  _showActionResult(context, vm, success);
}

Future<void> handleOverrideStepAction(
  BuildContext context,
  ClearanceStep step,
  String newStatus,
) async {
  final vm = context.read<AdminClearanceViewModel>();
  final confirmed = await confirmOverrideStep(context, step, newStatus);
  if (!confirmed) {
    return;
  }

  final success = await vm.overrideStep(
    step,
    newStatus,
    supabase.auth.currentUser!.id,
  );
  if (!context.mounted) {
    return;
  }
  _showActionResult(context, vm, success);
}

Future<void> handleFlagStepAction(
  BuildContext context,
  ClearanceStep step,
) async {
  final vm = context.read<AdminClearanceViewModel>();
  final remarks = await promptFlagRemark(context);
  if (remarks == null) {
    return;
  }

  final success = await vm.flagWithRemark(
    step,
    supabase.auth.currentUser!.id,
    remarks.isEmpty ? null : remarks,
  );
  if (!context.mounted) {
    return;
  }
  _showActionResult(context, vm, success);
}

void _showActionResult(
  BuildContext context,
  AdminClearanceViewModel vm,
  bool success,
) {
  if (success && vm.actionSuccess != null) {
    _showSuccess(context, vm.actionSuccess!);
  } else if (!success && vm.actionError != null) {
    _showError(context, vm.actionError!);
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

