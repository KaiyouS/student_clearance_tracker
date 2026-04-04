import 'package:flutter/material.dart';
import '../../core/models/clearance_step.dart';
import '../../core/models/program.dart';
import '../../core/models/school.dart';
import '../../core/repositories/academic_period_repository.dart';
import '../../core/repositories/clearance_repository.dart';
import '../../core/repositories/program_repository.dart';
import '../../core/repositories/school_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/status_badge.dart';
import '../../main.dart';

class AdminClearanceScreen extends StatefulWidget {
  const AdminClearanceScreen({super.key});

  @override
  State<AdminClearanceScreen> createState() => _AdminClearanceScreenState();
}

class _AdminClearanceScreenState extends State<AdminClearanceScreen> {
  final _clearanceRepo = ClearanceRepository();
  final _periodRepo = AcademicPeriodRepository();
  final _schoolRepo = SchoolRepository();
  final _programRepo = ProgramRepository();

  // Data
  List<Map<String, dynamic>> _overview = [];
  List<Map<String, dynamic>> _filtered = [];
  List<ClearanceStep> _selectedSteps = [];
  List<School> _schools = [];
  List<Program> _programs = [];
  int? _currentPeriodId;
  String? _currentPeriodLabel;

  // Selected student
  Map<String, dynamic>? _selectedStudent;

  // Filters
  String _search = '';
  String _statusFilter = 'all';
  int? _schoolFilter;
  int? _programFilter;

  // Loading states
  bool _isLoading = true;
  bool _isLoadingSteps = false;
  bool _isSaving = false;
  bool _isGenerating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── Data ──────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _clearanceRepo.getAdminOverview(),
        _periodRepo.getCurrent(),
        _schoolRepo.getAll(),
        _programRepo.getAll(),
      ]);

      final period = results[1] as dynamic;

      setState(() {
        _overview = results[0] as List<Map<String, dynamic>>;
        _currentPeriodId = period?.id;
        _currentPeriodLabel = period?.label;
        _schools = results[2] as List<School>;
        _programs = results[3] as List<Program>;
        _isLoading = false;
      });

      _applyFilters();

      // Reload selected student's steps if one is selected
      if (_selectedStudent != null) {
        _loadSteps(_selectedStudent!['student_id']);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSteps(String studentId) async {
    if (_currentPeriodId == null) return;
    setState(() => _isLoadingSteps = true);
    try {
      final steps = await _clearanceRepo.getByStudent(
        studentId,
        _currentPeriodId!,
      );
      setState(() {
        _selectedSteps = steps;
        _isLoadingSteps = false;
      });
    } catch (e) {
      setState(() => _isLoadingSteps = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filtered = _overview.where((s) {
        // Search
        final name = (s['full_name'] ?? '').toLowerCase();
        final matchSearch =
            _search.isEmpty || name.contains(_search.toLowerCase());

        // Status
        final status = s['clearance_status'] ?? 'incomplete';
        final matchStatus = _statusFilter == 'all' || status == _statusFilter;

        return matchSearch && matchStatus;
      }).toList();
    });
  }

  // ── Generate clearance ────────────────────────────────────

  Future<void> _generateForStudent(String studentId, String name) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Generate Clearance',
      message:
          'Generate clearance steps for $name for the '
          'current period? Existing steps will not be affected.',
      confirmLabel: 'Generate',
      confirmColor: AppTheme.primary,
    );
    if (!confirmed) return;

    setState(() => _isSaving = true);
    try {
      final count = await _clearanceRepo.generateForStudent(studentId);
      _showSuccess(
        count > 0
            ? 'Created $count clearance step${count != 1 ? 's' : ''} for $name.'
            : 'All clearance steps already exist for $name.',
      );
      await _load();
    } catch (e) {
      _showError('Failed to generate clearance: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _generateForAll() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Generate Clearance for All Students',
      message:
          'This will create clearance steps for every student '
          'for the current period based on their program. '
          'Existing steps will not be affected.',
      confirmLabel: 'Generate All',
      confirmColor: AppTheme.primary,
    );
    if (!confirmed) return;

    setState(() => _isGenerating = true);
    try {
      final count = await _clearanceRepo.generateForAllStudents();
      _showSuccess(
        'Done. Created $count new clearance step${count != 1 ? 's' : ''} '
        'across all students.',
      );
      await _load();
    } catch (e) {
      _showError('Failed to generate clearance: $e');
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  // ── Override actions (admin only) ─────────────────────────

  Future<void> _overrideStep(ClearanceStep step, String newStatus) async {
    final isReset = newStatus == 'pending';
    final confirmed = await ConfirmDialog.show(
      context,
      title: isReset ? 'Reset Step' : 'Override Step',
      message: isReset
          ? 'Reset this step back to pending?'
          : 'Override "${step.officeName}" step to $newStatus?',
      confirmLabel: isReset ? 'Reset' : 'Override',
      confirmColor: isReset ? AppTheme.warning : AppTheme.primary,
    );
    if (!confirmed) return;

    setState(() => _isSaving = true);
    try {
      if (isReset) {
        await _clearanceRepo.resetStep(step.id);
      } else {
        await _clearanceRepo.updateStatus(
          stepId: step.id,
          status: newStatus,
          updatedBy: supabase.auth.currentUser!.id,
        );
      }
      await _loadSteps(_selectedStudent!['student_id']);
      await _load();
      _showSuccess('Step updated.');
    } catch (e) {
      _showError('Failed to update step: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _flagWithRemark(ClearanceStep step) async {
    final remarkController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Flag Step'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: remarkController,
            decoration: const InputDecoration(
              labelText: 'Reason for flagging',
              hintText: 'Enter a remark...',
            ),
            maxLines: 3,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(true),
            child: const Text('Flag'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);
    try {
      await _clearanceRepo.updateStatus(
        stepId: step.id,
        status: 'flagged',
        updatedBy: supabase.auth.currentUser!.id,
        remarks: remarkController.text.trim().isEmpty
            ? null
            : remarkController.text.trim(),
      );
      await _loadSteps(_selectedStudent!['student_id']);
      await _load();
      _showSuccess('Step flagged.');
    } catch (e) {
      _showError('Failed to flag step: $e');
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Clearance',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentPeriodLabel != null
                            ? 'Current period: $_currentPeriodLabel'
                            : 'No active period set.',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Generate all button
                if (_isGenerating)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: (_isGenerating || _currentPeriodId == null)
                      ? null
                      : _generateForAll,
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Generate All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Body
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
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
        // Left panel — student list
        SizedBox(
          width: 380,
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Stats row
                _buildStatsRow(),
                const Divider(height: 1, color: AppTheme.border),

                // Filters
                _buildFilters(),
                const Divider(height: 1, color: AppTheme.border),

                // Student list
                Expanded(child: _buildStudentList()),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Right panel — student detail
        Expanded(
          child: _selectedStudent == null
              ? const AppCard(
                  child: Center(
                    child: Text(
                      'Select a student to view their clearance.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              : _buildDetailPanel(),
        ),
      ],
    );
  }

  // ── Stats row ─────────────────────────────────────────────

  Widget _buildStatsRow() {
    final total = _overview.length;
    final complete = _overview
        .where((s) => s['clearance_status'] == 'complete')
        .length;
    final flagged = _overview
        .where((s) => (s['flagged_steps'] ?? 0) > 0)
        .length;
    final noClearance = _overview
        .where((s) => (s['total_steps'] ?? 0) == 0)
        .length;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _MiniStat(label: 'Total', value: total, color: AppTheme.primary),
          _MiniStat(
            label: 'Complete',
            value: complete,
            color: AppTheme.statusSigned,
          ),
          _MiniStat(
            label: 'Flagged',
            value: flagged,
            color: AppTheme.statusFlagged,
          ),
          _MiniStat(
            label: 'No Steps',
            value: noClearance,
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  // ── Filters ───────────────────────────────────────────────

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Search
          TextField(
            onChanged: (v) {
              _search = v;
              _applyFilters();
            },
            decoration: const InputDecoration(
              hintText: 'Search by name...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),

          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['all', 'complete', 'incomplete'].map((status) {
                final isSelected = _statusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(
                      status == 'all' ? 'All' : _capitalize(status),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? AppTheme.surface
                            : AppTheme.textSecondary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.background,
                    checkmarkColor: AppTheme.surface,
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : AppTheme.border,
                    ),
                    onSelected: (_) {
                      setState(() => _statusFilter = status);
                      _applyFilters();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Student list ──────────────────────────────────────────

  Widget _buildStudentList() {
    if (_filtered.isEmpty) {
      return const Center(
        child: Text(
          'No students match filters.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.separated(
      itemCount: _filtered.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppTheme.border),
      itemBuilder: (context, i) {
        final student = _filtered[i];
        final isSelected =
            _selectedStudent?['student_id'] == student['student_id'];
        final total = student['total_steps'] ?? 0;
        final signed = student['signed_steps'] ?? 0;
        final flagged = student['flagged_steps'] ?? 0;
        final status = student['clearance_status'] ?? 'incomplete';
        final isComplete = status == 'complete';
        final noSteps = total == 0;

        return InkWell(
          onTap: () {
            setState(() => _selectedStudent = student);
            _loadSteps(student['student_id']);
          },
          child: Container(
            color: isSelected ? AppTheme.primary.withValues(alpha: 0.06) : null,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student['full_name'] ?? '—',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (flagged > 0)
                            const Icon(
                              Icons.flag,
                              size: 14,
                              color: AppTheme.statusFlagged,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (noSteps)
                        const Text(
                          'No clearance generated',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        )
                      else ...[
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total > 0 ? signed / total : 0,
                            backgroundColor: AppTheme.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isComplete
                                  ? AppTheme.statusSigned
                                  : AppTheme.primary,
                            ),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$signed / $total offices signed',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Detail panel ──────────────────────────────────────────

  Widget _buildDetailPanel() {
    final student = _selectedStudent!;
    final total = student['total_steps'] ?? 0;
    final signed = student['signed_steps'] ?? 0;
    final status = student['clearance_status'] ?? 'incomplete';
    final noSteps = total == 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['full_name'] ?? '—',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      noSteps
                          ? 'No clearance steps generated yet.'
                          : '$signed of $total offices signed',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Overall status badge
              if (!noSteps) StatusBadge(status: status),

              const SizedBox(width: 8),

              // Generate clearance button
              if (noSteps || total < 20)
                TextButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () => _generateForStudent(
                          student['student_id'],
                          student['full_name'] ?? 'Student',
                        ),
                  icon: const Icon(Icons.auto_awesome, size: 14),
                  label: const Text('Generate'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: AppTheme.border),
          const SizedBox(height: 8),

          // Steps list
          if (_isLoadingSteps)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_selectedSteps.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.checklist_outlined,
                      size: 48,
                      color: AppTheme.border,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No clearance steps yet.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () => _generateForStudent(
                              student['student_id'],
                              student['full_name'] ?? 'Student',
                            ),
                      child: const Text('Generate Clearance'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _selectedSteps.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppTheme.border),
                itemBuilder: (context, i) => _buildStepRow(_selectedSteps[i]),
              ),
            ),
        ],
      ),
    );
  }

  // ── Step row ──────────────────────────────────────────────

  Widget _buildStepRow(ClearanceStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Status icon
          _StepStatusIcon(status: step.status),
          const SizedBox(width: 12),

          // Office + remarks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.officeName ?? 'Unknown Office',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                ),
                if (step.remarks != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.remarks!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.statusFlagged,
                    ),
                  ),
                ],
                if (step.updatedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Updated ${_formatDateTime(step.updatedAt!)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Status badge
          StatusBadge(status: step.status),
          const SizedBox(width: 8),

          // Override actions
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              size: 18,
              color: AppTheme.textSecondary,
            ),
            tooltip: 'Override',
            onSelected: (action) {
              if (action == 'flag') {
                _flagWithRemark(step);
              } else {
                _overrideStep(step, action);
              }
            },
            itemBuilder: (_) => [
              if (!step.isSigned)
                const PopupMenuItem(
                  value: 'signed',
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppTheme.statusSigned,
                      ),
                      SizedBox(width: 8),
                      Text('Mark as Signed'),
                    ],
                  ),
                ),
              if (!step.isFlagged)
                const PopupMenuItem(
                  value: 'flag',
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 16,
                        color: AppTheme.statusFlagged,
                      ),
                      SizedBox(width: 8),
                      Text('Flag'),
                    ],
                  ),
                ),
              if (!step.isPending)
                const PopupMenuItem(
                  value: 'pending',
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(width: 8),
                      Text('Reset to Pending'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Mini stat widget ──────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Step status icon ──────────────────────────────────────────
class _StepStatusIcon extends StatelessWidget {
  final String status;
  const _StepStatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColor(status);
    final icon = switch (status) {
      'signed' => Icons.check_circle,
      'flagged' => Icons.flag,
      _ => Icons.hourglass_empty_outlined,
    };

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}
