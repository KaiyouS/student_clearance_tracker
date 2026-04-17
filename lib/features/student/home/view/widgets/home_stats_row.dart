import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/features/student/home/view/widgets/stat_card.dart';
import 'package:student_clearance_tracker/features/student/shell/viewmodel/student_shell_viewmodel.dart';

class HomeStatsRow extends StatelessWidget {
  const HomeStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final pendingSteps = context.select<StudentShellViewModel, int>(
      (p) => p.pendingSteps,
    );
    final flaggedSteps = context.select<StudentShellViewModel, int>(
      (p) => p.flaggedSteps,
    );
    final signedSteps = context.select<StudentShellViewModel, int>(
      (p) => p.signedSteps,
    );

    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Pending',
            value: pendingSteps,
            color: AppColors.of(context).statusPending,
            icon: Icons.hourglass_empty_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: 'Flagged',
            value: flaggedSteps,
            color: AppColors.of(context).statusFlagged,
            icon: Icons.flag_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: 'Signed',
            value: signedSteps,
            color: AppColors.of(context).statusSigned,
            icon: Icons.check_circle_outline,
          ),
        ),
      ],
    );
  }
}
