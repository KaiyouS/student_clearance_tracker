import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/view/widgets/prerequisite_chip_row.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/view/widgets/prerequisites_actions.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/view/widgets/prerequisites_info_banner.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/viewmodel/prerequisites_viewmodel.dart';

class PrerequisitesPrerequisitePanel extends StatelessWidget {
  const PrerequisitesPrerequisitePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PrerequisitesViewModel>();
    final office = vm.selectedOffice;

    if (office == null) {
      return const SizedBox.shrink();
    }

    final prereqs = vm.prerequisitesFor(office);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      office.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prereqs.isEmpty
                          ? 'No prerequisites - can be signed at any time.'
                          : 'Must be preceded by ${prereqs.length} office${prereqs.length > 1 ? 's' : ''}.',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (vm.isSaving)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => handleAddPrerequisiteAction(context, office),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Prerequisite'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Theme.of(context).dividerColor),
          const SizedBox(height: 12),
          if (prereqs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No prerequisites set.',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ),
            )
          else
            ...prereqs.map(
              (req) => PrerequisiteChipRow(office: office, prerequisite: req),
            ),
          if (prereqs.isNotEmpty) ...[
            const SizedBox(height: 16),
            PrerequisitesInfoBanner(officeName: office.name),
          ],
        ],
      ),
    );
  }
}

