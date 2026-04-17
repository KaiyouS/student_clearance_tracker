import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/admin/periods/view/widgets/academic_periods_screen_content.dart';
import 'package:student_clearance_tracker/features/admin/periods/viewmodel/periods_viewmodel.dart';

class AcademicPeriodsScreen extends StatelessWidget {
  const AcademicPeriodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PeriodsViewModel()..loadPeriods(),
      child: const AcademicPeriodsScreenContent(),
    );
  }
}
