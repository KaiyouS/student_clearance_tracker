import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/models/office.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/core/widgets/confirm_dialog.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/viewmodel/prerequisites_viewmodel.dart';

class PrerequisitesScreen extends StatelessWidget {
  const PrerequisitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PrerequisitesViewModel()..loadData(),
      child: const _PrerequisitesScreenContent(),
    );
  }
}

class _PrerequisitesScreenContent extends StatelessWidget {
  const _PrerequisitesScreenContent();

  Future<void> _handleRemove(BuildContext context, Office office, Office requires) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Remove Prerequisite',
      message: 'Remove "${requires.name}" as a prerequisite for "${office.name}"?',
      confirmLabel: 'Remove',
    );
    if (!confirmed) return;

    if (!context.mounted) return;
    final vm = context.read<PrerequisitesViewModel>();
    final success = await vm.removePrerequisite(office, requires);

    if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _showAddDialog(BuildContext context, Office office) async {
    final vm = context.read<PrerequisitesViewModel>();
    final disabledMap = vm.getDisabledOfficesMap(office);

    final chosen = await showDialog<Office>(
      context: context,
      builder: (_) => _AddPrerequisiteDialog(
        offices: vm.allOffices,
        disabledIds: disabledMap['ids'] as Set<int>,
        disabledReasons: disabledMap['reasons'] as Map<int, String>,
      ),
    );

    if (chosen != null && context.mounted) {
      final success = await vm.addPrerequisite(office, chosen);
      if (!success && context.mounted && vm.errorMessage != null) {
        _showError(context, vm.errorMessage!);
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.of(context).danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PrerequisitesViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Office Prerequisites',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              'Define which offices must be signed before another office can sign a student\'s clearance.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 14),
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildBody(context, vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PrerequisitesViewModel vm) {
    if (vm.isLoading && vm.allOffices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null && vm.allOffices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.errorMessage!, style: TextStyle(color: AppColors.of(context).danger)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: vm.loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 280,
          child: AppCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.separated(
                itemCount: vm.allOffices.length,
                separatorBuilder: (_, _) => Divider(height: 1, color: AppColors.of(context).border),
                itemBuilder: (context, i) {
                  final office = vm.allOffices[i];
                  final isSelected = vm.selectedOffice?.id == office.id;
                  final prereqCount = vm.prerequisitesFor(office).length;

                  return ListTile(
                    selected: isSelected,
                    selectedColor: AppColors.of(context).info,
                    selectedTileColor: AppColors.of(context).info.withValues(alpha: 0.08),
                    title: Text(office.name, style: const TextStyle(fontSize: 14)),
                    trailing: prereqCount > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.of(context).info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: Text('$prereqCount', style: TextStyle(fontSize: 12, color: AppColors.of(context).info, fontWeight: FontWeight.w600)),
                          )
                        : null,
                    onTap: () => context.read<PrerequisitesViewModel>().selectOffice(office),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: vm.selectedOffice == null
              ? AppCard(
                  child: Center(
                    child: Text(
                      'Select an office to manage its prerequisites.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
                    ),
                  ),
                )
              : _buildPrerequisitePanel(context, vm, vm.selectedOffice!),
        ),
      ],
    );
  }

  Widget _buildPrerequisitePanel(BuildContext context, PrerequisitesViewModel vm, Office office) {
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prereqs.isEmpty ? 'No prerequisites — can be signed at any time.' : 'Must be preceded by ${prereqs.length} office${prereqs.length > 1 ? 's' : ''}.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (vm.isSaving)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else
                ElevatedButton.icon(
                  onPressed: () => _showAddDialog(context, office),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Prerequisite'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.of(context).border),
          const SizedBox(height: 12),
          if (prereqs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No prerequisites set.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
              ),
            )
          else
            ...prereqs.map(
              (req) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.of(context).border)),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_forward, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(req.name, style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                            if (req.description != null)
                              Text(req.description!, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 18),
                        color: AppColors.of(context).danger,
                        tooltip: 'Remove',
                        onPressed: () => _handleRemove(context, office, req),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (prereqs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.of(context).info.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.of(context).info.withValues(alpha: 0.2))),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.of(context).info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('The listed offices must sign the student\'s clearance before "${office.name}" can sign.', style: TextStyle(fontSize: 12, color: AppColors.of(context).info)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddPrerequisiteDialog extends StatefulWidget {
  final List<Office> offices;
  final Set<int> disabledIds;
  final Map<int, String> disabledReasons;

  const _AddPrerequisiteDialog({required this.offices, required this.disabledIds, required this.disabledReasons});

  @override
  State<_AddPrerequisiteDialog> createState() => _AddPrerequisiteDialogState();
}

class _AddPrerequisiteDialogState extends State<_AddPrerequisiteDialog> {
  Office? _chosen;
  String _search = '';

  List<Office> get _filtered => _search.isEmpty ? widget.offices : widget.offices.where((o) => o.name.toLowerCase().contains(_search.toLowerCase())).toList();
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
            TextField(onChanged: (v) => setState(() => _search = v), decoration: const InputDecoration(hintText: 'Search offices...', prefixIcon: Icon(Icons.search))),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, _) => Divider(height: 1, color: AppColors.of(context).border),
                  itemBuilder: (context, i) {
                    final office = _filtered[i];
                    final disabled = _isDisabled(office);
                    final reason = _disabledReason(office);

                    return ListTile(
                      title: Text(office.name, style: TextStyle(fontSize: 14, color: disabled ? AppColors.of(context).neutral : Theme.of(context).colorScheme.onSurface)),
                      subtitle: reason != null ? Text(reason, style: TextStyle(fontSize: 12, color: AppColors.of(context).danger)) : office.description != null ? Text(office.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)) : null,
                      selected: _chosen?.id == office.id,
                      selectedColor: AppColors.of(context).info,
                      selectedTileColor: AppColors.of(context).info.withValues(alpha: 0.08),
                      trailing: disabled ? Tooltip(message: 'Cannot be added', child: Icon(Icons.block, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))) : null,
                      enabled: !disabled,
                      onTap: disabled ? null : () => setState(() => _chosen = office),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _chosen == null ? null : () => Navigator.of(context, rootNavigator: true).pop(_chosen), child: const Text('Add')),
      ],
    );
  }
}