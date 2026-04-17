import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/admin/staff/view/widgets/staff_screen_content.dart';
import 'package:student_clearance_tracker/features/admin/staff/viewmodel/staff_viewmodel.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StaffViewModel()..loadStaff(),
      child: const StaffScreenContent(),
    );
  }
}
