import 'package:flutter/material.dart';
import '../../core/models/office.dart';

class OfficeFormDialog extends StatefulWidget {
  final Office? office; // null = create, non-null = edit

  const OfficeFormDialog({super.key, this.office});

  /// Returns the submitted Office or null if cancelled
  static Future<Map<String, String>?> show(
    BuildContext context, {
    Office? office,
  }) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => OfficeFormDialog(office: office),
    );
  }

  @override
  State<OfficeFormDialog> createState() => _OfficeFormDialogState();
}

class _OfficeFormDialogState extends State<OfficeFormDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.office != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.office!.name;
      _descriptionController.text = widget.office!.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context, rootNavigator: true).pop({
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Office' : 'Add Office'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Office Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
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
          child: Text(_isEditing ? 'Save Changes' : 'Add Office'),
        ),
      ],
    );
  }
}
