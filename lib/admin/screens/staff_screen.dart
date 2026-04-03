import 'package:flutter/material.dart';
import '../../core/models/office_staff.dart';
import '../../core/repositories/staff_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../widgets/staff_form_dialog.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final _repo = StaffRepository();

  List<OfficeStaff> _staff    = [];
  List<OfficeStaff> _filtered = [];
  bool              _isLoading = true;
  bool              _isSaving  = false;
  String?           _error;
  String            _search   = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── Data ──────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final staff = await _repo.getAll();
      setState(() {
        _staff     = staff;
        _isLoading = false;
      });
      _applySearch(_search);
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _applySearch(String query) {
    setState(() {
      _search   = query;
      _filtered = query.isEmpty
          ? List.from(_staff)
          : _staff.where((s) =>
              s.fullName.toLowerCase().contains(query.toLowerCase()) ||
              s.employeeNo.toLowerCase().contains(query.toLowerCase())
            ).toList();
    });
  }

  // ── CRUD ──────────────────────────────────────────────────

  Future<void> _create() async {
    final result = await StaffFormDialog.show(context);
    if (result == null) return;

    setState(() => _isSaving = true);
    try {
      await _repo.create(
        email:      result['email'],
        employeeNo: result['employee_no'],
        firstName:  result['first_name'],
        middleName: result['middle_name'].isEmpty
                      ? null
                      : result['middle_name'],
        lastName:   result['last_name'],
        officeIds:  List<int>.from(result['office_ids']),
      );
      _showSuccess(
        'Staff member created. '
        'They can log in with their email and employee number as password.'
      );
      _load();
    } catch (e) {
      _showError('Failed to create staff: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _edit(OfficeStaff staff) async {
    final result = await StaffFormDialog.show(context, staff: staff);
    if (result == null) return;

    setState(() => _isSaving = true);
    try {
      await _repo.update(
        id:         staff.id,
        employeeNo: result['employee_no'],
        firstName:  result['first_name'],
        middleName: result['middle_name'].isEmpty
                      ? null
                      : result['middle_name'],
        lastName:   result['last_name'],
        officeIds:  List<int>.from(result['office_ids']),
      );
      _showSuccess('Staff member updated.');
      _load();
    } catch (e) {
      _showError('Failed to update staff: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _delete(OfficeStaff staff) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title:   'Delete Staff Member',
      message: 'Are you sure you want to delete "${staff.fullName}"? '
               'Their account will be permanently removed.',
    );
    if (!confirmed) return;

    setState(() => _isSaving = true);
    try {
      await _repo.delete(staff.id);
      _showSuccess('Staff member deleted.');
      _load();
    } catch (e) {
      _showError('Failed to delete staff: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(message),
        backgroundColor: AppTheme.accent,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(message),
        backgroundColor: AppTheme.danger,
      ),
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
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Staff',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage office staff and their office assignments.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isSaving)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _create,
                  icon:  const Icon(Icons.add),
                  label: const Text('Add Staff'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search
            SizedBox(
              width: 320,
              child: TextField(
                onChanged: _applySearch,
                decoration: const InputDecoration(
                  hintText:   'Search by name or employee no...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 16),

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
            Text(_error!, style: const TextStyle(color: AppTheme.danger)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Center(
        child: Text(
          _search.isEmpty ? 'No staff yet.' : 'No staff match "$_search".',
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
              0: FlexColumnWidth(2),    // name
              1: FixedColumnWidth(140), // employee no
              2: FlexColumnWidth(3),    // offices
              3: FixedColumnWidth(120), // actions
            },
            children: [
              TableRow(
                decoration:
                    const BoxDecoration(color: AppTheme.background),
                children: [
                  _headerCell('Name'),
                  _headerCell('Employee No.'),
                  _headerCell('Assigned Offices'),
                  _headerCell(''),
                ],
              ),
              ..._filtered.map((staff) => TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppTheme.border),
                  ),
                ),
                children: [
                  _dataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          staff.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _dataCell(
                    Text(
                      staff.employeeNo,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _dataCell(
                    staff.offices == null || staff.offices!.isEmpty
                        ? const Text(
                            'No offices assigned',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          )
                        : Wrap(
                            spacing:   6,
                            runSpacing: 4,
                            children: staff.offices!
                                .map((o) => _OfficeBadge(name: o.name))
                                .toList(),
                          ),
                  ),
                  _dataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                          ),
                          color:   AppTheme.primary,
                          tooltip: 'Edit',
                          onPressed:
                              _isSaving ? null : () => _edit(staff),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                          ),
                          color:   AppTheme.danger,
                          tooltip: 'Delete',
                          onPressed:
                              _isSaving ? null : () => _delete(staff),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
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

// ── Small office badge chip ───────────────────────────────────
class _OfficeBadge extends StatelessWidget {
  final String name;
  const _OfficeBadge({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}