import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/step_with_info.dart';
import 'package:student_clearance_tracker/features/student/clearance/view/widgets/step_detail_body.dart';
import 'package:student_clearance_tracker/features/student/clearance/viewmodel/step_detail_viewmodel.dart';

class StepDetailScreen extends StatelessWidget {
  final StepWithInfo stepWithInfo;

  const StepDetailScreen({super.key, required this.stepWithInfo});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StepDetailViewModel(stepWithInfo: stepWithInfo)..load(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Step Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const StepDetailBody(),
      ),
    );
  }
}
