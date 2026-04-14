import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/models/step_with_info.dart';
import 'package:student_clearance_tracker/core/providers/student_provider.dart';
import 'package:student_clearance_tracker/main.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.of(context).danger,
            ),
            const SizedBox(height: 12),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.of(context).danger),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => provider.loadData(supabase.auth.currentUser!.id),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadData(supabase.auth.currentUser!.id),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              'Hi, ${provider.profile?.firstName ?? 'Student'}! 👋',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              provider.currentPeriod?.label ?? 'No active period',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Overall clearance status card
            _ClearanceStatusCard(provider: provider),
            const SizedBox(height: 16),

            if (provider.hasSteps && !provider.isComplete) ...[
              _NextStepCard(step: provider.nextActionableStep),
              const SizedBox(height: 16),
            ],

            // Stats row
            if (provider.hasSteps) ...[
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Pending',
                      value: provider.pendingSteps,
                      color: AppColors.of(context).statusPending,
                      icon: Icons.hourglass_empty_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Flagged',
                      value: provider.flaggedSteps,
                      color: AppColors.of(context).statusFlagged,
                      icon: Icons.flag_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Signed',
                      value: provider.signedSteps,
                      color: AppColors.of(context).statusSigned,
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // View clearance button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/student/clearance'),
                  icon: Icon(Icons.checklist_outlined),
                  label: const Text('View Clearance Steps'),
                ),
              ),
            ] else ...[
              // No clearance yet
              _NoClearanceCard(),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Overall clearance status card ────────────────────────────
class _ClearanceStatusCard extends StatelessWidget {
  final StudentProvider provider;
  const _ClearanceStatusCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isComplete = provider.isComplete;
    final hasSteps = provider.hasSteps;
    final total = provider.totalSteps;
    final signed = provider.signedSteps;
    final color = isComplete
        ? AppColors.of(context).statusSigned
        : AppColors.of(context).info;

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
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: total > 0 ? signed / total : 0,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$signed of $total offices signed',
              style: TextStyle(color: color, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── No clearance generated yet ────────────────────────────────
class _NoClearanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.hourglass_empty_outlined,
            size: 48,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No Clearance Generated Yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Your clearance steps will appear here once the admin '
            'generates them for the current period.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  final StepWithInfo? step;
  const _NextStepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // All remaining steps are blocked — nothing actionable
    if (step == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppColors.of(context).border
                : AppColors.of(context).border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.lock_clock_outlined,
              color: AppColors.of(context).warning,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No steps are ready to sign yet — '
                'waiting for prerequisites.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.of(context).neutral
                      : AppColors.of(context).neutral,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => context.go('/student/clearance'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.of(context).info.withValues(alpha: 0.12),
              AppColors.of(context).info.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.of(context).info.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Pulsing icon to draw attention
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.of(context).info.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_circle_right_outlined,
                color: AppColors.of(context).info,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Step',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.of(context).info,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step!.step.officeName ?? '—',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).info,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to view clearance steps →',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.of(context).info,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
