import 'package:flutter/material.dart';
import '../../core/models/office.dart';
import '../../core/repositories/office_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../widgets/office_form_dialog.dart';

class OfficesScreen extends StatefulWidget {
  const OfficesScreen({super.key});

  @override
  State<OfficesScreen> createState() => _OfficesScreenState();
}

class _OfficesScreenState extends State<OfficesScreen> {
  final _repo = OfficeRepository();

  List<Office> _offices = [];
  List<Office> _filtered = [];
  bool _isLoading = true;
  String? _error;
  String _search = '';

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
      setState(() {
        _offices = offices;
        _isLoading = false;
      });
      _applySearch(_search);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applySearch(String query) {
    setState(() {
      _search = query;
      _filtered = query.isEmpty
          ? List.from(_offices)
          : _offices
                .where(
                  (o) =>
                      o.name.toLowerCase().contains(query.toLowerCase()) ||
                      (o.description ?? '').toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
    });
  }

  // ── CRUD actions ──────────────────────────────────────────

  Future<void> _create() async {
    final result = await OfficeFormDialog.show(context);
    if (result == null) return;

    try {
      await _repo.create(
        Office(
          id: 0, // ignored by DB (SERIAL)
          name: result['name']!,
          description: result['description']!.isEmpty
              ? null
              : result['description'],
        ),
      );
      _load();
    } catch (e) {
      _showError('Failed to create office: $e');
    }
  }

  Future<void> _edit(Office office) async {
    final result = await OfficeFormDialog.show(context, office: office);
    if (result == null) return;

    try {
      await _repo.update(
        office.id,
        Office(
          id: office.id,
          name: result['name']!,
          description: result['description']!.isEmpty
              ? null
              : result['description'],
        ),
      );
      _load();
    } catch (e) {
      _showError('Failed to update office: $e');
    }
  }

  Future<void> _delete(Office office) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Office',
      message:
          'Are you sure you want to delete "${office.name}"? '
          'This cannot be undone.',
    );
    if (!confirmed) return;

    try {
      await _repo.delete(office.id);
      _load();
    } catch (e) {
      _showError('Failed to delete office: $e');
    }
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
            // Header row
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offices',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage offices and their clearance descriptions.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _create,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Office'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search bar
            SizedBox(
              width: 320,
              child: TextField(
                onChanged: _applySearch,
                decoration: const InputDecoration(
                  hintText: 'Search offices...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Failed to load offices.',
              style: const TextStyle(color: AppTheme.danger),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Center(
        child: Text(
          _search.isEmpty ? 'No offices yet.' : 'No offices match "$_search".',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2), // name
              1: FlexColumnWidth(3), // description
              2: FixedColumnWidth(120), // actions
            },
            children: [
              // Header row
              TableRow(
                decoration: const BoxDecoration(color: AppTheme.background),
                children: [
                  _headerCell('Office Name'),
                  _headerCell('Description'),
                  _headerCell(''),
                ],
              ),
              // Data rows
              ..._filtered.map(
                (office) => TableRow(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: AppTheme.border)),
                  ),
                  children: [
                    _dataCell(
                      Text(
                        office.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    _dataCell(
                      Text(
                        office.description ?? '—',
                        style: const TextStyle(color: AppTheme.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _dataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            color: AppTheme.primary,
                            tooltip: 'Edit',
                            onPressed: () => _edit(office),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            color: AppTheme.danger,
                            tooltip: 'Delete',
                            onPressed: () => _delete(office),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppTheme.textSecondary,
      ),
    ),
  );

  Widget _dataCell(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: child,
  );
}
