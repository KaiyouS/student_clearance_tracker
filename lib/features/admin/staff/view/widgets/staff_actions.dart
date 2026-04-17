import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/office_staff.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/widgets/confirm_dialog.dart';
import 'package:student_clearance_tracker/features/admin/staff/view/staff_form_dialog.dart';
import 'package:student_clearance_tracker/features/admin/staff/viewmodel/staff_viewmodel.dart';

Future<void> handleCreateStaffAction(BuildContext context) async {
  final result = await StaffFormDialog.show(context);
  if (result == null) {
    return;
  }

  if (!context.mounted) {
    return;
  }
  final vm = context.read<StaffViewModel>();

  final success = await vm.createStaff(result);

  if (success && context.mounted) {
    _showSuccess(
      context,
      'Staff member created. They can log in with their email and employee number as password.',
    );
  } else if (!success && context.mounted && vm.errorMessage != null) {
    _showError(context, vm.errorMessage!);
  }
}

Future<void> handleEditStaffAction(
  BuildContext context,
  OfficeStaff staff,
) async {
  final result = await StaffFormDialog.show(context, staff: staff);
  if (result == null) {
    return;
  }

  if (!context.mounted) {
    return;
  }
  final vm = context.read<StaffViewModel>();

  final success = await vm.updateStaff(staff.id, result);

  if (success && context.mounted) {
    _showSuccess(context, 'Staff member updated.');
  } else if (!success && context.mounted && vm.errorMessage != null) {
    _showError(context, vm.errorMessage!);
  }
}

Future<void> handleDeleteStaffAction(
  BuildContext context,
  OfficeStaff staff,
) async {
  final confirmed = await ConfirmDialog.show(
    context,
    title: 'Delete Staff Member',
    message:
        'Are you sure you want to delete "${staff.fullName}"? Their account will be permanently removed.',
  );
  if (!confirmed) {
    return;
  }

  if (!context.mounted) {
    return;
  }
  final vm = context.read<StaffViewModel>();

  final success = await vm.deleteStaff(staff.id);

  if (success && context.mounted) {
    _showSuccess(context, 'Staff member deleted.');
  } else if (!success && context.mounted && vm.errorMessage != null) {
    _showError(context, vm.errorMessage!);
  }
}

Future<void> handleUpdateStaffStatusAction(
  BuildContext context,
  OfficeStaff staff,
  String newStatus,
) async {
  final vm = context.read<StaffViewModel>();
  final success = await vm.updateStatus(staff.id, newStatus);

  if (success && context.mounted) {
    _showSuccess(context, 'Account status updated to $newStatus.');
  } else if (!success && context.mounted && vm.errorMessage != null) {
    _showError(context, vm.errorMessage!);
  }
}

void _showSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.of(context).success,
    ),
  );
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.of(context).danger,
    ),
  );
}
