import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/widgets/admin_clearance_mini_stat.dart';
import 'package:student_clearance_tracker/features/admin/clearance/viewmodel/admin_clearance_viewmodel.dart';

class AdminClearanceStatsRow extends StatelessWidget {
  const AdminClearanceStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context
        .select<AdminClearanceViewModel, AdminClearanceOverviewStats>(
          (vm) => vm.overviewStats,
        );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          AdminClearanceMiniStat(
            label: 'Total',
            value: stats.total,
            color: Theme.of(context).colorScheme.primary,
          ),
          AdminClearanceMiniStat(
            label: 'Complete',
            value: stats.complete,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          AdminClearanceMiniStat(
            label: 'Flagged',
            value: stats.flagged,
            color: Theme.of(context).colorScheme.error,
          ),
          AdminClearanceMiniStat(
            label: 'No Steps',
            value: stats.noClearance,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ],
      ),
    );
  }
}

