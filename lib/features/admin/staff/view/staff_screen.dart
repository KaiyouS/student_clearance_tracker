import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/models/office_staff.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/core/widgets/confirm_dialog.dart';
import 'package:student_clearance_tracker/admin/widgets/account_status_menu.dart';
import 'package:student_clearance_tracker/features/admin/staff/view/staff_form_dialog.dart';
import 'package:student_clearance_tracker/features/admin/staff/viewmodel/staff_viewmodel.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StaffViewModel()..loadStaff(),
      child: const _StaffScreenContent(),
    );
  }
}

class _StaffScreenContent extends StatelessWidget {
  const _StaffScreenContent();

  Future<void> _handleCreate(BuildContext context) async {
    final result = await StaffFormDialog.show(context);
    if (result == null) return;

    if (!context.mounted) return;
    final vm = context.read<StaffViewModel>();
    
    final success = await vm.createStaff(result);
    
    if (success && context.mounted) {
      _showSuccess(context, 'Staff member created. They can log in with their email and employee number as password.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _handleEdit(BuildContext context, OfficeStaff staff) async {
    final result = await StaffFormDialog.show(context, staff: staff);
    if (result == null) return;

    if (!context.mounted) return;
    final vm = context.read<StaffViewModel>();
    
    final success = await vm.updateStaff(staff.id, result);

    if (success && context.mounted) {
      _showSuccess(context, 'Staff member updated.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _handleDelete(BuildContext context, OfficeStaff staff) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Staff Member',
      message: 'Are you sure you want to delete "${staff.fullName}"? Their account will be permanently removed.',
    );
    if (!confirmed) return;

    if (!context.mounted) return;
    final vm = context.read<StaffViewModel>();
    
    final success = await vm.deleteStaff(staff.id);
    
    if (success && context.mounted) {
      _showSuccess(context, 'Staff member deleted.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _handleUpdateStatus(BuildContext context, OfficeStaff staff, String newStatus) async {
    final vm = context.read<StaffViewModel>();
    final success = await vm.updateStatus(staff.id, newStatus);
    
    if (success && context.mounted) {
      _showSuccess(context, 'Account status updated to $newStatus.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.of(context).success),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.of(context).danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StaffViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Staff', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text('Manage office staff and their office assignments.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 14)),
                    ],
                  ),
                ),
                if (vm.isSaving)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                ElevatedButton.icon(
                  onPressed: vm.isSaving ? null : () => _handleCreate(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Staff'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 320,
              child: TextField(
                onChanged: context.read<StaffViewModel>().search,
                decoration: const InputDecoration(hintText: 'Search by name or employee no...', prefixIcon: Icon(Icons.search)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildContent(context, vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, StaffViewModel vm) {
    if (vm.isLoading && vm.filteredStaff.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null && vm.filteredStaff.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.errorMessage!, style: TextStyle(color: AppColors.of(context).danger)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: vm.loadStaff, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (vm.filteredStaff.isEmpty) {
      return Center(
        child: Text(
          vm.searchQuery.isEmpty ? 'No staff yet.' : 'No staff match "${vm.searchQuery}".',
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
              0: FlexColumnWidth(2),
              1: FixedColumnWidth(140),
              2: FlexColumnWidth(3),
              3: FixedColumnWidth(130),
              4: FixedColumnWidth(120),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
                children: [
                  _headerCell(context, 'Name'),
                  _headerCell(context, 'Employee No.'),
                  _headerCell(context, 'Assigned Offices'),
                  _headerCell(context, 'Status'),
                  _headerCell(context, ''),
                ],
              ),
              ...vm.filteredStaff.map(
                (staff) => TableRow(
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.of(context).border))),
                  children: [
                    _dataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(staff.fullName, style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      ),
                    ),
                    _dataCell(
                      Text(staff.employeeNo, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 13)),
                    ),
                    _dataCell(
                      staff.offices == null || staff.offices!.isEmpty
                          ? Text('No offices assigned', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 13))
                          : Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: staff.offices!.map((o) => _OfficeBadge(name: o.name)).toList(),
                            ),
                    ),
                    _dataCell(
                      staff.profile != null
                          ? AccountStatusMenu(
                              currentStatus: staff.profile!.accountStatus,
                              onStatusChanged: (s) => _handleUpdateStatus(context, staff, s),
                            )
                          : const SizedBox.shrink(),
                    ),
                    _dataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            color: AppColors.of(context).info,
                            tooltip: 'Edit',
                            onPressed: vm.isSaving ? null : () => _handleEdit(context, staff),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            color: AppColors.of(context).danger,
                            tooltip: 'Delete',
                            onPressed: vm.isSaving ? null : () => _handleDelete(context, staff),
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

  Widget _headerCell(BuildContext context, String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Text(
      label,
      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
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
        border: Border.all(color: AppColors.of(context).info.withValues(alpha: 0.25)),
      ),
      child: Text(
        name,
        style: TextStyle(fontSize: 11, color: AppColors.of(context).info, fontWeight: FontWeight.w500),
      ),
    );
  }
}