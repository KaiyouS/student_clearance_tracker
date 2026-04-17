import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/student/home/view/widgets/clearance_status_card.dart';
import 'package:student_clearance_tracker/features/student/home/view/widgets/home_error_state.dart';
import 'package:student_clearance_tracker/features/student/home/view/widgets/home_stats_row.dart';
import 'package:student_clearance_tracker/features/student/home/view/widgets/next_step_card.dart';
import 'package:student_clearance_tracker/features/student/home/view/widgets/no_clearance_card.dart';
import 'package:student_clearance_tracker/features/student/home/view/widgets/student_home_greeting.dart';
import 'package:student_clearance_tracker/features/student/shell/viewmodel/student_shell_viewmodel.dart';
import 'package:student_clearance_tracker/main.dart';

class StudentHomeBody extends StatelessWidget {
  const StudentHomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<StudentShellViewModel, bool>(
      (p) => p.isLoading,
    );
    final hasError = context.select<StudentShellViewModel, bool>(
      (p) => p.error != null,
    );
    final hasSteps = context.select<StudentShellViewModel, bool>(
      (p) => p.hasSteps,
    );
    final showNextStep = context.select<StudentShellViewModel, bool>(
      (p) => p.hasSteps && !p.isComplete,
    );

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return const HomeErrorState();
    }

    return RefreshIndicator(
      onRefresh: () => context.read<StudentShellViewModel>().loadData(
        supabase.auth.currentUser!.id,
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StudentHomeGreeting(),
            const SizedBox(height: 24),
            const ClearanceStatusCard(),
            const SizedBox(height: 16),
            if (showNextStep) ...[
              const NextStepCard(),
              const SizedBox(height: 16),
            ],
            if (hasSteps) ...[
              const HomeStatsRow(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/student/clearance'),
                  icon: const Icon(Icons.checklist_outlined),
                  label: const Text('View Clearance Steps'),
                ),
              ),
            ] else ...[
              const NoClearanceCard(),
            ],
          ],
        ),
      ),
    );
  }
}
