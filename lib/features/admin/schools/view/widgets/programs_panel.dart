import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/features/admin/schools/view/widgets/program_list_tile.dart';
import 'package:student_clearance_tracker/features/admin/schools/view/widgets/school_program_form_dialogs.dart';
import 'package:student_clearance_tracker/features/admin/schools/viewmodel/schools_viewmodel.dart';

class ProgramsPanel extends StatelessWidget {
  const ProgramsPanel({super.key});

  Future<void> _handleCreateProgram(BuildContext context) async {
    final vm = context.read<SchoolsViewModel>();
    if (vm.selectedSchool == null) return;

    final result = await showProgramFormDialog(context);
    if (result == null) return;

    if (!context.mounted) return;
    final success = await vm.createProgram(result);

    if (success && context.mounted) {
      _showSuccess(context, 'Program created.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  void _showSuccess(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.of(context).success,
      ),
    );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.of(context).danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SchoolsViewModel>();
    final school = vm.selectedSchool;

    if (school == null) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      school.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vm.isLoadingPrograms
                          ? 'Loading...'
                          : '${vm.programs.length} program${vm.programs.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: vm.isSaving
                    ? null
                    : () => _handleCreateProgram(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Program'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.of(context).border),
          const SizedBox(height: 8),
          if (vm.isLoadingPrograms)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (vm.programs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No programs yet. Add one above.',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: vm.programs.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: AppColors.of(context).border),
                itemBuilder: (context, i) {
                  return ProgramListTile(program: vm.programs[i]);
                },
              ),
            ),
        ],
      ),
    );
  }
}
