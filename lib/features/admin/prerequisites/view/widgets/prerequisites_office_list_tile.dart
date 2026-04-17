import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/viewmodel/prerequisites_viewmodel.dart';

class PrerequisitesOfficeListTile extends StatelessWidget {
  final int index;

  const PrerequisitesOfficeListTile({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PrerequisitesViewModel>();
    if (index >= vm.allOffices.length) {
      return const SizedBox.shrink();
    }

    final office = vm.allOffices[index];
    final isSelected = vm.selectedOffice?.id == office.id;
    final prereqCount = vm.prerequisitesFor(office).length;

    return ListTile(
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.primary,
      selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      title: Text(office.name, style: const TextStyle(fontSize: 14)),
      trailing: prereqCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$prereqCount',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      onTap: () => context.read<PrerequisitesViewModel>().selectOffice(office),
    );
  }
}

