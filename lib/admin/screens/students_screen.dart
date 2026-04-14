import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import '../../core/models/student.dart';
import '../../core/repositories/student_repository.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/repositories/user_profile_repository.dart';
import '../../core/widgets/account_status_badge.dart';
import '../widgets/account_status_menu.dart';
import '../widgets/student_form_dialog.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _repo = StudentRepository();
  final _profileRepo = UserProfileRepository();

  List<Student> _students = [];
  List<Student> _filtered = [];
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
      final students = await _repo.getAll();
      setState(() {
        _students = students;
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
          ? List.from(_students)
          : _students
                .where(
                  (s) =>
                      s.fullName.toLowerCase().contains(query.toLowerCase()) ||
                      s.studentNo.toLowerCase().contains(query.toLowerCase()) ||
                      s.programName.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      s.schoolName.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
    });
  }

  // ── CRUD ──────────────────────────────────────────────────

  Future<void> _create() async {
    final result = await StudentFormDialog.show(context);
    if (result == null) return;

    setState(() => _isSaving = true);
    try {
      await _repo.create(
        email: result['email'],
        studentNo: result['student_no'],
        firstName: result['first_name'],
        middleName: result['middle_name'].isEmpty
            ? null
            : result['middle_name'],
        lastName: result['last_name'],
        programId: result['program_id'],
        yearLevel: result['year_level'],
      );
      _showSuccess(
        'Student created. '
        'They can log in with their email and student number as password.',
      );
      _load();
    } catch (e) {
      _showError('Failed to create student: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _edit(Student student) async {
    final result = await StudentFormDialog.show(context, student: student);
    if (result == null) return;

    setState(() => _isSaving = true);
    try {
      await _repo.update(
        id: student.id,
        studentNo: result['student_no'],
        firstName: result['first_name'],
        middleName: result['middle_name'].isEmpty
            ? null
            : result['middle_name'],
        lastName: result['last_name'],
        programId: result['program_id'],
        yearLevel: result['year_level'],
      );
      _showSuccess('Student updated.');
      _load();
    } catch (e) {
      _showError('Failed to update student: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _updateStatus(Student student, String newStatus) async {
    try {
      await _profileRepo.updateStatus(student.id, newStatus);
      _showSuccess('Account status updated to $newStatus.');
      _load();
    } catch (e) {
      _showError('Failed to update status: $e');
    }
  }

  // TODO: decide if we should implement delete
  // Future<void> _delete(Student student) async {
  //   final confirmed = await ConfirmDialog.show(
  //     context,
  //     title:   'Delete Student',
  //     message: 'Are you sure you want to delete "${student.fullName}"? '
  //              'Their account will be permanently removed.',
  //   );
  //   if (!confirmed) return;

  //   setState(() => _isSaving = true);
  //   try {
  //     await _repo.delete(student.id);
  //     _showSuccess('Student deleted.');
  //     _load();
  //   } catch (e) {
  //     _showError('Failed to delete student: $e');
  //   } finally {
  //     setState(() => _isSaving = false);
  //   }
  // }

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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Students',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage graduating students and their accounts.',
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
                  label: Text('Add Student'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: 320,
              child: TextField(
                onChanged: _applySearch,
                decoration: const InputDecoration(
                  hintText: 'Search by name, student no, or course...',
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
          _search.isEmpty
              ? 'No students yet.'
              : 'No students match "$_search".',
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
              1: FixedColumnWidth(140), // student no
              2: FlexColumnWidth(2), // program
              3: FlexColumnWidth(2), // school
              4: FixedColumnWidth(100), // year
              5: FixedColumnWidth(130), // status
              6: FixedColumnWidth(120), // actions
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                children: [
                  _headerCell('Name'),
                  _headerCell('Student No.'),
                  _headerCell('Program'),
                  _headerCell('School'),
                  _headerCell('Year'),
                  _headerCell('Status'),
                  _headerCell(''),
                ],
              ),
              ..._filtered.map(
                (student) => TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.of(context).border),
                    ),
                  ),
                  children: [
                    _dataCell(
                      Text(
                        student.fullName,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    _dataCell(
                      Text(
                        student.studentNo,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    _dataCell(
                      Text(
                        student.programName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    _dataCell(
                      Text(
                        student.schoolName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    _dataCell(
                      Text(
                        student.yearLevel != null
                            ? 'Year ${student.yearLevel}'
                            : '—',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    _dataCell(
                      student.profile != null
                          ? AccountStatusMenu(
                              currentStatus: student.profile!.accountStatus,
                              onStatusChanged: (s) => _updateStatus(student, s),
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
                            onPressed: _isSaving ? null : () => _edit(student),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 18),
                            color: AppColors.of(context).danger,
                            tooltip: 'Delete',
                            onPressed: null,
                            // _isSaving ? null : () => _delete(student),
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
