import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/student.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/admin/widgets/account_status_menu.dart'; // Adjust if you moved this to core/widgets
import 'package:student_clearance_tracker/features/admin/students/view/student_form_dialog.dart';
import 'package:student_clearance_tracker/features/admin/students/viewmodel/students_viewmodel.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentsViewModel()..loadStudents(),
      child: const _StudentsScreenContent(),
    );
  }
}

class _StudentsScreenContent extends StatelessWidget {
  const _StudentsScreenContent();

  Future<void> _handleCreate(BuildContext context) async {
    final result = await StudentFormDialog.show(context);
    if (result == null) return;

    if (!context.mounted) return;
    final vm = context.read<StudentsViewModel>();
    final success = await vm.createStudent(result);

    if (success && context.mounted) {
      _showSuccess(context, 'Student created. They can log in with their email and student number as password.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _handleEdit(BuildContext context, Student student) async {
    final result = await StudentFormDialog.show(context, student: student);
    if (result == null) return;

    if (!context.mounted) return;
    final vm = context.read<StudentsViewModel>();
    final success = await vm.updateStudent(student.id, result);

    if (success && context.mounted) {
      _showSuccess(context, 'Student updated.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _handleUpdateStatus(BuildContext context, Student student, String newStatus) async {
    final vm = context.read<StudentsViewModel>();
    final success = await vm.updateStatus(student.id, newStatus);
    
    if (success && context.mounted) {
      _showSuccess(context, 'Account status updated to $newStatus.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.tertiary),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentsViewModel>();

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
                      Text('Students', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text('Manage student accounts, programs, and access.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 14)),
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
                  label: const Text('Add Student'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 320,
              child: TextField(
                onChanged: context.read<StudentsViewModel>().search,
                decoration: const InputDecoration(hintText: 'Search by name or student no...', prefixIcon: Icon(Icons.search)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildContent(context, vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, StudentsViewModel vm) {
    if (vm.isLoading && vm.filteredStudents.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null && vm.filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: vm.loadStudents, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (vm.filteredStudents.isEmpty) {
      return Center(
        child: Text(
          vm.searchQuery.isEmpty ? 'No students yet.' : 'No students match "${vm.searchQuery}".',
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
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(3),
              3: FixedColumnWidth(130),
              4: FixedColumnWidth(120),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
                children: [
                  _headerCell(context, 'Name'),
                  _headerCell(context, 'Student No.'),
                  _headerCell(context, 'Program'),
                  _headerCell(context, 'Status'),
                  _headerCell(context, ''),
                ],
              ),
              ...vm.filteredStudents.map(
                (student) => TableRow(
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
                  children: [
                    _dataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.profile?.fullName ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      ),
                    ),
                    _dataCell(
                      Text(student.studentNo, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 13)),
                    ),
                    _dataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.program?.name ?? 'No Program', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13)),
                          if (student.yearLevel != null)
                            Text('Year ${student.yearLevel}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
                        ],
                      ),
                    ),
                    _dataCell(
                      student.profile != null
                          ? AccountStatusMenu(
                              currentStatus: student.profile!.accountStatus,
                              onStatusChanged: (s) => _handleUpdateStatus(context, student, s),
                            )
                          : const SizedBox.shrink(),
                    ),
                    _dataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            color: Theme.of(context).colorScheme.primary,
                            tooltip: 'Edit',
                            onPressed: vm.isSaving ? null : () => _handleEdit(context, student),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            color: Theme.of(context).dividerColor, // Grayed out as in original
                            tooltip: 'Delete (Disabled)',
                            onPressed: null, // Disabled in your original file
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
