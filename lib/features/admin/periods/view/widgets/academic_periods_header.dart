import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/features/admin/periods/view/widgets/academic_periods_actions.dart';
import 'package:student_clearance_tracker/features/admin/periods/viewmodel/periods_viewmodel.dart';

class AcademicPeriodsHeader extends StatelessWidget {
  const AcademicPeriodsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isSaving = context.select<PeriodsViewModel, bool>(
      (vm) => vm.isSaving,
    );

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Academic Periods',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage academic periods and set the active one.',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.65),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (isSaving)
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ElevatedButton.icon(
          onPressed: isSaving ? null : () => handleCreatePeriodAction(context),
          icon: const PhosphorIcon(PhosphorIconsLight.plus),
          label: const Text('Add Period'),
        ),
      ],
    );
  }
}
