import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/clearance_step.dart';
import '../../core/providers/staff_provider.dart';
import '../../core/repositories/academic_period_repository.dart';
import '../../core/repositories/clearance_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../main.dart';

class StaffClearanceScreen extends StatefulWidget {
  const StaffClearanceScreen({super.key});

  @override
  State<StaffClearanceScreen> createState() => _StaffClearanceScreenState();
}

class _StaffClearanceScreenState extends State<StaffClearanceScreen>
    with SingleTickerProviderStateMixin {
  final _clearanceRepo = ClearanceRepository();
  final _periodRepo    = AcademicPeriodRepository();

  late TabController _tabController;

  List<ClearanceStep> _allSteps   = [];
  int?                _periodId;
  bool                _isLoading  = true;
  bool                _isSaving   = false;
  String?             _error;
  String              _search     = '';

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
    // Reload when office selection changes
    final provider = context.read<StaffProvider>();
    if (provider.selectedOffice != null && !_isLoading) {
      _loadSteps();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────

  Future<void> _loadPeriodThenSteps() async {
    try {
      final period = await _periodRepo.getCurrent();
      setState(() => _periodId = period?.id);
      await _loadSteps();
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _loadSteps() async {
    final officeId = context.read<StaffProvider>().selectedOffice?.id;
    if (officeId == null || _periodId == null) {
      setState(() { _allSteps = []; _isLoading = false; });
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    try {
      final steps = await _clearanceRepo.getByOffice(
        officeId,
        _periodId!,
      );

      // Check prerequisites for all pending steps concurrently
      final prereqFutures = <int, Future<bool>>{};
      for (final step in steps.where((s) => s.isPending)) {
        prereqFutures[step.id] = _clearanceRepo.canOfficeSign(
          studentId:         step.studentId,
          officeId:          officeId,
          academicPeriodId:  _periodId!,
        );
      }

      final prereqResults = await Future.wait(
        prereqFutures.entries.map((e) async =>
            MapEntry(e.key, await e.value)),
      );

      setState(() {
        _allSteps     = steps;
        _prereqCache
          ..clear()
          ..addEntries(prereqResults);
        _isLoading    = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  // ── Filtered steps per tab ────────────────────────────────

  List<ClearanceStep> _stepsForTab(int tabIndex) {
    final status = ['pending', 'flagged', 'signed'][tabIndex];
    return _allSteps.where((s) {
      final matchStatus = s.status == status;
      final name        = (s.studentName ?? '').toLowerCase();
      final no          = (s.studentNo  ?? '').toLowerCase();
      final matchSearch = _search.isEmpty ||
          name.contains(_search.toLowerCase()) ||
          no.contains(_search.toLowerCase());
      return matchStatus && matchSearch;
    }).toList();
  }

  // ── Sign action ───────────────────────────────────────────

  Future<void> _sign(ClearanceStep step) async {
    setState(() => _isSaving = true);
    try {
      await _clearanceRepo.updateStatus(
        stepId:    step.id,
        status:    'signed',
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Flag ${step.studentName ?? 'Student'}',
        ),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: remarkController,
            decoration: const InputDecoration(
              labelText: 'Reason for flagging',
              hintText:  'Describe the issue...',
            ),
            maxLines:  3,
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
        stepId:    step.id,
        status:    'flagged',
        updatedBy: supabase.auth.currentUser!.id,
        remarks:   remarkController.text.trim().isEmpty
                     ? null
                     : remarkController.text.trim(),
      );
      _showSuccess('Step flagged.');
      await _loadSteps();
    } catch (e) {
      _showError('Failed to flag: $e');
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
    final provider     = context.watch<StaffProvider>();
    final officeName   = provider.selectedOffice?.name ?? 'No Office Selected';

    // Reload when office changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isLoading && provider.selectedOffice != null) {
        final officeChanged = _allSteps.isNotEmpty &&
            _allSteps.first.officeId != provider.selectedOffice!.id;
        if (officeChanged) _loadSteps();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
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
                        style: const TextStyle(
                          fontSize:   24,
                          fontWeight: FontWeight.bold,
                          color:      AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Review and sign student clearance requests.',
                        style: TextStyle(
                          color:    AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Refresh button
                IconButton(
                  icon:    const Icon(Icons.refresh),
                  color:   AppTheme.primary,
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
                onChanged: (v) => setState(() => _search = v),
                decoration: const InputDecoration(
                  hintText:   'Search by name or student no...',
                  prefixIcon: Icon(Icons.search),
                  isDense:    true,
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
                    controller:        _tabController,
                    labelColor:        AppTheme.primary,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicatorColor:    AppTheme.primary,
                    indicatorSize:     TabBarIndicatorSize.tab,
                    dividerColor:      AppTheme.border,
                    tabs: [
                      _buildTab('Pending', _countFor('pending'),
                          AppTheme.statusPending),
                      _buildTab('Flagged', _countFor('flagged'),
                          AppTheme.statusFlagged),
                      _buildTab('Signed',  _countFor('signed'),
                          AppTheme.statusSigned),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 6, vertical: 1,
            ),
            decoration: BoxDecoration(
              color:        color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize:   11,
                color:      color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _countFor(String status) =>
      _allSteps.where((s) => s.status == status).length;

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, style: const TextStyle(color: AppTheme.danger)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadSteps,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepList(int tabIndex) {
    final steps = _stepsForTab(tabIndex);

    if (steps.isEmpty) {
      final labels  = ['pending', 'flagged', 'signed'];
      return Center(
        child: Text(
          'No ${labels[tabIndex]} steps.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding:         const EdgeInsets.all(0),
      itemCount:       steps.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppTheme.border),
      itemBuilder: (context, i) => _buildStepRow(steps[i]),
    );
  }

  Widget _buildStepRow(ClearanceStep step) {
    final canSign     = _prereqCache[step.id] ?? false;
    final isPending   = step.isPending;
    final isFlagged   = step.isFlagged;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20, vertical: 14,
      ),
      child: Row(
        children: [
          // Student info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.studentName ?? '—',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize:   14,
                    color:      AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.studentNo ?? '—',
                  style: const TextStyle(
                    fontSize: 12,
                    color:    AppTheme.textSecondary,
                  ),
                ),
                // Prerequisite warning
                if (isPending && !canSign) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size:  12,
                        color: AppTheme.warning,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Prerequisites not yet complete',
                        style: TextStyle(
                          fontSize: 11,
                          color:    AppTheme.warning,
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
                    style: const TextStyle(
                      fontSize: 12,
                      color:    AppTheme.statusFlagged,
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
                    ? AppTheme.statusSigned
                    : AppTheme.border,
                foregroundColor: Colors.white,
                minimumSize:     const Size(72, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text(
                'Sign',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            // Flag button
            OutlinedButton(
              onPressed: _isSaving ? null : () => _flag(step),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.danger,
                side: const BorderSide(color: AppTheme.danger),
                minimumSize: const Size(72, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text(
                'Flag',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ] else if (isFlagged) ...[
            // Re-sign button for flagged items
            ElevatedButton(
              onPressed: _isSaving ? null : () => _sign(step),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusSigned,
                foregroundColor: Colors.white,
                minimumSize:     const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text(
                'Sign',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}