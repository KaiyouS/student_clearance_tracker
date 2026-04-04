import 'package:flutter/material.dart';
import '../../core/models/program.dart';
import '../../core/models/school.dart';
import '../../core/repositories/program_repository.dart';
import '../../core/repositories/school_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/confirm_dialog.dart';

class SchoolsScreen extends StatefulWidget {
  const SchoolsScreen({super.key});

  @override
  State<SchoolsScreen> createState() => _SchoolsScreenState();
}

class _SchoolsScreenState extends State<SchoolsScreen> {
  final _schoolRepo = SchoolRepository();
  final _programRepo = ProgramRepository();

  List<School> _schools = [];
  List<Program> _programs = [];
  School? _selected;
  bool _loadingSchools = true;
  bool _loadingPrograms = false;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  // ── Data ──────────────────────────────────────────────────

  Future<void> _loadSchools() async {
    setState(() {
      _loadingSchools = true;
      _error = null;
    });
    try {
      final schools = await _schoolRepo.getAll();
      setState(() {
        _schools = schools;
        _loadingSchools = false;
        // Re-select same school if it was selected
        if (_selected != null) {
          _selected = schools.firstWhere(
            (s) => s.id == _selected!.id,
            orElse: () => schools.first,
          );
          _loadPrograms(_selected!.id);
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingSchools = false;
      });
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
      });
    } catch (e) {
      setState(() => _loadingPrograms = false);
    }
  }

  // ── School CRUD ───────────────────────────────────────────

  Future<void> _createSchool() async {
    final result = await _SchoolFormDialog.show(context);
    if (result == null) return;

    setState(() => _isSaving = true);
    try {
      await _schoolRepo.create(
        School(
          id: 0,
          name: result['name']!,
          description: result['description'],
        ),
      );
      _showSuccess('School created.');
      _loadSchools();
    } catch (e) {
      _showError('Failed to create school: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _editSchool(School school) async {
    final result = await _SchoolFormDialog.show(context, school: school);
    if (result == null) return;

    setState(() => _isSaving = true);
    try {
      await _schoolRepo.update(
        school.id,
        School(
          id: school.id,
          name: result['name']!,
          description: result['description'],
        ),
      );
      _showSuccess('School updated.');
      _loadSchools();
    } catch (e) {
      _showError('Failed to update school: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteSchool(School school) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete School',
      message:
          'Are you sure you want to delete "${school.name}"? '
          'This will also delete all programs under it.',
    );
    if (!confirmed) return;

    setState(() => _isSaving = true);
    try {
      await _schoolRepo.delete(school.id);
      if (_selected?.id == school.id) {
        setState(() {
          _selected = null;
          _programs = [];
        });
      }
      _showSuccess('School deleted.');
      _loadSchools();
    } catch (e) {
      _showError('Failed to delete school: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ── Program CRUD ──────────────────────────────────────────

  Future<void> _createProgram() async {
    if (_selected == null) return;
    final result = await _ProgramFormDialog.show(context);
    if (result == null) return;

    setState(() => _isSaving = true);
    try {
      await _programRepo.create(
        Program(id: 0, name: result['name']!, schoolId: _selected!.id),
      );
      _showSuccess('Program created.');
      _loadPrograms(_selected!.id);
    } catch (e) {
      _showError('Failed to create program: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _editProgram(Program program) async {
    final result = await _ProgramFormDialog.show(context, program: program);
    if (result == null) return;

    setState(() => _isSaving = true);
    try {
      await _programRepo.update(
        program.id,
        Program(id: program.id, name: result['name']!, schoolId: _selected!.id),
      );
      _showSuccess('Program updated.');
      _loadPrograms(_selected!.id);
    } catch (e) {
      _showError('Failed to update program: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteProgram(Program program) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Program',
      message:
          'Are you sure you want to delete "${program.name}"? '
          'Students assigned to this program will have no program.',
    );
    if (!confirmed) return;

    setState(() => _isSaving = true);
    try {
      await _programRepo.delete(program.id);
      _showSuccess('Program deleted.');
      _loadPrograms(_selected!.id);
    } catch (e) {
      _showError('Failed to delete program: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.accent),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.danger),
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
            // Header
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schools & Programs',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage schools and the programs they offer.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
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
              ],
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loadingSchools) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: AppTheme.danger)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _loadSchools, child: const Text('Retry')),
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
                // Schools header + add button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Schools',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        color: AppTheme.primary,
                        tooltip: 'Add School',
                        onPressed: _isSaving ? null : _createSchool,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppTheme.border),
                // School list
                Expanded(
                  child: _schools.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No schools yet.',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _schools.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1, color: AppTheme.border),
                          itemBuilder: (context, i) {
                            final school = _schools[i];
                            final isSelected = _selected?.id == school.id;

                            return ListTile(
                              selected: isSelected,
                              selectedColor: AppTheme.primary,
                              selectedTileColor: AppTheme.primary.withValues(
                                alpha: 0.08,
                              ),
                              title: Text(
                                school.name,
                                style: const TextStyle(fontSize: 13),
                              ),
                              subtitle: school.description != null
                                  ? Text(
                                      school.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11),
                                    )
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                    ),
                                    color: AppTheme.primary,
                                    tooltip: 'Edit',
                                    onPressed: _isSaving
                                        ? null
                                        : () => _editSchool(school),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                    ),
                                    color: AppTheme.danger,
                                    tooltip: 'Delete',
                                    onPressed: _isSaving
                                        ? null
                                        : () => _deleteSchool(school),
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(() => _selected = school);
                                _loadPrograms(school.id);
                              },
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
          child: _selected == null
              ? const AppCard(
                  child: Center(
                    child: Text(
                      'Select a school to manage its programs.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              : _buildProgramsPanel(_selected!),
        ),
      ],
    );
  }

  Widget _buildProgramsPanel(School school) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      school.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _loadingPrograms
                          ? 'Loading...'
                          : '${_programs.length} program${_programs.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _createProgram,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Program'),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: AppTheme.border),
          const SizedBox(height: 8),

          // Programs list
          if (_loadingPrograms)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_programs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No programs yet. Add one above.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _programs.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppTheme.border),
                itemBuilder: (context, i) {
                  final program = _programs[i];
                  return ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                    ),
                    title: Text(
                      program.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          color: AppTheme.primary,
                          tooltip: 'Edit',
                          onPressed: _isSaving
                              ? null
                              : () => _editProgram(program),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          color: AppTheme.danger,
                          tooltip: 'Delete',
                          onPressed: _isSaving
                              ? null
                              : () => _deleteProgram(program),
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

  static Future<Map<String, String?>?> show(
    BuildContext context, {
    School? school,
  }) {
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
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Save Changes' : 'Add School'),
        ),
      ],
    );
  }
}

// ── Program Form Dialog ───────────────────────────────────────
class _ProgramFormDialog extends StatefulWidget {
  final Program? program;
  const _ProgramFormDialog({this.program});

  static Future<Map<String, String?>?> show(
    BuildContext context, {
    Program? program,
  }) {
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
    if (_isEditing) {
      _nameController.text = widget.program!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(
      context,
      rootNavigator: true,
    ).pop({'name': _nameController.text.trim()});
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
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
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
          child: Text(_isEditing ? 'Save Changes' : 'Add Program'),
        ),
      ],
    );
  }
}
