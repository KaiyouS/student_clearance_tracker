import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/clearance_step.dart';

Future<String?> showStaffFlagDialog(
  BuildContext context,
  ClearanceStep step,
) async {
  final remarkController = TextEditingController();
  try {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Flag ${step.studentName ?? 'Student'}'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: remarkController,
            decoration: const InputDecoration(
              labelText: 'Reason for flagging',
              hintText: 'Describe the issue...',
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

