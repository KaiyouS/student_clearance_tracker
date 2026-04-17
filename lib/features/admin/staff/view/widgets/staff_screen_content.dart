import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/features/admin/staff/view/widgets/staff_content.dart';
import 'package:student_clearance_tracker/features/admin/staff/view/widgets/staff_header.dart';
import 'package:student_clearance_tracker/features/admin/staff/view/widgets/staff_search_bar.dart';

class StaffScreenContent extends StatelessWidget {
  const StaffScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StaffHeader(),
            SizedBox(height: 24),
            StaffSearchBar(),
            SizedBox(height: 16),
            Expanded(child: StaffContent()),
          ],
        ),
      ),
    );
  }
}
