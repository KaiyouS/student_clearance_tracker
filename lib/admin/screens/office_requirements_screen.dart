import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/models/office.dart';
import 'package:student_clearance_tracker/core/models/program.dart';
import 'package:student_clearance_tracker/core/models/school.dart';
import 'package:student_clearance_tracker/core/repositories/office_repository.dart';
import 'package:student_clearance_tracker/core/repositories/program_repository.dart';
import 'package:student_clearance_tracker/core/repositories/school_repository.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';

class OfficeRequirementsScreen extends StatefulWidget {
  const OfficeRequirementsScreen({super.key});

  @override
  State<OfficeRequirementsScreen> createState() =>
      _OfficeRequirementsScreenState();
}

class _OfficeRequirementsScreenState extends State<OfficeRequirementsScreen> {
  final _officeRepo = OfficeRepository();
  final _programRepo = ProgramRepository();
  final _schoolRepo = SchoolRepository();

  List<Office> _offices = [];
  List<Program> _allPrograms = [];
  List<School> _schools = [];
  Map<int, List<int?>> _requirements = {};
  Office? _selected;

  bool _loadingOffices = true;
  bool _loadingPrograms = true;
  bool _isSaving = false;
  String? _error;

  // Whether the selected office has "applies to all" set
  bool get _appliesToAll {
    if (_selected == null) return false;
    final reqs = _requirements[_selected!.id] ?? [];
    return reqs.contains(null);
  }

  // Program IDs assigned to selected office
  Set<int> get _assignedProgramIds {
    if (_selected == null) return {};
    final reqs = _requirements[_selected!.id] ?? [];
    return reqs.whereType<int>().toSet();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loadingOffices = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _officeRepo.getAll(),
        _programRepo.getAll(),
        _schoolRepo.getAll(),
        _officeRepo.getAllRequirements(),
      ]);

      setState(() {
        _offices = results[0] as List<Office>;
        _allPrograms = results[1] as List<Program>;
        _schools = results[2] as List<School>;
        _requirements = results[3] as Map<int, List<int?>>;
        _loadingOffices = false;
        _loadingPrograms = false;

        if (_selected != null) {
          _selected = (_offices as List<Office>).firstWhere(
            (o) => o.id == _selected!.id,
            orElse: () => (_offices as List<Office>).first,
          );
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingOffices = false;
      });
    }
  }

  // ── Actions ───────────────────────────────────────────────

  Future<void> _toggleAppliesToAll(bool value) async {
    if (_selected == null) return;
    setState(() => _isSaving = true);
    try {
      if (value) {
        // Set to applies to all — clears specific programs
        await _officeRepo.setAppliesToAll(_selected!.id);
      } else {
        // Remove the "all" entry — office now requires no one
        // until specific programs are added
        await _officeRepo.clearRequirements(_selected!.id);
      }
      await _load();
    } catch (e) {
      _showError('Failed to update: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _toggleProgram(int programId, bool add) async {
    if (_selected == null) return;
    setState(() => _isSaving = true);
    try {
      if (add) {
        await _officeRepo.addRequirement(_selected!.id, programId);
      } else {
        await _officeRepo.removeRequirement(_selected!.id, programId);
      }
      await _load();
    } catch (e) {
      _showError('Failed to update: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.of(context).danger),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  // Returns a summary label for the office list badge
  String _requirementSummary(Office office) {
    final reqs = _requirements[office.id] ?? [];
    if (reqs.isEmpty) return 'No students';
    if (reqs.contains(null)) return 'All students';
    return '${reqs.length} program${reqs.length != 1 ? 's' : ''}';
  }

  Color _requirementColor(Office office) {
    final reqs = _requirements[office.id] ?? [];
    if (reqs.isEmpty) return AppColors.of(context).neutral;
    if (reqs.contains(null)) return AppColors.of(context).statusSigned;
    return AppColors.of(context).info;
  }

  // Programs grouped by school for the right panel
  Map<School, List<Program>> get _programsBySchool {
    final map = <School, List<Program>>{};
    for (final school in _schools) {
      final programs = _allPrograms
          .where((p) => p.schoolId == school.id)
          .toList();
      if (programs.isNotEmpty) map[school] = programs;
    }
    return map;
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
            Text(
              'Office Requirements',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Define which programs each office applies to when '
              'generating student clearance.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loadingOffices || _loadingPrograms) {
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left — office list
        SizedBox(
          width: 300,
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Text(
                    'Offices',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Divider(height: 1, color: AppColors.of(context).border),
                Expanded(
                  child: ListView.separated(
                    itemCount: _offices.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: AppColors.of(context).border,
                    ),
                    itemBuilder: (context, i) {
                      final office = _offices[i];
                      final isSelected = _selected?.id == office.id;
                      final summary = _requirementSummary(office);
                      final color = _requirementColor(office);

                      return ListTile(
                        selected: isSelected,
                        selectedColor: AppColors.of(context).info,
                        selectedTileColor: AppColors.of(context).info.withValues(
                          alpha: 0.08,
                        ),
                        title: Text(
                          office.name,
                          style: TextStyle(fontSize: 13),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            summary,
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onTap: () => setState(() => _selected = office),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Right — requirements for selected office
        Expanded(
          child: _selected == null
              ? AppCard(
                  child: Center(
                    child: Text(
                      'Select an office to manage its requirements.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                )
              : _buildRequirementsPanel(_selected!),
        ),
      ],
    );
  }

  Widget _buildRequirementsPanel(Office office) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      office.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _appliesToAll
                          ? 'Required for all graduating students.'
                          : _assignedProgramIds.isEmpty
                          ? 'Not assigned to any program yet.'
                          : 'Required for ${_assignedProgramIds.length} '
                                'program${_assignedProgramIds.length != 1 ? 's' : ''}.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isSaving)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: AppColors.of(context).border),
          const SizedBox(height: 8),

          // "Applies to all" toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _appliesToAll
                  ? AppColors.of(context).statusSigned.withValues(alpha: 0.06)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _appliesToAll
                    ? AppColors.of(context).statusSigned.withValues(alpha: 0.3)
                    : AppColors.of(context).border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.people_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Applies to all students',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Every graduating student must clear this office '
                        'regardless of program.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _appliesToAll,
                  activeThumbColor: AppColors.of(context).info,
                  onChanged: _isSaving ? null : _toggleAppliesToAll,
                ),
              ],
            ),
          ),

          // Program list — only shown when not "applies to all"
          if (!_appliesToAll) ...[
            const SizedBox(height: 16),
            Text(
              'Specific Programs',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Only students enrolled in the selected programs '
              'will have this office on their clearance.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 12),

            // Programs grouped by school
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _programsBySchool.entries.map((entry) {
                    final school = entry.key;
                    final programs = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // School header
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 4),
                          child: Text(
                            school.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.of(context).border,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Column(
                              children: programs.asMap().entries.map((e) {
                                final idx = e.key;
                                final program = e.value;
                                final checked = _assignedProgramIds.contains(
                                  program.id,
                                );

                                return Column(
                                  children: [
                                    if (idx > 0)
                                      Divider(
                                        height: 1,
                                        color: AppColors.of(context).border,
                                      ),
                                    CheckboxListTile(
                                      dense: true,
                                      value: checked,
                                      activeColor: AppColors.of(context).info,
                                      title: Text(
                                        program.name,
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      onChanged: _isSaving
                                          ? null
                                          : (v) => _toggleProgram(
                                              program.id,
                                              v ?? false,
                                            ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
