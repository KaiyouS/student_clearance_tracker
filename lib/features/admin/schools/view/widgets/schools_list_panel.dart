import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/features/admin/schools/view/widgets/school_list_tile.dart';
import 'package:student_clearance_tracker/features/admin/schools/view/widgets/school_program_form_dialogs.dart';
import 'package:student_clearance_tracker/features/admin/schools/viewmodel/schools_viewmodel.dart';

class SchoolsListPanel extends StatelessWidget {
  const SchoolsListPanel({super.key});

  Future<void> _handleCreateSchool(BuildContext context) async {
    final result = await showSchoolFormDialog(context);
    if (result == null) return;

    if (!context.mounted) return;
    final vm = context.read<SchoolsViewModel>();
    final success = await vm.createSchool(result);

    if (success && context.mounted) {
      _showSuccess(context, 'School created.');
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

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Schools',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  color: Theme.of(context).colorScheme.primary,
                  tooltip: 'Add School',
                  onPressed: vm.isSaving
                      ? null
                      : () => _handleCreateSchool(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Expanded(
            child: vm.schools.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No schools yet.',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: vm.schools.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: Theme.of(context).dividerColor),
                    itemBuilder: (context, i) {
                      final school = vm.schools[i];
                      final isSelected = vm.selectedSchool?.id == school.id;

                      return SchoolListTile(
                        school: school,
                        isSelected: isSelected,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

