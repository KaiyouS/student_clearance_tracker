import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/features/admin/staff/view/widgets/staff_actions.dart';
import 'package:student_clearance_tracker/features/admin/staff/viewmodel/staff_viewmodel.dart';

class StaffHeader extends StatelessWidget {
  const StaffHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isSaving = context.select<StaffViewModel, bool>((vm) => vm.isSaving);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staff',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage office staff and their office assignments.',
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
          onPressed: isSaving ? null : () => handleCreateStaffAction(context),
          icon: const PhosphorIcon(PhosphorIconsLight.plus),
          label: const Text('Add Staff'),
        ),
      ],
    );
  }
}
