import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/view/widgets/prerequisites_screen_content.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/viewmodel/prerequisites_viewmodel.dart';

class PrerequisitesScreen extends StatelessWidget {
  const PrerequisitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PrerequisitesViewModel()..loadData(),
      child: const PrerequisitesScreenContent(),
    );
  }
}
