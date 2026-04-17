import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/view/widgets/prerequisites_office_list_panel.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/view/widgets/prerequisites_prerequisite_panel.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/viewmodel/prerequisites_viewmodel.dart';

class PrerequisitesBody extends StatelessWidget {
  const PrerequisitesBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PrerequisitesViewModel>();

    if (vm.isLoading && vm.allOffices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null && vm.allOffices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              vm.errorMessage!,
              style: TextStyle(color: AppColors.of(context).danger),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: vm.loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 280, child: PrerequisitesOfficeListPanel()),
        const SizedBox(width: 16),
        Expanded(
          child: vm.selectedOffice == null
              ? AppCard(
                  child: Center(
                    child: Text(
                      'Select an office to manage its prerequisites.',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                )
              : const PrerequisitesPrerequisitePanel(),
        ),
      ],
    );
  }
}
