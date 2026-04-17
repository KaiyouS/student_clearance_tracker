import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/widgets/admin_clearance_filters.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/widgets/admin_clearance_stats_row.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/widgets/admin_clearance_student_list.dart';

class AdminClearanceOverviewPanel extends StatelessWidget {
  const AdminClearanceOverviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const AdminClearanceStatsRow(),
          Divider(height: 1, color: AppColors.of(context).border),
          const AdminClearanceFilters(),
          Divider(height: 1, color: AppColors.of(context).border),
          const Expanded(child: AdminClearanceStudentList()),
        ],
      ),
    );
  }
}
