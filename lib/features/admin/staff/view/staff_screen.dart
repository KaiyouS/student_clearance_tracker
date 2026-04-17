import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/models/office_staff.dart';
import 'package:student_clearance_tracker/core/repositories/staff_repository.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/core/widgets/confirm_dialog.dart';
import 'package:student_clearance_tracker/core/repositories/user_profile_repository.dart';
import 'package:student_clearance_tracker/admin/widgets/account_status_menu.dart';
import 'package:student_clearance_tracker/features/admin/staff/view/staff_form_dialog.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final _repo = StaffRepository();
  final _profileRepo = UserProfileRepository();

  List<OfficeStaff> _staff = [];
  List<OfficeStaff> _filtered = [];
  bool _isLoading = true;
  bool _isSaving = false;
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
      final staff = await _repo.getAll();
      setState(() {
        _staff = staff;
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
          ? List.from(_staff)
          : _staff
                .where(
                  (s) =>
                      s.fullName.toLowerCase().contains(query.toLowerCase()) ||
                      s.employeeNo.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
    });
  }

  // ── CRUD ──────────────────────────────────────────────────

  Future<void> _create() async {
    final result = await StaffFormDialog.show(context);
    if (result == null) return;

    setState(() => _isSaving = true);
    try {
      await _repo.create(
        email: result['email'],
        employeeNo: result['employee_no'],
        firstName: result['first_name'],
        middleName: result['middle_name'].isEmpty
            ? null
            : result['middle_name'],
        lastName: result['last_name'],
        officeIds: List<int>.from(result['office_ids']),
      );
      _showSuccess(
        'Staff member created. '
        'They can log in with their email and employee number as password.',
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
        id: staff.id,
        employeeNo: result['employee_no'],
        firstName: result['first_name'],
        middleName: result['middle_name'].isEmpty
            ? null
            : result['middle_name'],
        lastName: result['last_name'],
        officeIds: List<int>.from(result['office_ids']),
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
      title: 'Delete Staff Member',
      message:
          'Are you sure you want to delete "${staff.fullName}"? '
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

  Future<void> _updateStatus(OfficeStaff staff, String newStatus) async {
    try {
      await _profileRepo.updateStatus(staff.id, newStatus);
      _showSuccess('Account status updated to $newStatus.');
      _load();
    } catch (e) {
      _showError('Failed to update status: $e');
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.of(context).success),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.of(context).danger),
    );
  }

  // ── UI ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
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
                      SizedBox(height: 4),
                      Text(
                        'Manage office staff and their office assignments.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
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
                  icon: Icon(Icons.add),
                  label: Text('Add Staff'),
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
                  hintText: 'Search by name or employee no...',
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
            Text(_error!, style: TextStyle(color: AppColors.of(context).danger)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: Text('Retry')),
          ],
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Center(
        child: Text(
          _search.isEmpty ? 'No staff yet.' : 'No staff match "$_search".',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
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
              1: FixedColumnWidth(140), // employee no
              2: FlexColumnWidth(3), // offices
              3: FixedColumnWidth(130), // status
              4: FixedColumnWidth(120), // actions
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                children: [
                  _headerCell('Name'),
                  _headerCell('Employee No.'),
                  _headerCell('Assigned Offices'),
                  _headerCell('Status'),
                  _headerCell(''),
                ],
              ),
              ..._filtered.map(
                (staff) => TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.of(context).border),
                    ),
                  ),
                  children: [
                    _dataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff.fullName,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _dataCell(
                      Text(
                        staff.employeeNo,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    _dataCell(
                      staff.offices == null || staff.offices!.isEmpty
                          ? Text(
                              'No offices assigned',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                fontSize: 13,
                              ),
                            )
                          : Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: staff.offices!
                                  .map((o) => _OfficeBadge(name: o.name))
                                  .toList(),
                            ),
                    ),
                    _dataCell(
                      staff.profile != null
                          ? AccountStatusMenu(
                              currentStatus: staff.profile!.accountStatus,
                              onStatusChanged: (s) => _updateStatus(staff, s),
                            )
                          : const SizedBox.shrink(),
                    ),
                    _dataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit_outlined, size: 18),
                            color: AppColors.of(context).info,
                            tooltip: 'Edit',
                            onPressed: _isSaving ? null : () => _edit(staff),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 18),
                            color: AppColors.of(context).danger,
                            tooltip: 'Delete',
                            onPressed: _isSaving ? null : () => _delete(staff),
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
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.of(context).info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.of(context).info.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 11,
          color: AppColors.of(context).info,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
