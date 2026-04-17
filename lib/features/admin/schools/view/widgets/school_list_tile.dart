import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/school.dart';
import 'package:student_clearance_tracker/core/widgets/confirm_dialog.dart';
import 'package:student_clearance_tracker/features/admin/schools/view/widgets/school_program_form_dialogs.dart';
import 'package:student_clearance_tracker/features/admin/schools/viewmodel/schools_viewmodel.dart';

class SchoolListTile extends StatelessWidget {
  final School school;
  final bool isSelected;

  const SchoolListTile({
    super.key,
    required this.school,
    required this.isSelected,
  });

  Future<void> _handleEditSchool(BuildContext context) async {
    final result = await showSchoolFormDialog(context, school: school);
    if (result == null) return;

    if (!context.mounted) return;
    final vm = context.read<SchoolsViewModel>();
    final success = await vm.updateSchool(school.id, result);

    if (success && context.mounted) {
      _showSuccess(context, 'School updated.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _handleDeleteSchool(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete School',
      message:
          'Are you sure you want to delete "${school.name}"? This will also '
          'delete all programs under it.',
    );
    if (!confirmed) return;

    if (!context.mounted) return;
    final vm = context.read<SchoolsViewModel>();
    final success = await vm.deleteSchool(school.id);

    if (success && context.mounted) {
      _showSuccess(context, 'School deleted.');
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
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SchoolsViewModel>();

    return ListTile(
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.primary,
      selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      title: Text(school.name, style: const TextStyle(fontSize: 13)),
      subtitle: school.description != null
          ? Text(
              school.description!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 16),
            color: Theme.of(context).colorScheme.primary,
            tooltip: 'Edit',
            onPressed: vm.isSaving ? null : () => _handleEditSchool(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 16),
            color: Theme.of(context).colorScheme.error,
            tooltip: 'Delete',
            onPressed: vm.isSaving ? null : () => _handleDeleteSchool(context),
          ),
        ],
      ),
      onTap: () => context.read<SchoolsViewModel>().selectSchool(school),
    );
  }
}

