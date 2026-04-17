import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/step_with_info.dart';
import 'package:student_clearance_tracker/features/student/clearance/viewmodel/student_provider.dart';
import 'package:student_clearance_tracker/core/widgets/status_badge.dart';
import 'package:student_clearance_tracker/main.dart';
import 'package:student_clearance_tracker/features/student/clearance/view/step_detail_screen.dart';

class StudentClearanceScreen extends StatelessWidget {
  const StudentClearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<StudentProvider, bool>((p) => p.isLoading);
    final steps = context.select<StudentProvider, List<StepWithInfo>>(
      (p) => p.steps,
    );
    final _ = context.select<StudentProvider, int>(
      (p) => p.changedStepsVersion,
    );

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => context.read<StudentProvider>().loadData(
        supabase.auth.currentUser!.id,
      ),
      child: steps.isEmpty ? const _EmptySteps() : _StepsList(steps: steps),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────
class _EmptySteps extends StatelessWidget {
  const _EmptySteps();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.checklist_outlined,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'No Clearance Steps Yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Pull down to refresh.',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Steps list ────────────────────────────────────────────────
class _StepsList extends StatelessWidget {
  final List<StepWithInfo> steps;
  const _StepsList({required this.steps});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StudentProvider>();

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
              (context, i) => GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StepDetailScreen(stepWithInfo: steps[i]),
                  ),
                ),
                child: _StepCard(
                  item: steps[i],
                  isLast: i == steps.length - 1,
                  prevLevel: i > 0 ? steps[i - 1].level : null,
                  wasChanged: provider.wasStepChanged(steps[i].step.id),
                ),
              ),
              childCount: steps.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Individual step card ──────────────────────────────────────
class _StepCard extends StatelessWidget {
  final StepWithInfo item;
  final bool isLast;
  final int? prevLevel;
  final bool wasChanged;

  const _StepCard({
    required this.item,
    required this.isLast,
    required this.prevLevel,
    required this.wasChanged,
  });

  @override
  Widget build(BuildContext context) {
    final step = item.step;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNewLevel = prevLevel != null && item.level != prevLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level separator label
        if (isNewLevel) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_downward,
                  size: 14,
                  color: AppColors.of(context).neutral,
                ),
                const SizedBox(width: 4),
                Text(
                  'Requires above steps',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.of(context).neutral
                        : AppColors.of(context).neutral,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Step card
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left timeline
            Column(
              children: [
                _StatusCircle(status: step.status),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    color: (isDark
                        ? AppColors.of(context).border
                        : AppColors.of(context).border),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Card content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: step.status == 'flagged'
                        ? AppColors.of(
                            context,
                          ).statusFlagged.withValues(alpha: 0.5)
                        : isDark
                        ? AppColors.of(context).border
                        : AppColors.of(context).border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Office name + status badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            step.officeName ?? '—',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        if (wasChanged)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.of(
                                context,
                              ).info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.of(
                                  context,
                                ).info.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              'Updated',
                              style: TextStyle(
                                color: AppColors.of(context).info,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        StatusBadge(status: step.status),
                      ],
                    ),

                    // Status details
                    const SizedBox(height: 8),
                    ..._buildDetails(context, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildDetails(BuildContext context, bool isDark) {
    final step = item.step;
    final details = <Widget>[];

    if (step.isSigned) {
      details.add(
        _DetailRow(
          icon: Icons.check_circle_outline,
          color: AppColors.of(context).statusSigned,
          text: step.updatedAt != null
              ? 'Signed on ${_formatDate(step.updatedAt!)}'
              : 'Signed',
        ),
      );
    } else if (step.isFlagged) {
      details.add(
        _DetailRow(
          icon: Icons.flag_outlined,
          color: AppColors.of(context).statusFlagged,
          text: step.remarks != null
              ? 'Flagged: ${step.remarks}'
              : 'This step has been flagged.',
        ),
      );
    } else if (item.isBlocked) {
      // Blocked by prerequisites
      details.add(
        _DetailRow(
          icon: Icons.lock_outline,
          color: AppColors.of(context).warning,
          text: 'Waiting for: ${item.waitingFor.join(', ')}',
        ),
      );
    } else {
      // Pending and can be signed
      details.add(
        _DetailRow(
          icon: Icons.pending_outlined,
          color: AppColors.of(context).statusPending,
          text: 'Visit this office to get your clearance signed.',
        ),
      );
    }

    return details;
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

// ── Status circle for timeline ────────────────────────────────
class _StatusCircle extends StatelessWidget {
  final String status;
  const _StatusCircle({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColorFromString(context, status);
    final icon = switch (status) {
      'signed' => Icons.check,
      'flagged' => Icons.flag,
      _ => Icons.circle_outlined,
    };

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}

// ── Detail row ────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _DetailRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 12, color: color)),
        ),
        Icon(
          Icons.chevron_right,
          size: 16,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.65), // ← add this
        ),
      ],
    );
  }
}
