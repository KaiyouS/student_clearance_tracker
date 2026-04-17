import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/models/school.dart';
import 'package:student_clearance_tracker/core/models/program.dart';
import 'package:student_clearance_tracker/core/models/student.dart';
import 'package:student_clearance_tracker/core/repositories/school_repository.dart';
import 'package:student_clearance_tracker/core/repositories/program_repository.dart';

class StudentFormDialog extends StatefulWidget {
  final Student? student;

  const StudentFormDialog({super.key, this.student});

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    Student? student,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => StudentFormDialog(student: student),
    );
  }

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _studentNoController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final _schoolRepo = SchoolRepository();
  final _programRepo = ProgramRepository();

  List<School> _schools = [];
  List<Program> _programs = [];
  School? _selectedSchool;
  Program? _selectedProgram;
  int? _selectedYearLevel;

  bool _loadingSchools = true;
  bool _loadingPrograms = false;

  bool get _isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    _loadSchools();
    if (_isEditing) {
      final s = widget.student!;
      _studentNoController.text = s.studentNo;
      _firstNameController.text = s.profile?.firstName ?? '';
      _middleNameController.text = s.profile?.middleName ?? '';
      _lastNameController.text = s.profile?.lastName ?? '';
      _selectedYearLevel = s.yearLevel;
      // Pre-select school and program from the joined data
      if (s.program != null) {
        _selectedProgram = s.program;
        // School will be set after schools load
      }
    }
  }

  Future<void> _loadSchools() async {
    try {
      final schools = await _schoolRepo.getAll();
      setState(() {
        _schools = schools;
        _loadingSchools = false;
        // If editing, find and set the school from the program
        if (_selectedProgram != null) {
          _selectedSchool = schools.firstWhere(
            (c) => c.id == _selectedProgram!.schoolId,
            orElse: () => schools.first,
          );
          // Load programs for that school
          _loadPrograms(_selectedSchool!.id);
        }
      });
    } catch (_) {
      setState(() => _loadingSchools = false);
    }
  }

  Future<void> _loadPrograms(int schoolId) async {
    setState(() {
      _loadingPrograms = true;
      _programs = [];
    });
    try {
      final programs = await _programRepo.getBySchool(schoolId);
      setState(() {
        _programs = programs;
        _loadingPrograms = false;
        // Re-select program if editing
        if (_selectedProgram != null) {
          _selectedProgram = programs.firstWhere(
            (p) => p.id == _selectedProgram!.id,
            orElse: () => programs.first,
          );
        }
      });
    } catch (_) {
      setState(() => _loadingPrograms = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _studentNoController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context, rootNavigator: true).pop({
      'email': _emailController.text.trim(),
      'student_no': _studentNoController.text.trim(),
      'first_name': _firstNameController.text.trim(),
      'middle_name': _middleNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'program_id': _selectedProgram?.id,
      'year_level': _selectedYearLevel,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Student' : 'Add Student'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email — create only
                if (!_isEditing) ...[
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      helperText:
                          'Student will log in with their student number as password.',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Student No
                TextFormField(
                  controller: _studentNoController,
                  decoration: const InputDecoration(
                    labelText: 'Student No.',
                    hintText: 'e.g. 2021-00001',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Student number is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Name row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _middleNameController,
                        decoration: const InputDecoration(
                          labelText: 'Middle Name',
                          hintText: 'Optional',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // School dropdown
                _loadingSchools
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<School>(
                        initialValue: _selectedSchool,
                        decoration: const InputDecoration(labelText: 'School'),
                        hint: Text('Select a school'),
                        items: _schools
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: (school) {
                          setState(() {
                            _selectedSchool = school;
                            _selectedProgram = null; // reset program
                          });
                          if (school != null) {
                            _loadPrograms(school.id);
                          }
                        },
                      ),
                const SizedBox(height: 16),

                // Program dropdown — disabled until school is selected
                DropdownButtonFormField<Program>(
                  initialValue: _selectedProgram,
                  decoration: InputDecoration(
                    labelText: 'Program',
                    // Visual hint when no school selected yet
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.of(context).border,
                      ),
                    ),
                  ),
                  hint: Text(
                    _selectedSchool == null
                        ? 'Select a school first'
                        : _loadingPrograms
                        ? 'Loading...'
                        : 'Select a program',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                  items: _programs
                      .map(
                        (p) => DropdownMenuItem(value: p, child: Text(p.name)),
                      )
                      .toList(),
                  // Disabled if no school selected or still loading
                  onChanged: (_selectedSchool == null || _loadingPrograms)
                      ? null
                      : (program) => setState(() => _selectedProgram = program),
                ),
                const SizedBox(height: 16),

                // Year level
                DropdownButtonFormField<int>(
                  initialValue: _selectedYearLevel,
                  decoration: const InputDecoration(labelText: 'Year Level'),
                  hint: Text('Select year level'),
                  items: [1, 2, 3, 4, 5]
                      .map(
                        (y) =>
                            DropdownMenuItem(value: y, child: Text('Year $y')),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedYearLevel = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Save Changes' : 'Add Student'),
        ),
      ],
    );
  }
}
