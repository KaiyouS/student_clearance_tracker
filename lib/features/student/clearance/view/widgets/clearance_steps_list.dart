import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/student/clearance/view/widgets/clearance_step_card.dart';
import 'package:student_clearance_tracker/features/student/shell/viewmodel/student_shell_viewmodel.dart';

class ClearanceStepsList extends StatelessWidget {
  const ClearanceStepsList({super.key});

  @override
  Widget build(BuildContext context) {
    final stepCount = context.select<StudentShellViewModel, int>(
      (p) => p.steps.length,
    );

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Clearance Steps',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) =>
                  ClearanceStepCard(index: i, isLast: i == stepCount - 1),
              childCount: stepCount,
            ),
          ),
        ),
      ],
    );
  }
}
