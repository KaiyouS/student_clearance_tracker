import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/features/staff/clearance/view/widgets/staff_clearance_header.dart';
import 'package:student_clearance_tracker/features/staff/clearance/view/widgets/staff_clearance_search_bar.dart';
import 'package:student_clearance_tracker/features/staff/clearance/view/widgets/staff_clearance_tab_panel.dart';

class StaffClearanceScreenContent extends StatelessWidget {
  final TabController tabController;

  const StaffClearanceScreenContent({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StaffClearanceHeader(),
            const SizedBox(height: 16),
            const StaffClearanceSearchBar(),
            const SizedBox(height: 16),
            StaffClearanceTabPanel(tabController: tabController),
          ],
        ),
      ),
    );
  }
}
