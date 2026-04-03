import 'package:flutter/material.dart';
import '../../core/models/student.dart';
import '../../core/repositories/student_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../widgets/student_form_dialog.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _repo = StudentRepository();

  List<Student> _students  = [];
  List<Student> _filtered  = [];
  bool          _isLoading = true;
  bool          _isSaving  = false;
  String?       _error;
  String        _search    = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── Data ──────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final students = await _repo.getAll();
      setState(() {
        _students  = students;
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
          ? List.from(_students)
          : _students.where((s) =>
              s.fullName.toLowerCase().contains(query.toLowerCase()) ||
              s.studentNo.toLowerCase().contains(query.toLowerCase()) ||
              (s.course ?? '').toLowerCase().contains(query.toLowerCase())
            ).toList();
    });
  }

  // ── CRUD ──────────────────────────────────────────────────

  Future<void> _create() async {
    final result = await StudentFormDialog.show(context);
    if (result == null) return;

    setState(() => _isSaving = true);
    try {
      await _repo.create(
        email:      result['email'],
        studentNo:  result['student_no'],
        firstName:  result['first_name'],
        middleName: result['middle_name'].isEmpty
                      ? null
                      : result['middle_name'],
        lastName:   result['last_name'],
        course:     result['course'],
        yearLevel:  result['year_level'],
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
        id:         student.id,
        studentNo:  result['student_no'],
        firstName:  result['first_name'],
        middleName: result['middle_name'].isEmpty
                      ? null
                      : result['middle_name'],
        lastName:   result['last_name'],
        course:     result['course'],
        yearLevel:  result['year_level'],
      );
      _showSuccess('Student updated.');
      _load();
    } catch (e) {
      _showError('Failed to update student: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _delete(Student student) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title:   'Delete Student',
      message: 'Are you sure you want to delete "${student.fullName}"? '
               'Their account will be permanently removed.',
    );
    if (!confirmed) return;

    setState(() => _isSaving = true);
    try {
      await _repo.delete(student.id);
      _showSuccess('Student deleted.');
      _load();
    } catch (e) {
      _showError('Failed to delete student: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.accent),
    );
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
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Students',
                        style: TextStyle(
                          fontSize:   28,
                          fontWeight: FontWeight.bold,
                          color:      AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage graduating students and their accounts.',
                        style: TextStyle(
                          color:    AppTheme.textSecondary,
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
                      width:  20,
                      height: 20,
                      child:  CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _create,
                  icon:  const Icon(Icons.add),
                  label: const Text('Add Student'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: 320,
              child: TextField(
                onChanged: _applySearch,
                decoration: const InputDecoration(
                  hintText:   'Search by name, student no, or course...',
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
          _search.isEmpty
              ? 'No students yet.'
              : 'No students match "$_search".',
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
              1: FixedColumnWidth(140), // student no
              2: FlexColumnWidth(2),    // course
              3: FixedColumnWidth(100), // year
              4: FixedColumnWidth(120), // actions
            },
            children: [
              TableRow(
                decoration:
                    const BoxDecoration(color: AppTheme.background),
                children: [
                  _headerCell('Name'),
                  _headerCell('Student No.'),
                  _headerCell('Course'),
                  _headerCell('Year'),
                  _headerCell(''),
                ],
              ),
              ..._filtered.map((student) => TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppTheme.border),
                  ),
                ),
                children: [
                  _dataCell(
                    Text(
                      student.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color:      AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  _dataCell(
                    Text(
                      student.studentNo,
                      style: const TextStyle(
                        color:    AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _dataCell(
                    Text(
                      student.course ?? '—',
                      style: const TextStyle(
                        color:    AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _dataCell(
                    Text(
                      student.yearLevel != null
                          ? 'Year ${student.yearLevel}'
                          : '—',
                      style: const TextStyle(
                        color:    AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _dataCell(
                    Row(
                      children: [
                        IconButton(
                          icon:    const Icon(Icons.edit_outlined, size: 18),
                          color:   AppTheme.primary,
                          tooltip: 'Edit',
                          onPressed:
                              _isSaving ? null : () => _edit(student),
                        ),
                        IconButton(
                          icon:    const Icon(Icons.delete_outline, size: 18),
                          color:   AppTheme.danger,
                          tooltip: 'Delete',
                          onPressed:
                              _isSaving ? null : () => _delete(student),
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
        fontSize:   13,
        color:      AppTheme.textSecondary,
      ),
    ),
  );

  Widget _dataCell(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: child,
  );
}