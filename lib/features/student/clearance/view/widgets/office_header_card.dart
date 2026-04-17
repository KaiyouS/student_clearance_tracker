import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/widgets/status_badge.dart';
import 'package:student_clearance_tracker/features/student/clearance/viewmodel/step_detail_viewmodel.dart';

class OfficeHeaderCard extends StatelessWidget {
  const OfficeHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final step = context.watch<StepDetailViewModel>().step;
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    StatusBadge(status: step.status),
                  ],
                ),
              ),
            ],
          ),
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
