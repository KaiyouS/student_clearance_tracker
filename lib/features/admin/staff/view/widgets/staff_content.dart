import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/features/admin/staff/view/widgets/staff_table.dart';
import 'package:student_clearance_tracker/features/admin/staff/viewmodel/staff_viewmodel.dart';

class StaffContent extends StatelessWidget {
  const StaffContent({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StaffViewModel>();

    if (vm.isLoading && vm.filteredStaff.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null && vm.filteredStaff.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              vm.errorMessage!,
              style: TextStyle(color: AppColors.of(context).danger),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: vm.loadStaff, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (vm.filteredStaff.isEmpty) {
      return Center(
        child: Text(
          vm.searchQuery.isEmpty
              ? 'No staff yet.'
              : 'No staff match "${vm.searchQuery}".',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      );
    }

    return StaffTable(staffList: vm.filteredStaff);
  }
}
