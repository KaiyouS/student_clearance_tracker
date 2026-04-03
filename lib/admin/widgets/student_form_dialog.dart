import 'package:flutter/material.dart';
import '../../core/models/student.dart';

// Common courses — extend as needed
const List<String> kCourses = [
  'BS Computer Science',
  'BS Information Technology',
  'BS Civil Engineering',
  'BS Accountancy',
  'BS Business Administration',
  'BS Nursing',
  'BS Biology',
  'BS Psychology',
  'AB Communication',
  'AB Political Science',
];

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
  final _formKey             = GlobalKey<FormState>();
  final _emailController     = TextEditingController();
  final _studentNoController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController= TextEditingController();
  final _lastNameController  = TextEditingController();

  String? _selectedCourse;
  int?    _selectedYearLevel;

  bool get _isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final s = widget.student!;
      _studentNoController.text  = s.studentNo;
      _firstNameController.text  = s.profile?.firstName ?? '';
      _middleNameController.text = s.profile?.middleName ?? '';
      _lastNameController.text   = s.profile?.lastName ?? '';
      _selectedCourse     = s.course;
      _selectedYearLevel  = s.yearLevel;
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
    Navigator.pop(context, {
      'email':       _emailController.text.trim(),
      'student_no':  _studentNoController.text.trim(),
      'first_name':  _firstNameController.text.trim(),
      'middle_name': _middleNameController.text.trim(),
      'last_name':   _lastNameController.text.trim(),
      'course':      _selectedCourse,
      'year_level':  _selectedYearLevel,
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
                    controller:   _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration:   const InputDecoration(
                      labelText:  'Email',
                      helperText:
                          'Student will log in with student number as password.',
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
                  controller:  _studentNoController,
                  decoration:  const InputDecoration(
                    labelText: 'Student No.',
                    hintText:  'e.g. 2021-00001',
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
                        decoration:
                            const InputDecoration(labelText: 'First Name'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _middleNameController,
                        decoration: const InputDecoration(
                          labelText: 'Middle Name',
                          hintText:  'Optional',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration:
                            const InputDecoration(labelText: 'Last Name'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Course dropdown
                DropdownButtonFormField<String>(
                  initialValue:       _selectedCourse,
                  decoration:  const InputDecoration(labelText: 'Course'),
                  hint: const Text('Select a course'),
                  items: kCourses
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCourse = v),
                ),
                const SizedBox(height: 16),

                // Year level dropdown
                DropdownButtonFormField<int>(
                  initialValue:      _selectedYearLevel,
                  decoration: const InputDecoration(labelText: 'Year Level'),
                  hint: const Text('Select year level'),
                  items: [1, 2, 3, 4, 5]
                      .map((y) => DropdownMenuItem(
                            value: y,
                            child: Text('Year $y'),
                          ))
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Save Changes' : 'Add Student'),
        ),
      ],
    );
  }
}