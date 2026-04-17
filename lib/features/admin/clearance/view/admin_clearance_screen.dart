import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/widgets/admin_clearance_screen_content.dart';
import 'package:student_clearance_tracker/features/admin/clearance/viewmodel/admin_clearance_viewmodel.dart';

class AdminClearanceScreen extends StatelessWidget {
  const AdminClearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminClearanceViewModel()..load(),
      child: const AdminClearanceScreenContent(),
    );
  }
}
