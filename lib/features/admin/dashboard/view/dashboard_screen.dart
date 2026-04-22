import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/features/admin/dashboard/viewmodel/dashboard_viewmodel.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // The .. syntax calls loadStats() immediately after creating the ViewModel
      create: (_) => DashboardViewModel()..loadStats(),
      child: const _AdminDashboardScreenContent(),
    );
  }
}

class _AdminDashboardScreenContent extends StatelessWidget {
  const _AdminDashboardScreenContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Builder(
        builder: (context) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load dashboard.\n${vm.errorMessage}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<DashboardViewModel>().loadStats(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stats = vm.stats!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Current period: ${stats.currentPeriodLabel}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.65),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const PhosphorIcon(
                        PhosphorIconsLight.arrowsClockwise,
                      ),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () =>
                          context.read<DashboardViewModel>().loadStats(),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _StatCard(
                      label: 'Total Students',
                      value: stats.totalStudents,
                      icon: PhosphorIconsLight.graduationCap,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _StatCard(
                      label: 'Total Offices',
                      value: stats.totalOffices,
                      icon: PhosphorIconsLight.buildings,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _StatCard(
                      label: 'Total Staff',
                      value: stats.totalStaff,
                      icon: PhosphorIconsLight.user,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _StatCard(
                      label: 'Cleared Students',
                      value: stats.completedStudents,
                      icon: PhosphorIconsLight.checkCircle,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    _StatCard(
                      label: 'Pending Steps',
                      value: stats.pendingSteps,
                      icon: PhosphorIconsLight.hourglass,
                      color: AppColors.warning,
                    ),
                    _StatCard(
                      label: 'Flagged Steps',
                      value: stats.flaggedSteps,
                      icon: PhosphorIconsLight.flag,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// â”€â”€ Stat card widget â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: PhosphorIcon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
