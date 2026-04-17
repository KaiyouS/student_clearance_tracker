import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/academic_period.dart';
import 'package:student_clearance_tracker/core/widgets/confirm_dialog.dart';
import 'package:student_clearance_tracker/features/admin/periods/view/academic_period_form_dialog.dart';
import 'package:student_clearance_tracker/features/admin/periods/viewmodel/periods_viewmodel.dart';

Future<void> handleCreatePeriodAction(BuildContext context) async {
  final result = await AcademicPeriodFormDialog.show(context);
  if (result == null) {
    return;
  }

  if (!context.mounted) {
    return;
  }
  final vm = context.read<PeriodsViewModel>();
  final success = await vm.createPeriod(result);

  if (success && context.mounted) {
    _showSuccess(context, 'Academic period created.');
  } else if (!success && context.mounted && vm.errorMessage != null) {
    _showError(context, vm.errorMessage!);
  }
}

Future<void> handleEditPeriodAction(
  BuildContext context,
  AcademicPeriod period,
) async {
  final result = await AcademicPeriodFormDialog.show(context, period: period);
  if (result == null) {
    return;
  }

  if (!context.mounted) {
    return;
  }
  final vm = context.read<PeriodsViewModel>();
  final success = await vm.updatePeriod(period.id, result, period.isCurrent);

  if (success && context.mounted) {
    _showSuccess(context, 'Academic period updated.');
  } else if (!success && context.mounted && vm.errorMessage != null) {
    _showError(context, vm.errorMessage!);
  }
}

Future<void> handleDeletePeriodAction(
  BuildContext context,
  AcademicPeriod period,
) async {
  if (period.isCurrent) {
    _showError(
      context,
      'Cannot delete the current period. Set another period as current first.',
    );
    return;
  }

  final confirmed = await ConfirmDialog.show(
    context,
    title: 'Delete Period',
    message:
        'Are you sure you want to delete "${period.label}"? All clearance steps for this period will also be deleted.',
  );
  if (!confirmed) {
    return;
  }

  if (!context.mounted) {
    return;
  }
  final vm = context.read<PeriodsViewModel>();
  final success = await vm.deletePeriod(period);

  if (success && context.mounted) {
    _showSuccess(context, 'Academic period deleted.');
  } else if (!success && context.mounted && vm.errorMessage != null) {
    _showError(context, vm.errorMessage!);
  }
}

Future<void> handleSetCurrentPeriodAction(
  BuildContext context,
  AcademicPeriod period,
) async {
  final confirmed = await ConfirmDialog.show(
    context,
    title: 'Set as Current Period',
    message:
        'Set "${period.label}" as the current academic period? The previous current period will be unset.',
    confirmLabel: 'Set as Current',
    confirmColor: Theme.of(context).colorScheme.primary,
  );
  if (!confirmed) {
    return;
  }

  if (!context.mounted) {
    return;
  }
  final vm = context.read<PeriodsViewModel>();
  final success = await vm.setCurrentPeriod(period);

  if (success && context.mounted) {
    _showSuccess(context, '"${period.label}" is now the current period.');
  } else if (!success && context.mounted && vm.errorMessage != null) {
    _showError(context, vm.errorMessage!);
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

