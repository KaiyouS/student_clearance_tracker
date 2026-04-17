import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/widgets/admin_clearance_body.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/widgets/admin_clearance_header.dart';

class AdminClearanceScreenContent extends StatelessWidget {
  const AdminClearanceScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminClearanceHeader(),
            SizedBox(height: 24),
            Expanded(child: AdminClearanceBody()),
          ],
        ),
      ),
    );
  }
}
