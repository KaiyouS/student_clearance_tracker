import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/office.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';

Future<Office?> showAddPrerequisiteDialog(
  BuildContext context, {
  required List<Office> offices,
  required Set<int> disabledIds,
  required Map<int, String> disabledReasons,
}) {
  return showDialog<Office>(
    context: context,
    builder: (_) => AddPrerequisiteDialog(
      offices: offices,
      disabledIds: disabledIds,
      disabledReasons: disabledReasons,
    ),
  );
}

class AddPrerequisiteDialog extends StatefulWidget {
  final List<Office> offices;
  final Set<int> disabledIds;
  final Map<int, String> disabledReasons;

  const AddPrerequisiteDialog({
    super.key,
    required this.offices,
    required this.disabledIds,
    required this.disabledReasons,
  });

  @override
  State<AddPrerequisiteDialog> createState() => _AddPrerequisiteDialogState();
}

class _AddPrerequisiteDialogState extends State<AddPrerequisiteDialog> {
  Office? _chosen;
  String _search = '';

  List<Office> get _filtered {
    if (_search.isEmpty) {
      return widget.offices;
    }
    return widget.offices
        .where((o) => o.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();
  }

  bool _isDisabled(Office office) => widget.disabledIds.contains(office.id);

  String? _disabledReason(Office office) => widget.disabledReasons[office.id];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Prerequisite'),
      content: SizedBox(
        width: 400,
        height: 360,
        child: Column(
          children: [
            TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'Search offices...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: Theme.of(context).dividerColor),
                  itemBuilder: (context, i) {
                    final office = _filtered[i];
                    final disabled = _isDisabled(office);
                    final reason = _disabledReason(office);

                    return ListTile(
                      title: Text(
                        office.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: disabled
                              ? AppColors.contentSecondary(context)
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: reason != null
                          ? Text(
                              reason,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            )
                          : office.description != null
                          ? Text(
                              office.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            )
                          : null,
                      selected: _chosen?.id == office.id,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.08),
                      trailing: disabled
                          ? Tooltip(
                              message: 'Cannot be added',
                              child: Icon(
                                Icons.block,
                                size: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.65),
                              ),
                            )
                          : null,
                      enabled: !disabled,
                      onTap: disabled
                          ? null
                          : () => setState(() => _chosen = office),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _chosen == null
              ? null
              : () => Navigator.of(context, rootNavigator: true).pop(_chosen),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

