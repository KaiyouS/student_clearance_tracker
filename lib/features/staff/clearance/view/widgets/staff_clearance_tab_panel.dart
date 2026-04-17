import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/features/staff/clearance/view/widgets/staff_clearance_status_tab.dart';
import 'package:student_clearance_tracker/features/staff/clearance/view/widgets/staff_clearance_step_list.dart';
import 'package:student_clearance_tracker/features/staff/clearance/viewmodel/staff_clearance_viewmodel.dart';

class StaffClearanceTabPanel extends StatelessWidget {
  final TabController tabController;

  const StaffClearanceTabPanel({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StaffClearanceViewModel>();

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: tabController,
            labelColor: AppColors.of(context).info,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.65),
            indicatorColor: AppColors.of(context).info,
            tabs: [
              StaffClearanceStatusTab(
                label: 'Pending',
                count: vm.statusCounts['pending'] ?? 0,
                color: AppColors.of(context).statusPending,
              ),
              StaffClearanceStatusTab(
                label: 'Flagged',
                count: vm.statusCounts['flagged'] ?? 0,
                color: AppColors.of(context).statusFlagged,
              ),
              StaffClearanceStatusTab(
                label: 'Signed',
                count: vm.statusCounts['signed'] ?? 0,
                color: AppColors.of(context).statusSigned,
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 320,
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.error != null
                ? Center(
                    child: Text(
                      vm.error!,
                      style: TextStyle(color: AppColors.of(context).danger),
                    ),
                  )
                : TabBarView(
                    controller: tabController,
                    children: const [
                      StaffClearanceStepList(status: 'pending'),
                      StaffClearanceStepList(status: 'flagged'),
                      StaffClearanceStepList(status: 'signed'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
