import 'package:flutter/material.dart';
import '../../core/models/academic_period.dart';
import '../../core/repositories/academic_period_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../widgets/academic_period_form_dialog.dart';

class AcademicPeriodsScreen extends StatefulWidget {
  const AcademicPeriodsScreen({super.key});

  @override
  State<AcademicPeriodsScreen> createState() =>
      _AcademicPeriodsScreenState();
}

class _AcademicPeriodsScreenState extends State<AcademicPeriodsScreen> {
  final _repo = AcademicPeriodRepository();

  List<AcademicPeriod> _periods   = [];
  bool                 _isLoading = true;
  bool                 _isSaving  = false;
  String?              _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── Data ──────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final periods = await _repo.getAll();
      setState(() { _periods = periods; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  // ── CRUD ──────────────────────────────────────────────────

  Future<void> _create() async {
    final result = await AcademicPeriodFormDialog.show(context);
    if (result == null) return;

    setState(() => _isSaving = true);
    try {
      await _repo.create(AcademicPeriod(
        id:        0,
        label:     result['label'],
        startDate: result['start_date'],
        endDate:   result['end_date'],
        isCurrent: false,
      ));
      _showSuccess('Academic period created.');
      _load();
    } catch (e) {
      _showError('Failed to create period: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _edit(AcademicPeriod period) async {
    final result = await AcademicPeriodFormDialog.show(
      context,
      period: period,
    );
    if (result == null) return;

    setState(() => _isSaving = true);
    try {
      await _repo.update(
        period.id,
        AcademicPeriod(
          id:        period.id,
          label:     result['label'],
          startDate: result['start_date'],
          endDate:   result['end_date'],
          isCurrent: period.isCurrent,
        ),
      );
      _showSuccess('Academic period updated.');
      _load();
    } catch (e) {
      _showError('Failed to update period: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _delete(AcademicPeriod period) async {
    // Prevent deleting the current period
    if (period.isCurrent) {
      _showError(
        'Cannot delete the current period. '
        'Set another period as current first.',
      );
      return;
    }

    final confirmed = await ConfirmDialog.show(
      context,
      title:   'Delete Period',
      message: 'Are you sure you want to delete "${period.label}"? '
               'All clearance steps for this period will also be deleted.',
    );
    if (!confirmed) return;

    setState(() => _isSaving = true);
    try {
      await _repo.delete(period.id);
      _showSuccess('Academic period deleted.');
      _load();
    } catch (e) {
      _showError('Failed to delete period: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _setCurrent(AcademicPeriod period) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title:        'Set as Current Period',
      message:      'Set "${period.label}" as the current academic period? '
                    'The previous current period will be unset.',
      confirmLabel: 'Set as Current',
      confirmColor: AppTheme.primary,
    );
    if (!confirmed) return;

    setState(() => _isSaving = true);
    try {
      await _repo.setCurrent(period.id);
      _showSuccess('"${period.label}" is now the current period.');
      _load();
    } catch (e) {
      _showError('Failed to set current period: $e');
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
                        'Academic Periods',
                        style: TextStyle(
                          fontSize:   28,
                          fontWeight: FontWeight.bold,
                          color:      AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage academic periods and set the active one.',
                        style: TextStyle(
                          color:    AppTheme.textSecondary,
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
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _create,
                  icon:  const Icon(Icons.add),
                  label: const Text('Add Period'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
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
    if (_periods.isEmpty) {
      return const Center(
        child: Text(
          'No academic periods yet.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(3),    // label
              1: FlexColumnWidth(2),    // date range
              2: FixedColumnWidth(140), // status
              3: FixedColumnWidth(180), // actions
            },
            children: [
              // Header
              TableRow(
                decoration:
                    const BoxDecoration(color: AppTheme.background),
                children: [
                  _headerCell('Label'),
                  _headerCell('Date Range'),
                  _headerCell('Status'),
                  _headerCell(''),
                ],
              ),
              // Rows
              ..._periods.map((period) => TableRow(
                // Highlight current period row
                decoration: BoxDecoration(
                  color: period.isCurrent
                      ? AppTheme.primary.withValues(alpha: 0.04)
                      : null,
                  border: Border(
                    top: BorderSide(color: AppTheme.border),
                  ),
                ),
                children: [
                  // Label
                  _dataCell(
                    Row(
                      children: [
                        if (period.isCurrent) ...[
                          const Icon(
                            Icons.radio_button_checked,
                            size:  14,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            period.label,
                            style: TextStyle(
                              fontWeight: period.isCurrent
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: period.isCurrent
                                  ? AppTheme.primary
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Date range
                  _dataCell(
                    Text(
                      period.dateRange,
                      style: const TextStyle(
                        color:    AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  // Status badge
                  _dataCell(
                    period.isCurrent
                        ? _CurrentBadge()
                        : const SizedBox.shrink(),
                  ),
                  // Actions
                  _dataCell(
                    Row(
                      children: [
                        // Set as current — only show for non-current
                        if (!period.isCurrent)
                          Tooltip(
                            message: 'Set as current',
                            child: IconButton(
                              icon: const Icon(
                                Icons.radio_button_unchecked,
                                size: 18,
                              ),
                              color:   AppTheme.primary,
                              onPressed: _isSaving
                                  ? null
                                  : () => _setCurrent(period),
                            ),
                          ),
                        IconButton(
                          icon:    const Icon(
                            Icons.edit_outlined, size: 18,
                          ),
                          color:   AppTheme.primary,
                          tooltip: 'Edit',
                          onPressed:
                              _isSaving ? null : () => _edit(period),
                        ),
                        IconButton(
                          icon:    const Icon(
                            Icons.delete_outline, size: 18,
                          ),
                          color: period.isCurrent
                              ? AppTheme.border  // greyed out
                              : AppTheme.danger,
                          tooltip: period.isCurrent
                              ? 'Cannot delete current period'
                              : 'Delete',
                          onPressed: _isSaving
                              ? null
                              : () => _delete(period),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize:   13,
        color:      AppTheme.textSecondary,
      ),
    ),
  );

  Widget _dataCell(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: child,
  );
}

// ── Current period badge ──────────────────────────────────────
class _CurrentBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.4),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.radio_button_checked,
            size:  12,
            color: AppTheme.primary,
          ),
          SizedBox(width: 4),
          Text(
            'Current',
            style: TextStyle(
              color:      AppTheme.primary,
              fontSize:   12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}