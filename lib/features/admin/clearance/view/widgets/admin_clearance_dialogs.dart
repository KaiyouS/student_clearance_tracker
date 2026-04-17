import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/clearance_step.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/widgets/confirm_dialog.dart';

Future<bool> confirmGenerateForStudent(BuildContext context, String name) {
  return ConfirmDialog.show(
    context,
    title: 'Generate Clearance',
    message:
        'Generate clearance steps for $name for the '
        'current period? Existing steps will not be affected.',
    confirmLabel: 'Generate',
    confirmColor: Theme.of(context).colorScheme.primary,
  );
}

Future<bool> confirmGenerateForAll(BuildContext context) {
  return ConfirmDialog.show(
    context,
    title: 'Generate Clearance for All Students',
    message:
        'This will create clearance steps for every student '
        'for the current period based on their program. '
        'Existing steps will not be affected.',
    confirmLabel: 'Generate All',
    confirmColor: Theme.of(context).colorScheme.primary,
  );
}

Future<bool> confirmOverrideStep(
  BuildContext context,
  ClearanceStep step,
  String newStatus,
) {
  final isReset = newStatus == 'pending';
  return ConfirmDialog.show(
    context,
    title: isReset ? 'Reset Step' : 'Override Step',
    message: isReset
        ? 'Reset this step back to pending?'
        : 'Override "${step.officeName}" step to $newStatus?',
    confirmLabel: isReset ? 'Reset' : 'Override',
    confirmColor: isReset
        ? AppColors.warning
        : Theme.of(context).colorScheme.primary,
  );
}

Future<String?> promptFlagRemark(BuildContext context) async {
  final remarkController = TextEditingController();
  try {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Flag Step'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: remarkController,
            decoration: const InputDecoration(
              labelText: 'Reason for flagging',
              hintText: 'Enter a remark...',
            ),
            maxLines: 3,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(true),
            child: const Text('Flag'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return null;
    }

    return remarkController.text.trim();
  } finally {
    remarkController.dispose();
  }
}

