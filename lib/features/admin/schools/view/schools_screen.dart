import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/models/program.dart';
import 'package:student_clearance_tracker/core/models/school.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/core/widgets/confirm_dialog.dart';
import 'package:student_clearance_tracker/features/admin/schools/viewmodel/schools_viewmodel.dart';

class SchoolsScreen extends StatelessWidget {
  const SchoolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SchoolsViewModel()..loadSchools(),
      child: const _SchoolsScreenContent(),
    );
  }
}

class _SchoolsScreenContent extends StatelessWidget {
  const _SchoolsScreenContent();

  // ── School Handlers ───────────────────────────────────────

  Future<void> _handleCreateSchool(BuildContext context) async {
    final result = await _SchoolFormDialog.show(context);
    if (result == null) return;

    if (!context.mounted) return;
    final vm = context.read<SchoolsViewModel>();
    final success = await vm.createSchool(result);
    
    if (success && context.mounted) {
      _showSuccess(context, 'School created.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _handleEditSchool(BuildContext context, School school) async {
    final result = await _SchoolFormDialog.show(context, school: school);
    if (result == null) return;

    if (!context.mounted) return;
    final vm = context.read<SchoolsViewModel>();
    final success = await vm.updateSchool(school.id, result);
    
    if (success && context.mounted) {
      _showSuccess(context, 'School updated.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _handleDeleteSchool(BuildContext context, School school) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete School',
      message: 'Are you sure you want to delete "${school.name}"? This will also delete all programs under it.',
    );
    if (!confirmed) return;

    if (!context.mounted) return;
    final vm = context.read<SchoolsViewModel>();
    final success = await vm.deleteSchool(school.id);
    
    if (success && context.mounted) {
      _showSuccess(context, 'School deleted.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  // ── Program Handlers ──────────────────────────────────────

  Future<void> _handleCreateProgram(BuildContext context) async {
    final vm = context.read<SchoolsViewModel>();
    if (vm.selectedSchool == null) return;

    final result = await _ProgramFormDialog.show(context);
    if (result == null) return;

    if (!context.mounted) return;
    final success = await vm.createProgram(result);
    
    if (success && context.mounted) {
      _showSuccess(context, 'Program created.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _handleEditProgram(BuildContext context, Program program) async {
    final result = await _ProgramFormDialog.show(context, program: program);
    if (result == null) return;

    if (!context.mounted) return;
    final vm = context.read<SchoolsViewModel>();
    final success = await vm.updateProgram(program.id, result);
    
    if (success && context.mounted) {
      _showSuccess(context, 'Program updated.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _handleDeleteProgram(BuildContext context, Program program) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Program',
      message: 'Are you sure you want to delete "${program.name}"? Students assigned to this program will have no program.',
    );
    if (!confirmed) return;

    if (!context.mounted) return;
    final vm = context.read<SchoolsViewModel>();
    final success = await vm.deleteProgram(program.id);
    
    if (success && context.mounted) {
      _showSuccess(context, 'Program deleted.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  void _showSuccess(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.of(context).success));
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.of(context).danger));
  }

  // ── UI ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SchoolsViewModel>();

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
                      Text('Schools & Programs', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text('Manage schools and the programs they offer.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 14)),
                    ],
                  ),
                ),
                if (vm.isSaving)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildBody(context, vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SchoolsViewModel vm) {
    if (vm.isLoadingSchools) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null && vm.schools.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.errorMessage!, style: TextStyle(color: AppColors.of(context).danger)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: vm.loadSchools, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel — schools list
        SizedBox(
          width: 300,
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Schools', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        color: AppColors.of(context).info,
                        tooltip: 'Add School',
                        onPressed: vm.isSaving ? null : () => _handleCreateSchool(context),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: AppColors.of(context).border),
                Expanded(
                  child: vm.schools.isEmpty
                      ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('No schools yet.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)))))
                      : ListView.separated(
                          itemCount: vm.schools.length,
                          separatorBuilder: (_, _) => Divider(height: 1, color: AppColors.of(context).border),
                          itemBuilder: (context, i) {
                            final school = vm.schools[i];
                            final isSelected = vm.selectedSchool?.id == school.id;

                            return ListTile(
                              selected: isSelected,
                              selectedColor: AppColors.of(context).info,
                              selectedTileColor: AppColors.of(context).info.withValues(alpha: 0.08),
                              title: Text(school.name, style: const TextStyle(fontSize: 13)),
                              subtitle: school.description != null
                                  ? Text(school.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11))
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 16),
                                    color: AppColors.of(context).info,
                                    tooltip: 'Edit',
                                    onPressed: vm.isSaving ? null : () => _handleEditSchool(context, school),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 16),
                                    color: AppColors.of(context).danger,
                                    tooltip: 'Delete',
                                    onPressed: vm.isSaving ? null : () => _handleDeleteSchool(context, school),
                                  ),
                                ],
                              ),
                              onTap: () => context.read<SchoolsViewModel>().selectSchool(school),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Right panel — programs for selected school
        Expanded(
          child: vm.selectedSchool == null
              ? AppCard(
                  child: Center(
                    child: Text('Select a school to manage its programs.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
                  ),
                )
              : _buildProgramsPanel(context, vm, vm.selectedSchool!),
        ),
      ],
    );
  }

  Widget _buildProgramsPanel(BuildContext context, SchoolsViewModel vm, School school) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(school.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 4),
                    Text(
                      vm.isLoadingPrograms ? 'Loading...' : '${vm.programs.length} program${vm.programs.length != 1 ? 's' : ''}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: vm.isSaving ? null : () => _handleCreateProgram(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Program'),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: AppColors.of(context).border),
          const SizedBox(height: 8),

          if (vm.isLoadingPrograms)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
          else if (vm.programs.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 32), child: Text('No programs yet. Add one above.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)))))
          else
            Expanded(
              child: ListView.separated(
                itemCount: vm.programs.length,
                separatorBuilder: (_, _) => Divider(height: 1, color: AppColors.of(context).border),
                itemBuilder: (context, i) {
                  final program = vm.programs[i];
                  return ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: AppColors.of(context).info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Icon(Icons.school_outlined, size: 16, color: AppColors.of(context).info),
                    ),
                    title: Text(program.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          color: AppColors.of(context).info,
                          tooltip: 'Edit',
                          onPressed: vm.isSaving ? null : () => _handleEditProgram(context, program),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          color: AppColors.of(context).danger,
                          tooltip: 'Delete',
                          onPressed: vm.isSaving ? null : () => _handleDeleteProgram(context, program),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── School Form Dialog ────────────────────────────────────────
class _SchoolFormDialog extends StatefulWidget {
  final School? school;
  const _SchoolFormDialog({this.school});

  static Future<Map<String, String?>?> show(BuildContext context, {School? school}) {
    return showDialog<Map<String, String?>>(
      context: context,
      builder: (_) => _SchoolFormDialog(school: school),
    );
  }

  @override
  State<_SchoolFormDialog> createState() => _SchoolFormDialogState();
}

class _SchoolFormDialogState extends State<_SchoolFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool get _isEditing => widget.school != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.school!.name;
      _descriptionController.text = widget.school!.description ?? '';
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
      'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit School' : 'Add School'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'School Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: Text(_isEditing ? 'Save Changes' : 'Add School')),
      ],
    );
  }
}

// ── Program Form Dialog ───────────────────────────────────────
class _ProgramFormDialog extends StatefulWidget {
  final Program? program;
  const _ProgramFormDialog({this.program});

  static Future<Map<String, String?>?> show(BuildContext context, {Program? program}) {
    return showDialog<Map<String, String?>>(
      context: context,
      builder: (_) => _ProgramFormDialog(program: program),
    );
  }

  @override
  State<_ProgramFormDialog> createState() => _ProgramFormDialogState();
}

class _ProgramFormDialogState extends State<_ProgramFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool get _isEditing => widget.program != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _nameController.text = widget.program!.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context, rootNavigator: true).pop({'name': _nameController.text.trim()});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Program' : 'Add Program'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Program Name'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: Text(_isEditing ? 'Save Changes' : 'Add Program')),
      ],
    );
  }
}