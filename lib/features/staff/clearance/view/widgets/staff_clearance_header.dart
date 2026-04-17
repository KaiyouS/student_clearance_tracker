import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/features/staff/clearance/viewmodel/staff_clearance_viewmodel.dart';
import 'package:student_clearance_tracker/features/staff/shell/viewmodel/staff_shell_viewmodel.dart';

class StaffClearanceHeader extends StatelessWidget {
  const StaffClearanceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final officeName = context.select<StaffShellViewModel, String>(
      (p) => p.selectedOffice?.name ?? 'No Office Selected',
    );
    final selectedOfficeId = context.select<StaffShellViewModel, int?>(
      (p) => p.selectedOffice?.id,
    );
    final isLoading = context.select<StaffClearanceViewModel, bool>(
      (vm) => vm.isLoading,
    );

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                officeName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Review and sign student clearance requests.',
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
        IconButton(
          icon: const Icon(Icons.refresh),
          color: AppColors.of(context).info,
          tooltip: 'Refresh',
          onPressed: isLoading
              ? null
              : () => context.read<StaffClearanceViewModel>().loadSteps(
                  selectedOfficeId,
                ),
        ),
      ],
    );
  }
}
