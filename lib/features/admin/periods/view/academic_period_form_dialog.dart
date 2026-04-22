import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/models/academic_period.dart';

class AcademicPeriodFormDialog extends StatefulWidget {
  final AcademicPeriod? period;

  const AcademicPeriodFormDialog({super.key, this.period});

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    AcademicPeriod? period,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AcademicPeriodFormDialog(period: period),
    );
  }

  @override
  State<AcademicPeriodFormDialog> createState() =>
      _AcademicPeriodFormDialogState();
}

class _AcademicPeriodFormDialogState extends State<AcademicPeriodFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  bool get _isEditing => widget.period != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _labelController.text = widget.period!.label;
      _startDate = widget.period!.startDate;
      _endDate = widget.period!.endDate;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context, rootNavigator: true).pop({
      'label': _labelController.text.trim(),
      'start_date': _startDate,
      'end_date': _endDate,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Period' : 'Add Academic Period'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  hintText: 'e.g. AY 2024-2025 Semester 1',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Label is required'
                    : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Date range row
              Row(
                children: [
                  // Start date
                  Expanded(
                    child: _DatePickerField(
                      label: 'Start Date',
                      value: _formatDate(_startDate),
                      onTap: () => _pickDate(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '-',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // End date
                  Expanded(
                    child: _DatePickerField(
                      label: 'End Date',
                      value: _formatDate(_endDate),
                      onTap: () => _pickDate(isStart: false),
                    ),
                  ),
                ],
              ),
            ],
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
          child: Text(_isEditing ? 'Save Changes' : 'Add Period'),
        ),
      ],
    );
  }
}

// â”€â”€ Simple date picker field â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _DatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: PhosphorIcon(PhosphorIconsLight.calendar, size: 16),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: value == 'Select date'
                ? AppColors.contentSecondary(context)
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
