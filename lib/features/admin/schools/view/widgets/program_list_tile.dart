import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/core/models/program.dart';
import 'package:student_clearance_tracker/core/widgets/confirm_dialog.dart';
import 'package:student_clearance_tracker/features/admin/schools/view/widgets/school_program_form_dialogs.dart';
import 'package:student_clearance_tracker/features/admin/schools/viewmodel/schools_viewmodel.dart';

class ProgramListTile extends StatelessWidget {
  final Program program;

  const ProgramListTile({super.key, required this.program});

  Future<void> _handleEditProgram(BuildContext context) async {
    final result = await showProgramFormDialog(context, program: program);
    if (result == null) return;

    if (!context.mounted) return;
    final vm = context.read<SchoolsViewModel>();
    final success = await vm.updateProgram(program.id, result);

    if (success && context.mounted) {
      _showSuccess(context, 'Program updated.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _handleDeleteProgram(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Program',
      message:
          'Are you sure you want to delete "${program.name}"? Students '
          'assigned to this program will have no program.',
    );
    if (!confirmed) return;

    if (!context.mounted) return;
    final vm = context.read<SchoolsViewModel>();
    final success = await vm.deleteProgram(program.id);

    if (success && context.mounted) {
      _showSuccess(context, 'Program deleted.');
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
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: PhosphorIcon(
          PhosphorIconsLight.graduationCap,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        program.name,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const PhosphorIcon(PhosphorIconsLight.pencilSimple, size: 18),
            color: Theme.of(context).colorScheme.primary,
            tooltip: 'Edit',
            onPressed: vm.isSaving ? null : () => _handleEditProgram(context),
          ),
          IconButton(
            icon: const PhosphorIcon(PhosphorIconsLight.trash, size: 18),
            color: Theme.of(context).colorScheme.error,
            tooltip: 'Delete',
            onPressed: vm.isSaving ? null : () => _handleDeleteProgram(context),
          ),
        ],
      ),
    );
  }
}
