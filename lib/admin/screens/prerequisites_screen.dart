import 'package:flutter/material.dart';
import '../../core/models/office.dart';
import '../../core/repositories/office_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/confirm_dialog.dart';

class PrerequisitesScreen extends StatefulWidget {
  const PrerequisitesScreen({super.key});

  @override
  State<PrerequisitesScreen> createState() => _PrerequisitesScreenState();
}

class _PrerequisitesScreenState extends State<PrerequisitesScreen> {
  final _repo = OfficeRepository();

  List<Office> _allOffices = [];
  Map<int, List<Office>> _prerequisites = {};
  Office? _selected;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── Data ──────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final offices = await _repo.getAll();
      final prereqs = await _repo.getAllPrerequisites();
      setState(() {
        _allOffices = offices;
        _prerequisites = prereqs;
        _isLoading = false;
        // Re-select the same office if it was selected before
        if (_selected != null) {
          _selected = offices.firstWhere(
            (o) => o.id == _selected!.id,
            orElse: () => offices.first,
          );
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Office> _prerequisitesFor(Office office) {
    return _prerequisites[office.id] ?? [];
  }

  // Offices that CAN be added as prerequisites for the selected office:
  // - Not the office itself
  // - Not already a prerequisite
  // - Would not create a circular dependency
  List<Office> _availableToAdd(Office office) {
    final current = _prerequisitesFor(office).map((o) => o.id).toSet();
    return _allOffices
        .where(
          (o) =>
              o.id != office.id &&
              !current.contains(o.id) &&
              !_wouldCreateCycle(office.id, o.id),
        )
        .toList();
  }

  // Simple cycle check: would adding requiresOfficeId as a prerequisite
  // of officeId create a cycle?
  // i.e. does officeId already appear (directly or indirectly)
  // in requiresOfficeId's prerequisites?
  bool _wouldCreateCycle(int officeId, int requiresOfficeId) {
    final visited = <int>{};
    return _reachable(requiresOfficeId, officeId, visited);
  }

  bool _reachable(int from, int target, Set<int> visited) {
    if (from == target) return true;
    if (visited.contains(from)) return false;
    visited.add(from);
    final prereqs = _prerequisites[from] ?? [];
    return prereqs.any((p) => _reachable(p.id, target, visited));
  }

  // ── CRUD ──────────────────────────────────────────────────

  Future<void> _addPrerequisite(Office office, Office requires) async {
    setState(() => _isSaving = true);
    try {
      await _repo.addPrerequisite(office.id, requires.id);
      await _load();
    } catch (e) {
      _showError('Failed to add prerequisite: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _removePrerequisite(Office office, Office requires) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Remove Prerequisite',
      message:
          'Remove "${requires.name}" as a prerequisite '
          'for "${office.name}"?',
      confirmLabel: 'Remove',
    );
    if (!confirmed) return;

    setState(() => _isSaving = true);
    try {
      await _repo.removePrerequisite(office.id, requires.id);
      await _load();
    } catch (e) {
      _showError('Failed to remove prerequisite: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _showAddDialog(Office office) async {
    // Build disabled map with reasons for ALL other offices
    final disabledIds = <int>{};
    final disabledReasons = <int, String>{};

    for (final o in _allOffices) {
      if (o.id == office.id) {
        // Can't add itself
        disabledIds.add(o.id);
        disabledReasons[o.id] = 'An office cannot require itself.';
      } else if (_prerequisitesFor(office).any((p) => p.id == o.id)) {
        // Already a prerequisite
        disabledIds.add(o.id);
        disabledReasons[o.id] = 'Already a prerequisite.';
      } else if (_wouldCreateCycle(office.id, o.id)) {
        // Would create a cycle
        disabledIds.add(o.id);
        disabledReasons[o.id] =
            'Would create a cycle — "${o.name}" already depends on '
            '"${office.name}" directly or indirectly.';
      }
    }

    final chosen = await showDialog<Office>(
      context: context,
      builder: (context) => _AddPrerequisiteDialog(
        offices: _allOffices, // ← pass ALL offices now
        disabledIds: disabledIds,
        disabledReasons: disabledReasons,
      ),
    );

    if (chosen != null) await _addPrerequisite(office, chosen);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.danger),
    );
  }

  // ── UI ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Office Prerequisites',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Define which offices must be signed before another office '
              'can sign a student\'s clearance.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Body
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: AppTheme.danger)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel — office list
        SizedBox(
          width: 280,
          child: AppCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.separated(
                itemCount: _allOffices.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppTheme.border),
                itemBuilder: (context, i) {
                  final office = _allOffices[i];
                  final isSelected = _selected?.id == office.id;
                  final prereqCount = (_prerequisites[office.id] ?? []).length;

                  return ListTile(
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    selectedTileColor: AppTheme.primary.withValues(alpha: 0.08),
                    title: Text(
                      office.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: prereqCount > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$prereqCount',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : null,
                    onTap: () => setState(() => _selected = office),
                  );
                },
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Right panel — prerequisites for selected office
        Expanded(
          child: _selected == null
              ? const AppCard(
                  child: Center(
                    child: Text(
                      'Select an office to manage its prerequisites.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              : _buildPrerequisitePanel(_selected!),
        ),
      ],
    );
  }

  Widget _buildPrerequisitePanel(Office office) {
    final prereqs = _prerequisitesFor(office);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      office.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prereqs.isEmpty
                          ? 'No prerequisites — can be signed at any time.'
                          : 'Must be preceded by ${prereqs.length} '
                                'office${prereqs.length > 1 ? 's' : ''}.',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isSaving)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => _showAddDialog(office),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Prerequisite'),
                ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: AppTheme.border),
          const SizedBox(height: 12),

          // Prerequisite list
          if (prereqs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No prerequisites set.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            ...prereqs.map(
              (req) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (req.description != null)
                              Text(
                                req.description!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 18),
                        color: AppTheme.danger,
                        tooltip: 'Remove',
                        onPressed: () => _removePrerequisite(office, req),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Explains what the arrows mean
          if (prereqs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The listed offices must sign the student\'s clearance '
                      'before "${office.name}" can sign.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                      ),
                    ),
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

// ── Add Prerequisite Dialog ──────────────────────────────────
class _AddPrerequisiteDialog extends StatefulWidget {
  final List<Office> offices;
  final Set<int> disabledIds;
  final Map<int, String> disabledReasons;

  const _AddPrerequisiteDialog({
    required this.offices,
    required this.disabledIds,
    required this.disabledReasons,
  });

  @override
  State<_AddPrerequisiteDialog> createState() => _AddPrerequisiteDialogState();
}

class _AddPrerequisiteDialogState extends State<_AddPrerequisiteDialog> {
  Office? _chosen;
  String _search = '';

  // Changed: receives all offices + the ones that are invalid + already added
  List<Office> get _filtered => _search.isEmpty
      ? widget.offices
      : widget.offices
            .where((o) => o.name.toLowerCase().contains(_search.toLowerCase()))
            .toList();

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
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppTheme.border),
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
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: reason != null
                          ? Text(
                              reason,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.danger,
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
                      selectedColor: AppTheme.primary,
                      selectedTileColor: AppTheme.primary.withValues(
                        alpha: 0.08,
                      ),
                      // Disabled tiles show a lock icon instead
                      trailing: disabled
                          ? const Tooltip(
                              message: 'Cannot be added',
                              child: Icon(
                                Icons.block,
                                size: 16,
                                color: AppTheme.textSecondary,
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
