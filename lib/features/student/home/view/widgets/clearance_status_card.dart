import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/student/shell/viewmodel/student_shell_viewmodel.dart';

class ClearanceStatusCard extends StatelessWidget {
  const ClearanceStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isComplete = context.select<StudentShellViewModel, bool>(
      (p) => p.isComplete,
    );
    final hasSteps = context.select<StudentShellViewModel, bool>(
      (p) => p.hasSteps,
    );
    final totalSteps = context.select<StudentShellViewModel, int>(
      (p) => p.totalSteps,
    );
    final signedSteps = context.select<StudentShellViewModel, int>(
      (p) => p.signedSteps,
    );

    final color = isComplete
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isComplete ? Icons.verified_outlined : Icons.pending_outlined,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isComplete
                    ? 'Clearance Complete!'
                    : hasSteps
                    ? 'Clearance In Progress'
                    : 'Awaiting Clearance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          if (hasSteps) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: totalSteps > 0 ? signedSteps / totalSteps : 0,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$signedSteps of $totalSteps offices signed',
              style: TextStyle(color: color, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

