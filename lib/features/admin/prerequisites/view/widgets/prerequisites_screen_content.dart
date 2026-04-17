import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/view/widgets/prerequisites_body.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/view/widgets/prerequisites_header.dart';

class PrerequisitesScreenContent extends StatelessWidget {
  const PrerequisitesScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrerequisitesHeader(),
            SizedBox(height: 24),
            Expanded(child: PrerequisitesBody()),
          ],
        ),
      ),
    );
  }
}
