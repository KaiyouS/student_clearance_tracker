import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/features/admin/schools/view/widgets/programs_panel.dart';
import 'package:student_clearance_tracker/features/admin/schools/view/widgets/schools_list_panel.dart';
import 'package:student_clearance_tracker/features/admin/schools/viewmodel/schools_viewmodel.dart';

class SchoolsBody extends StatelessWidget {
  const SchoolsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SchoolsViewModel>();

    if (vm.isLoadingSchools) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null && vm.schools.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              vm.errorMessage!,
              style: TextStyle(color: AppColors.of(context).danger),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: vm.loadSchools,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 300, child: SchoolsListPanel()),
        const SizedBox(width: 16),
        Expanded(
          child: vm.selectedSchool == null
              ? AppCard(
                  child: Center(
                    child: Text(
                      'Select a school to manage its programs.',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                )
              : const ProgramsPanel(),
        ),
      ],
    );
  }
}
