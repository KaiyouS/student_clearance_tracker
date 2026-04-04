import 'package:flutter/material.dart';
import '../../core/models/office.dart';
import '../../core/models/office_staff.dart';
import '../../core/repositories/office_repository.dart';
import '../../core/theme/app_theme.dart';

class StaffFormDialog extends StatefulWidget {
  final OfficeStaff? staff; // null = create

  const StaffFormDialog({super.key, this.staff});

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    OfficeStaff? staff,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => StaffFormDialog(staff: staff),
    );
  }

  @override
  State<StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends State<StaffFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _employeeNoController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  List<Office> _allOffices = [];
  List<int> _selectedOffices = [];
  bool _loadingOffices = true;

  bool get _isEditing => widget.staff != null;

  @override
  void initState() {
    super.initState();
    _loadOffices();
    if (_isEditing) {
      final s = widget.staff!;
      _employeeNoController.text = s.employeeNo;
      _firstNameController.text = s.firstName;
      _middleNameController.text = s.middleName ?? '';
      _lastNameController.text = s.lastName;
      _selectedOffices = s.offices?.map((o) => o.id).toList() ?? [];
    }
  }

  Future<void> _loadOffices() async {
    try {
      final offices = await OfficeRepository().getAll();
      setState(() {
        _allOffices = offices;
        _loadingOffices = false;
      });
    } catch (_) {
      setState(() => _loadingOffices = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _employeeNoController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _toggleOffice(int officeId) {
    setState(() {
      if (_selectedOffices.contains(officeId)) {
        _selectedOffices.remove(officeId);
      } else {
        _selectedOffices.add(officeId);
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context, rootNavigator: true).pop({
      'email': _emailController.text.trim(),
      'employee_no': _employeeNoController.text.trim(),
      'first_name': _firstNameController.text.trim(),
      'middle_name': _middleNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'office_ids': List<int>.from(_selectedOffices),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Staff' : 'Add Staff Member'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email — only shown on create
                if (!_isEditing) ...[
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      helperText:
                          'An invite email will be sent to this address.',
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

                // Employee No
                TextFormField(
                  controller: _employeeNoController,
                  decoration: const InputDecoration(labelText: 'Employee No.'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Employee number is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Name fields
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
                const SizedBox(height: 24),

                // Office assignments
                const Text(
                  'Assigned Offices',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select one or more offices this staff member can sign for.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),

                if (_loadingOffices)
                  const Center(child: CircularProgressIndicator())
                else
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _allOffices.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: AppTheme.border),
                        itemBuilder: (context, i) {
                          final office = _allOffices[i];
                          final selected = _selectedOffices.contains(office.id);
                          return CheckboxListTile(
                            dense: true,
                            value: selected,
                            title: Text(
                              office.name,
                              style: const TextStyle(fontSize: 13),
                            ),
                            activeColor: AppTheme.primary,
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (_) => _toggleOffice(office.id),
                          );
                        },
                      ),
                    ),
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
          child: Text(_isEditing ? 'Save Changes' : 'Add Staff Member'),
        ),
      ],
    );
  }
}
