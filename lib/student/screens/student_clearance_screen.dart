import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/step_with_info.dart';
import '../../core/providers/student_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';

class StudentClearanceScreen extends StatelessWidget {
  const StudentClearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () =>
          provider.loadData(supabase.auth.currentUser!.id),
      child: provider.steps.isEmpty
          ? const _EmptySteps()
          : _StepsList(steps: provider.steps),
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
                size:  64,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.2),
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
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
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
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Clearance Steps',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _StepCard(
                item:       steps[i],
                isLast:     i == steps.length - 1,
                prevLevel:  i > 0 ? steps[i - 1].level : null,
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
  final bool         isLast;
  final int?         prevLevel;

  const _StepCard({
    required this.item,
    required this.isLast,
    required this.prevLevel,
  });

  @override
  Widget build(BuildContext context) {
    final step        = item.step;
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final isNewLevel  = prevLevel != null && item.level != prevLevel;

    // Status colors
    final statusColor = AppTheme.statusColor(step.status);

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
                const Icon(
                  Icons.arrow_downward,
                  size:  14,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Requires above steps',
                  style: TextStyle(
                    fontSize: 11,
                    color:    isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textSecondary,
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
                    width:  2,
                    height: 60,
                    color:  (isDark ? AppTheme.darkBorder : AppTheme.border),
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
                  color:        isDark
                      ? AppTheme.darkSurface
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: step.status == 'flagged'
                        ? AppTheme.statusFlagged.withValues(alpha: 0.5)
                        : isDark
                            ? AppTheme.darkBorder
                            : AppTheme.border,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize:   14,
                            ),
                          ),
                        ),
                        _StatusBadge(status: step.status),
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
    final step    = item.step;
    final details = <Widget>[];

    if (step.isSigned) {
      details.add(
        _DetailRow(
          icon:  Icons.check_circle_outline,
          color: AppTheme.statusSigned,
          text:  step.updatedAt != null
              ? 'Signed on ${_formatDate(step.updatedAt!)}'
              : 'Signed',
        ),
      );
    } else if (step.isFlagged) {
      details.add(
        _DetailRow(
          icon:  Icons.flag_outlined,
          color: AppTheme.statusFlagged,
          text:  step.remarks != null
              ? 'Flagged: ${step.remarks}'
              : 'This step has been flagged.',
        ),
      );
    } else if (item.isBlocked) {
      // Blocked by prerequisites
      details.add(
        _DetailRow(
          icon:  Icons.lock_outline,
          color: AppTheme.warning,
          text:  'Waiting for: ${item.waitingFor.join(', ')}',
        ),
      );
    } else {
      // Pending and can be signed
      details.add(
        _DetailRow(
          icon:  Icons.pending_outlined,
          color: AppTheme.statusPending,
          text:  'Visit this office to get your clearance signed.',
        ),
      );
    }

    return details;
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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
    final color = AppTheme.statusColor(status);
    final icon  = switch (status) {
      'signed'  => Icons.check,
      'flagged' => Icons.flag,
      _         => Icons.circle_outlined,
    };

    return Container(
      width:  28,
      height: 28,
      decoration: BoxDecoration(
        color:  color.withValues(alpha: 0.15),
        shape:  BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColor(status);
    final label = status[0].toUpperCase() + status.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color:      color,
          fontSize:   11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Detail row ────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final String   text;

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
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color:    color,
            ),
          ),
        ),
      ],
    );
  }
}