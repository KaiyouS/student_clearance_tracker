import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/widgets/admin_clearance_detail_panel.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/widgets/admin_clearance_overview_panel.dart';
import 'package:student_clearance_tracker/features/admin/clearance/viewmodel/admin_clearance_viewmodel.dart';

class AdminClearanceBody extends StatelessWidget {
  const AdminClearanceBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminClearanceViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              vm.error!,
              style: TextStyle(color: AppColors.of(context).danger),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: vm.load, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 380, child: AdminClearanceOverviewPanel()),
        const SizedBox(width: 16),
        Expanded(
          child: vm.selectedStudent == null
              ? AppCard(
                  child: Center(
                    child: Text(
                      'Select a student to view their clearance.',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                )
              : const AdminClearanceDetailPanel(),
        ),
      ],
    );
  }
}
