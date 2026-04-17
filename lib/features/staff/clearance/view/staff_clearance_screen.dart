import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/clearance_step.dart';
import 'package:student_clearance_tracker/features/staff/clearance/viewmodel/staff_provider.dart';
import 'package:student_clearance_tracker/core/repositories/academic_period_repository.dart';
import 'package:student_clearance_tracker/core/repositories/clearance_repository.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/core/widgets/status_badge.dart';
import 'package:student_clearance_tracker/main.dart';

class StaffClearanceScreen extends StatefulWidget {
  const StaffClearanceScreen({super.key});

  @override
  State<StaffClearanceScreen> createState() => _StaffClearanceScreenState();
}

class _StaffClearanceScreenState extends State<StaffClearanceScreen>
    with SingleTickerProviderStateMixin {
  final _clearanceRepo = ClearanceRepository();
  final _periodRepo = AcademicPeriodRepository();

  late TabController _tabController;

  List<ClearanceStep> _allSteps = [];
  int? _periodId;
  int? _selectedOfficeId;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  String _search = '';
  StaffProvider? _staffProvider;

  static const List<String> _tabStatuses = ['pending', 'flagged', 'signed'];
  final Map<String, List<ClearanceStep>> _filteredByStatus = {
    'pending': const <ClearanceStep>[],
    'flagged': const <ClearanceStep>[],
    'signed': const <ClearanceStep>[],
  };
  final Map<String, int> _statusCounts = {
    'pending': 0,
    'flagged': 0,
    'signed': 0,
  };

  // Track which steps have prerequisite checks cached
  final Map<int, bool> _prereqCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPeriodThenSteps();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final nextProvider = context.read<StaffProvider>();
    if (_staffProvider != nextProvider) {
      _staffProvider?.removeListener(_handleOfficeSelectionChanged);
      _staffProvider = nextProvider;
      _staffProvider?.addListener(_handleOfficeSelectionChanged);
      _handleOfficeSelectionChanged();
    }
  }

  @override
  void dispose() {
    _staffProvider?.removeListener(_handleOfficeSelectionChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _handleOfficeSelectionChanged() {
    final officeId = _staffProvider?.selectedOffice?.id;
    if (_selectedOfficeId == officeId) return;

    _selectedOfficeId = officeId;
    if (_periodId != null) {
      _loadSteps();
    }
  }

  void _recomputeFilteredBuckets() {
    final q = _search.trim().toLowerCase();
    bool matchesSearch(ClearanceStep step) {
      if (q.isEmpty) return true;
      final name = (step.studentName ?? '').toLowerCase();
      final no = (step.studentNo ?? '').toLowerCase();
      return name.contains(q) || no.contains(q);
    }

    for (final status in _tabStatuses) {
      _filteredByStatus[status] = _allSteps
          .where((s) => s.status == status)
          .where(matchesSearch)
          .toList(growable: false);
    }
  }

  void _recomputeStatusCounts() {
    for (final status in _tabStatuses) {
      _statusCounts[status] = _allSteps.where((s) => s.status == status).length;
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _search = value;
      _recomputeFilteredBuckets();
    });
  }

  // ── Data ──────────────────────────────────────────────────

  Future<void> _loadPeriodThenSteps() async {
    try {
      final period = await _periodRepo.getCurrent();
      setState(() => _periodId = period?.id);
      await _loadSteps();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSteps() async {
    final officeId = _selectedOfficeId;
    if (officeId == null || _periodId == null) {
      setState(() {
        _allSteps = const <ClearanceStep>[];
        _prereqCache.clear();
        _recomputeStatusCounts();
        _recomputeFilteredBuckets();
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final steps = await _clearanceRepo.getByOffice(officeId, _periodId!);

      // Check prerequisites for all pending steps concurrently
      final prereqFutures = <int, Future<bool>>{};
      for (final step in steps.where((s) => s.isPending)) {
        prereqFutures[step.id] = _clearanceRepo.canOfficeSign(
          studentId: step.studentId,
          officeId: officeId,
          academicPeriodId: _periodId!,
        );
      }

      final prereqResults = await Future.wait(
        prereqFutures.entries.map((e) async => MapEntry(e.key, await e.value)),
      );

      setState(() {
        _allSteps = steps;
        _prereqCache
          ..clear()
          ..addEntries(prereqResults);
        _recomputeStatusCounts();
        _recomputeFilteredBuckets();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── Filtered steps per tab ────────────────────────────────

  List<ClearanceStep> _stepsForTab(int tabIndex) {
    final status = _tabStatuses[tabIndex];
    return _filteredByStatus[status] ?? const <ClearanceStep>[];
  }

  // ── Sign action ───────────────────────────────────────────

  Future<void> _sign(ClearanceStep step) async {
    setState(() => _isSaving = true);
    try {
      await _clearanceRepo.updateStatus(
        stepId: step.id,
        status: 'signed',
        updatedBy: supabase.auth.currentUser!.id,
      );
      _showSuccess('Clearance signed for ${step.studentName ?? 'student'}.');
      await _loadSteps();
    } catch (e) {
      _showError('Failed to sign: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ── Flag action ───────────────────────────────────────────

  Future<void> _flag(ClearanceStep step) async {
    final remarkController = TextEditingController();
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Flag ${step.studentName ?? 'Student'}'),
          content: SizedBox(
            width: 400,
            child: TextField(
              controller: remarkController,
              decoration: const InputDecoration(
                labelText: 'Reason for flagging',
                hintText: 'Describe the issue...',
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.of(context).danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(true),
              child: Text('Flag'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() => _isSaving = true);

      await _clearanceRepo.updateStatus(
        stepId: step.id,
        status: 'flagged',
        updatedBy: supabase.auth.currentUser!.id,
        remarks: remarkController.text.trim().isEmpty
            ? null
            : remarkController.text.trim(),
      );
      _showSuccess('Step flagged.');
      await _loadSteps();
    } catch (e) {
      _showError('Failed to flag: $e');
    } finally {
      remarkController.dispose();
      setState(() => _isSaving = false);
    }
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.of(context).success,
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.of(context).danger,
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final officeName = context.select<StaffProvider, String>(
      (p) => p.selectedOffice?.name ?? 'No Office Selected',
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(24),
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
                        officeName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review and sign student clearance requests.',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.65),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Refresh button
                IconButton(
                  icon: Icon(Icons.refresh),
                  color: AppColors.of(context).info,
                  tooltip: 'Refresh',
                  onPressed: _isLoading ? null : _loadSteps,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            SizedBox(
              width: 320,
              child: TextField(
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Search by name or student no...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tabs
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab bar with counts
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.of(context).info,
                    unselectedLabelColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.65),
                    indicatorColor: AppColors.of(context).info,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: AppColors.of(context).border,
                    tabs: [
                      _buildTab(
                        'Pending',
                        _statusCounts['pending'] ?? 0,
                        AppColors.of(context).statusPending,
                      ),
                      _buildTab(
                        'Flagged',
                        _statusCounts['flagged'] ?? 0,
                        AppColors.of(context).statusFlagged,
                      ),
                      _buildTab(
                        'Signed',
                        _statusCounts['signed'] ?? 0,
                        AppColors.of(context).statusSigned,
                      ),
                    ],
                  ),

                  // Tab content
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 320,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                        ? _buildError()
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildStepList(0),
                              _buildStepList(1),
                              _buildStepList(2),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Tab _buildTab(String label, int count, Color color) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, style: TextStyle(color: AppColors.of(context).danger)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _loadSteps, child: Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildStepList(int tabIndex) {
    final steps = _stepsForTab(tabIndex);

    if (steps.isEmpty) {
      final labels = ['pending', 'flagged', 'signed'];
      return Center(
        child: Text(
          'No ${labels[tabIndex]} steps.',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(0),
      itemCount: steps.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: AppColors.of(context).border),
      itemBuilder: (context, i) => _buildStepRow(steps[i]),
    );
  }

  Widget _buildStepRow(ClearanceStep step) {
    final canSign = _prereqCache[step.id] ?? false;
    final isPending = step.isPending;
    final isFlagged = step.isFlagged;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Student info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.studentName ?? '—',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.studentNo ?? '—',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                // Prerequisite warning
                if (isPending && !canSign) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 12,
                        color: AppColors.of(context).warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Prerequisites not yet complete',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.of(context).warning,
                        ),
                      ),
                    ],
                  ),
                ],
                // Flag remark
                if (isFlagged && step.remarks != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.remarks!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.of(context).statusFlagged,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Status badge
          StatusBadge(status: step.status),
          const SizedBox(width: 12),

          // Actions
          if (isPending) ...[
            // Sign button
            ElevatedButton(
              onPressed: (_isSaving || !canSign) ? null : () => _sign(step),
              style: ElevatedButton.styleFrom(
                backgroundColor: canSign
                    ? AppColors.of(context).statusSigned
                    : AppColors.of(context).border,
                foregroundColor: Colors.white,
                minimumSize: const Size(72, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text('Sign', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 8),
            // Flag button
            OutlinedButton(
              onPressed: _isSaving ? null : () => _flag(step),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.of(context).danger,
                side: BorderSide(color: AppColors.of(context).danger),
                minimumSize: const Size(72, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text('Flag', style: TextStyle(fontSize: 13)),
            ),
          ] else if (isFlagged) ...[
            // Re-sign button for flagged items
            ElevatedButton(
              onPressed: _isSaving ? null : () => _sign(step),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.of(context).statusSigned,
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text('Sign', style: TextStyle(fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}
