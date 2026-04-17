import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/student/shell/viewmodel/student_shell_viewmodel.dart';

class StudentHomeGreeting extends StatelessWidget {
  const StudentHomeGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    final firstName = context.select<StudentShellViewModel, String?>(
      (p) => p.profile?.firstName,
    );
    final periodLabel = context.select<StudentShellViewModel, String?>(
      (p) => p.currentPeriod?.label,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi, ${firstName ?? 'Student'}! 👋',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          periodLabel ?? 'No active period',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
