import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import '../../core/models/clearance_step.dart';
import '../../core/models/step_with_info.dart';
import '../../core/repositories/clearance_repository.dart';

class StepDetailScreen extends StatefulWidget {
  final StepWithInfo stepWithInfo;

  const StepDetailScreen({super.key, required this.stepWithInfo});

  @override
  State<StepDetailScreen> createState() => _StepDetailScreenState();
}

class _StepDetailScreenState extends State<StepDetailScreen> {
  final _repo = ClearanceRepository();

  List<Map<String, dynamic>> _logs = [];
  ClearanceStep? _step;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _repo.getStepById(widget.stepWithInfo.step.id),
        _repo.getStepLogs(widget.stepWithInfo.step.id),
      ]);

      setState(() {
        _step = results[0] as ClearanceStep;
        _logs = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.stepWithInfo;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Step Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Office header card
                  _OfficeHeaderCard(
                    step: _step ?? item.step,
                    item: item,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Status detail card
                  _StatusDetailCard(
                    step: _step ?? item.step,
                    item: item,
                    isDark: isDark,
                  ),

                  // Prerequisite info if blocked
                  if (item.isBlocked) ...[
                    const SizedBox(height: 16),
                    _PrerequisiteCard(
                      waitingFor: item.waitingFor,
                      isDark: isDark,
                    ),
                  ],

                  // Activity log
                  if (_logs.isNotEmpty) ...[
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
                    _ActivityLog(logs: _logs, isDark: isDark),
                  ],
                ],
              ),
            ),
    );
  }
}

// ── Office Header Card ────────────────────────────────────────
class _OfficeHeaderCard extends StatelessWidget {
  final ClearanceStep step;
  final StepWithInfo item;
  final bool isDark;

  const _OfficeHeaderCard({
    required this.step,
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.statusColorFromString(context, step.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Office name + status badge row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Office icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business_outlined,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.officeName ?? '—',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StatusBadge(status: step.status),
                  ],
                ),
              ),
            ],
          ),

          // Office description
          if (step.officeDescription != null) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              step.officeDescription!,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.65),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Status Detail Card ────────────────────────────────────────
class _StatusDetailCard extends StatelessWidget {
  final ClearanceStep step;
  final StepWithInfo item;
  final bool isDark;

  const _StatusDetailCard({
    required this.step,
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Details',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ..._buildRows(context),
        ],
      ),
    );
  }

  List<Widget> _buildRows(BuildContext context) {
    if (step.isSigned) {
      return [
        _DetailRow(
          label: 'Status',
          child: _StatusBadge(status: step.status),
        ),
        if (step.updatedAt != null)
          _DetailRow(
            label: 'Signed on',
            value: _formatDateTime(step.updatedAt!),
          ),
      ];
    }

    if (step.isFlagged) {
      return [
        _DetailRow(
          label: 'Status',
          child: _StatusBadge(status: step.status),
        ),
        if (step.updatedAt != null)
          _DetailRow(
            label: 'Flagged on',
            value: _formatDateTime(step.updatedAt!),
          ),
        if (step.remarks != null)
          _DetailRow(label: 'Reason', value: step.remarks!, isRed: true),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.of(context).danger.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.of(context).danger.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: AppColors.of(context).danger,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Visit this office to resolve the flag before '
                  'your clearance can proceed.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.of(context).danger,
                  ),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    // Pending
    return [
      _DetailRow(
        label: 'Status',
        child: _StatusBadge(status: step.status),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.isBlocked
              ? AppColors.of(context).warning.withValues(alpha: 0.06)
              : AppColors.of(context).info.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: item.isBlocked
                ? AppColors.of(context).warning.withValues(alpha: 0.3)
                : AppColors.of(context).info.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              item.isBlocked
                  ? Icons.lock_outline
                  : Icons.directions_walk_outlined,
              size: 14,
              color: item.isBlocked
                  ? AppColors.of(context).warning
                  : AppColors.of(context).info,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.isBlocked
                    ? 'This step is locked until prerequisites are complete.'
                    : 'Visit this office in person to get your clearance signed.',
                style: TextStyle(
                  fontSize: 12,
                  color: item.isBlocked
                      ? AppColors.of(context).warning
                      : AppColors.of(context).info,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  String _formatDateTime(DateTime dt) {
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
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Prerequisite Card ─────────────────────────────────────────
class _PrerequisiteCard extends StatelessWidget {
  final List<String> waitingFor;
  final bool isDark;

  const _PrerequisiteCard({required this.waitingFor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.of(context).warning.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_clock_outlined,
                color: AppColors.of(context).warning,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Waiting For Prerequisites',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.of(context).warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'The following offices must sign your clearance first:',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 10),
          ...waitingFor.map(
            (name) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.radio_button_unchecked,
                    size: 14,
                    color: AppColors.of(context).warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Activity Log ──────────────────────────────────────────────
class _ActivityLog extends StatelessWidget {
  final List<Map<String, dynamic>> logs;
  final bool isDark;

  const _ActivityLog({required this.logs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Column(
        children: logs.asMap().entries.map((entry) {
          final idx = entry.key;
          final log = entry.value;
          final isLast = idx == logs.length - 1;
          final status = log['new_status'] as String? ?? 'pending';
          final color = AppColors.statusColorFromString(context, status);
          final changedAt = log['changed_at'] != null
              ? DateTime.parse(log['changed_at'])
              : null;
          final staffName =
              log['office_staff']?['user_profiles']?['full_name'] as String?;
          final remarks = log['remarks'] as String?;
          final oldStatus = log['old_status'] as String? ?? 'pending';

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline dot + line
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Icon(_iconFor(status), size: 12, color: color),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 48,
                      color: AppColors.of(context).border,
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Log content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status change label
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(
                            context,
                          ).style.copyWith(fontSize: 13),
                          children: [
                            TextSpan(
                              text: _capitalize(oldStatus),
                              style: TextStyle(
                                color: AppColors.statusColorFromString(
                                  context,
                                  oldStatus,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' → '),
                            TextSpan(
                              text: _capitalize(status),
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Changed by
                      if (staffName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'by $staffName',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                      ],

                      // Timestamp
                      if (changedAt != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatDateTime(changedAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                      ],

                      // Remarks
                      if (remarks != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '"$remarks"',
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  IconData _iconFor(String status) => switch (status) {
    'signed' => Icons.check,
    'flagged' => Icons.flag,
    _ => Icons.circle,
  };

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _formatDateTime(DateTime dt) {
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
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Reusable widgets ──────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColorFromString(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? child;
  final bool isRed;

  const _DetailRow({
    required this.label,
    this.value,
    this.child,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ),
          Expanded(
            child:
                child ??
                Text(
                  value ?? '—',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isRed ? AppColors.of(context).danger : null,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
