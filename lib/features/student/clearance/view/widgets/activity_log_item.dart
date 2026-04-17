import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/features/student/clearance/viewmodel/step_detail_viewmodel.dart';

class ActivityLogItem extends StatelessWidget {
  final int index;
  final bool isLast;

  const ActivityLogItem({super.key, required this.index, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<StepDetailViewModel>().logs;
    final log = logs[index];
    final status = log['new_status'] as String? ?? 'pending';
    final color = AppColors.forStatus( status);
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
                color: Theme.of(context).dividerColor,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(
                      context,
                    ).style.copyWith(fontSize: 13),
                    children: [
                      TextSpan(
                        text: _capitalize(oldStatus),
                        style: TextStyle(
                          color: AppColors.forStatus(
                            oldStatus,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' â†’ '),
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

