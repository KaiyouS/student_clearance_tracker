import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/program.dart';
import 'package:student_clearance_tracker/core/models/school.dart';

Future<Map<String, String?>?> showSchoolFormDialog(
  BuildContext context, {
  School? school,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: school?.name ?? '');
  final descriptionController = TextEditingController(
    text: school?.description ?? '',
  );
  final isEditing = school != null;

  void submit(BuildContext dialogContext) {
    if (!formKey.currentState!.validate()) return;
    Navigator.of(dialogContext, rootNavigator: true).pop({
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
    });
  }

  return showDialog<Map<String, String?>>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(isEditing ? 'Edit School' : 'Add School'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'School Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => submit(dialogContext),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => submit(dialogContext),
          child: Text(isEditing ? 'Save Changes' : 'Add School'),
        ),
      ],
    ),
  ).whenComplete(() {
    nameController.dispose();
    descriptionController.dispose();
  });
}

Future<Map<String, String?>?> showProgramFormDialog(
  BuildContext context, {
  Program? program,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: program?.name ?? '');
  final isEditing = program != null;

  void submit(BuildContext dialogContext) {
    if (!formKey.currentState!.validate()) return;
    Navigator.of(
      dialogContext,
      rootNavigator: true,
    ).pop({'name': nameController.text.trim()});
  }

  return showDialog<Map<String, String?>>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(isEditing ? 'Edit Program' : 'Add Program'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Program Name'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => submit(dialogContext),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => submit(dialogContext),
          child: Text(isEditing ? 'Save Changes' : 'Add Program'),
        ),
      ],
    ),
  ).whenComplete(nameController.dispose);
}
