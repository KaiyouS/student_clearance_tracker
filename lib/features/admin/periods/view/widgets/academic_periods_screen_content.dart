import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/features/admin/periods/view/widgets/academic_periods_content.dart';
import 'package:student_clearance_tracker/features/admin/periods/view/widgets/academic_periods_header.dart';

class AcademicPeriodsScreenContent extends StatelessWidget {
  const AcademicPeriodsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AcademicPeriodsHeader(),
            SizedBox(height: 24),
            Expanded(child: AcademicPeriodsContent()),
          ],
        ),
      ),
    );
  }
}
