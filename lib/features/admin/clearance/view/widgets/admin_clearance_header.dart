import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/widgets/admin_clearance_actions.dart';
import 'package:student_clearance_tracker/features/admin/clearance/viewmodel/admin_clearance_viewmodel.dart';

class AdminClearanceHeader extends StatelessWidget {
  const AdminClearanceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminClearanceViewModel>();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clearance',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                vm.currentPeriodLabel != null
                    ? 'Current period: ${vm.currentPeriodLabel}'
                    : 'No active period set.',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.65),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (vm.isGenerating)
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ElevatedButton.icon(
          onPressed: (vm.isGenerating || vm.currentPeriodId == null)
              ? null
              : () => handleGenerateForAllAction(context),
          icon: const Icon(Icons.auto_awesome, size: 16),
          label: const Text('Generate All'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.of(context).success,
          ),
        ),
      ],
    );
  }
}
