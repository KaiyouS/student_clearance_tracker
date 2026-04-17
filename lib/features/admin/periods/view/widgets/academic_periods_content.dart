import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/features/admin/periods/view/widgets/academic_periods_table.dart';
import 'package:student_clearance_tracker/features/admin/periods/viewmodel/periods_viewmodel.dart';

class AcademicPeriodsContent extends StatelessWidget {
  const AcademicPeriodsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PeriodsViewModel>();

    if (vm.isLoading && vm.periods.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null && vm.periods.isEmpty) {
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
              onPressed: vm.loadPeriods,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (vm.periods.isEmpty) {
      return Center(
        child: Text(
          'No academic periods yet.',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      );
    }

    return AcademicPeriodsTable(periods: vm.periods);
  }
}
