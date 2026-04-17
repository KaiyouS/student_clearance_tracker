import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/student/clearance/view/widgets/activity_log_panel.dart';
import 'package:student_clearance_tracker/features/student/clearance/view/widgets/office_header_card.dart';
import 'package:student_clearance_tracker/features/student/clearance/view/widgets/prerequisite_card.dart';
import 'package:student_clearance_tracker/features/student/clearance/view/widgets/status_detail_card.dart';
import 'package:student_clearance_tracker/features/student/clearance/viewmodel/step_detail_viewmodel.dart';

class StepDetailBody extends StatelessWidget {
  const StepDetailBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<StepDetailViewModel, bool>(
      (vm) => vm.isLoading,
    );
    final isBlocked = context.select<StepDetailViewModel, bool>(
      (vm) => vm.isBlocked,
    );
    final hasLogs = context.select<StepDetailViewModel, bool>(
      (vm) => vm.logs.isNotEmpty,
    );

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OfficeHeaderCard(),
          const SizedBox(height: 16),
          const StatusDetailCard(),
          if (isBlocked) ...[
            const SizedBox(height: 16),
            const PrerequisiteCard(),
          ],
          if (hasLogs) ...[
            const SizedBox(height: 24),
            Text(
              'Activity Log',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 8),
            const ActivityLogPanel(),
          ],
        ],
      ),
    );
  }
}
