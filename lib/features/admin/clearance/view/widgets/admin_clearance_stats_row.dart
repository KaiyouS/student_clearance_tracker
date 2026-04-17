import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
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
            color: AppColors.of(context).info,
          ),
          AdminClearanceMiniStat(
            label: 'Complete',
            value: stats.complete,
            color: AppColors.of(context).statusSigned,
          ),
          AdminClearanceMiniStat(
            label: 'Flagged',
            value: stats.flagged,
            color: AppColors.of(context).statusFlagged,
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
