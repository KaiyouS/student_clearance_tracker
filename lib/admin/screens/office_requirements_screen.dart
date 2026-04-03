import 'package:flutter/material.dart';
import '../../core/models/office.dart';
import '../../core/models/program.dart';
import '../../core/models/school.dart';
import '../../core/repositories/office_repository.dart';
import '../../core/repositories/program_repository.dart';
import '../../core/repositories/school_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';

class OfficeRequirementsScreen extends StatefulWidget {
  const OfficeRequirementsScreen({super.key});

  @override
  State<OfficeRequirementsScreen> createState() =>
      _OfficeRequirementsScreenState();
}

class _OfficeRequirementsScreenState
    extends State<OfficeRequirementsScreen> {
  final _officeRepo  = OfficeRepository();
  final _programRepo = ProgramRepository();
  final _schoolRepo  = SchoolRepository();

  List<Office>          _offices          = [];
  List<Program>         _allPrograms      = [];
  List<School>          _schools          = [];
  Map<int, List<int?>>  _requirements     = {};
  Office?               _selected;

  bool    _loadingOffices  = true;
  bool    _loadingPrograms = true;
  bool    _isSaving        = false;
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
    setState(() { _loadingOffices = true; _error = null; });
    try {
      final results = await Future.wait([
        _officeRepo.getAll(),
        _programRepo.getAll(),
        _schoolRepo.getAll(),
        _officeRepo.getAllRequirements(),
      ]);

      setState(() {
        _offices      = results[0] as List<Office>;
        _allPrograms  = results[1] as List<Program>;
        _schools      = results[2] as List<School>;
        _requirements = results[3] as Map<int, List<int?>>;
        _loadingOffices  = false;
        _loadingPrograms = false;

        if (_selected != null) {
          _selected = (_offices as List<Office>).firstWhere(
            (o) => o.id == _selected!.id,
            orElse: () => (_offices as List<Office>).first,
          );
        }
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loadingOffices = false; });
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
      SnackBar(content: Text(msg), backgroundColor: AppTheme.danger),
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
    if (reqs.isEmpty) return AppTheme.textSecondary;
    if (reqs.contains(null)) return AppTheme.statusSigned;
    return AppTheme.primary;
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
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Office Requirements',
              style: TextStyle(
                fontSize:   28,
                fontWeight: FontWeight.bold,
                color:      AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Define which programs each office applies to when '
              'generating student clearance.',
              style: TextStyle(
                color:    AppTheme.textSecondary,
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
            Text(_error!, style: const TextStyle(color: AppTheme.danger)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
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
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Text(
                    'Offices',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize:   14,
                      color:      AppTheme.textPrimary,
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppTheme.border),
                Expanded(
                  child: ListView.separated(
                    itemCount: _offices.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: AppTheme.border),
                    itemBuilder: (context, i) {
                      final office     = _offices[i];
                      final isSelected = _selected?.id == office.id;
                      final summary    = _requirementSummary(office);
                      final color      = _requirementColor(office);

                      return ListTile(
                        selected:          isSelected,
                        selectedColor:     AppTheme.primary,
                        selectedTileColor:
                            AppTheme.primary.withValues(alpha: 0.08),
                        title: Text(
                          office.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            summary,
                            style: TextStyle(
                              fontSize:   11,
                              color:      color,
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
              ? const AppCard(
                  child: Center(
                    child: Text(
                      'Select an office to manage its requirements.',
                      style: TextStyle(color: AppTheme.textSecondary),
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
                      style: const TextStyle(
                        fontSize:   18,
                        fontWeight: FontWeight.bold,
                        color:      AppTheme.textPrimary,
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
                      style: const TextStyle(
                        color:    AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isSaving)
                const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: AppTheme.border),
          const SizedBox(height: 8),

          // "Applies to all" toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _appliesToAll
                  ? AppTheme.statusSigned.withValues(alpha: 0.06)
                  : AppTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _appliesToAll
                    ? AppTheme.statusSigned.withValues(alpha: 0.3)
                    : AppTheme.border,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.people_outlined,
                  size:  20,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Applies to all students',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color:      AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Every graduating student must clear this office '
                        'regardless of program.',
                        style: TextStyle(
                          fontSize: 12,
                          color:    AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value:      _appliesToAll,
                  activeThumbColor: AppTheme.primary,
                  onChanged:   _isSaving ? null : _toggleAppliesToAll,
                ),
              ],
            ),
          ),

          // Program list — only shown when not "applies to all"
          if (!_appliesToAll) ...[
            const SizedBox(height: 16),
            const Text(
              'Specific Programs',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize:   13,
                color:      AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Only students enrolled in the selected programs '
              'will have this office on their clearance.',
              style: TextStyle(
                fontSize: 12,
                color:    AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Programs grouped by school
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _programsBySchool.entries.map((entry) {
                    final school   = entry.key;
                    final programs = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // School header
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 12, bottom: 4),
                          child: Text(
                            school.name,
                            style: const TextStyle(
                              fontSize:   12,
                              fontWeight: FontWeight.w600,
                              color:      AppTheme.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Column(
                              children: programs.asMap().entries.map((e) {
                                final idx     = e.key;
                                final program = e.value;
                                final checked =
                                    _assignedProgramIds.contains(program.id);

                                return Column(
                                  children: [
                                    if (idx > 0)
                                      const Divider(
                                        height: 1,
                                        color: AppTheme.border,
                                      ),
                                    CheckboxListTile(
                                      dense:       true,
                                      value:       checked,
                                      activeColor: AppTheme.primary,
                                      title: Text(
                                        program.name,
                                        style: const TextStyle(fontSize: 13),
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