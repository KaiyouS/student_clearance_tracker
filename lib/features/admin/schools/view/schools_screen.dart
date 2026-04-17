import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/admin/schools/view/widgets/schools_screen_content.dart';
import 'package:student_clearance_tracker/features/admin/schools/viewmodel/schools_viewmodel.dart';

class SchoolsScreen extends StatelessWidget {
  const SchoolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SchoolsViewModel()..loadSchools(),
      child: const SchoolsScreenContent(),
    );
  }
}
