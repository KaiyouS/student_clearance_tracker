import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/office.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/widgets/confirm_dialog.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/view/widgets/add_prerequisite_dialog.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/viewmodel/prerequisites_viewmodel.dart';

Future<void> handleRemovePrerequisiteAction(
  BuildContext context,
  Office office,
  Office requires,
) async {
  final confirmed = await ConfirmDialog.show(
    context,
    title: 'Remove Prerequisite',
    message:
        'Remove "${requires.name}" as a prerequisite for "${office.name}"?',
    confirmLabel: 'Remove',
  );
  if (!confirmed) {
    return;
  }

  if (!context.mounted) {
    return;
  }
  final vm = context.read<PrerequisitesViewModel>();
  final success = await vm.removePrerequisite(office, requires);

  if (!success && context.mounted && vm.errorMessage != null) {
    _showError(context, vm.errorMessage!);
  }
}

Future<void> handleAddPrerequisiteAction(
  BuildContext context,
  Office office,
) async {
  final vm = context.read<PrerequisitesViewModel>();
  final disabledMap = vm.getDisabledOfficesMap(office);

  final chosen = await showAddPrerequisiteDialog(
    context,
    offices: vm.allOffices,
    disabledIds: disabledMap['ids'] as Set<int>,
    disabledReasons: disabledMap['reasons'] as Map<int, String>,
  );

  if (chosen != null && context.mounted) {
    final success = await vm.addPrerequisite(office, chosen);
    if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.of(context).danger,
    ),
  );
}
