import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/models/academic_period.dart';
import 'package:student_clearance_tracker/core/repositories/academic_period_repository.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/core/widgets/confirm_dialog.dart';
import 'package:student_clearance_tracker/admin/widgets/academic_period_form_dialog.dart';

class AcademicPeriodsScreen extends StatefulWidget {
  const AcademicPeriodsScreen({super.key});

  @override
  State<AcademicPeriodsScreen> createState() => _AcademicPeriodsScreenState();
}

class _AcademicPeriodsScreenState extends State<AcademicPeriodsScreen> {
  final _repo = AcademicPeriodRepository();

  List<AcademicPeriod> _periods = [];
  bool _isLoading = true;
  bool _isSaving = false;
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
      final periods = await _repo.getAll();
      setState(() {
        _periods = periods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── CRUD ──────────────────────────────────────────────────

  Future<void> _create() async {
    final result = await AcademicPeriodFormDialog.show(context);
    if (result == null) return;

    setState(() => _isSaving = true);
    try {
      await _repo.create(
        AcademicPeriod(
          id: 0,
          label: result['label'],
          startDate: result['start_date'],
          endDate: result['end_date'],
          isCurrent: false,
        ),
      );
      _showSuccess('Academic period created.');
      _load();
    } catch (e) {
      _showError('Failed to create period: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _edit(AcademicPeriod period) async {
    final result = await AcademicPeriodFormDialog.show(context, period: period);
    if (result == null) return;

    setState(() => _isSaving = true);
    try {
      await _repo.update(
        period.id,
        AcademicPeriod(
          id: period.id,
          label: result['label'],
          startDate: result['start_date'],
          endDate: result['end_date'],
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
      title: 'Delete Period',
      message:
          'Are you sure you want to delete "${period.label}"? '
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
      title: 'Set as Current Period',
      message:
          'Set "${period.label}" as the current academic period? '
          'The previous current period will be unset.',
      confirmLabel: 'Set as Current',
      confirmColor: AppColors.of(context).info,
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                      Text(
                        'Academic Periods',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage academic periods and set the active one.',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.65),
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
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _create,
                  icon: Icon(Icons.add),
                  label: Text('Add Period'),
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
            Text(
              _error!,
              style: TextStyle(color: AppColors.of(context).danger),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: Text('Retry')),
          ],
        ),
      );
    }
    if (_periods.isEmpty) {
      return Center(
        child: Text(
          'No academic periods yet.',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
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
              0: FlexColumnWidth(3), // label
              1: FlexColumnWidth(2), // date range
              2: FixedColumnWidth(140), // status
              3: FixedColumnWidth(180), // actions
            },
            children: [
              // Header
              TableRow(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                children: [
                  _headerCell('Label'),
                  _headerCell('Date Range'),
                  _headerCell('Status'),
                  _headerCell(''),
                ],
              ),
              // Rows
              ..._periods.map(
                (period) => TableRow(
                  // Highlight current period row
                  decoration: BoxDecoration(
                    color: period.isCurrent
                        ? AppColors.of(context).info.withValues(alpha: 0.04)
                        : null,
                    border: Border(
                      top: BorderSide(color: AppColors.of(context).border),
                    ),
                  ),
                  children: [
                    // Label
                    _dataCell(
                      Row(
                        children: [
                          if (period.isCurrent) ...[
                            Icon(
                              Icons.radio_button_checked,
                              size: 14,
                              color: AppColors.of(context).info,
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
                                    ? AppColors.of(context).info
                                    : Theme.of(context).colorScheme.onSurface,
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
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.65),
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
                                icon: Icon(
                                  Icons.radio_button_unchecked,
                                  size: 18,
                                ),
                                color: AppColors.of(context).info,
                                onPressed: _isSaving
                                    ? null
                                    : () => _setCurrent(period),
                              ),
                            ),
                          IconButton(
                            icon: Icon(Icons.edit_outlined, size: 18),
                            color: AppColors.of(context).info,
                            tooltip: 'Edit',
                            onPressed: _isSaving ? null : () => _edit(period),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 18),
                            color: period.isCurrent
                                ? AppColors.of(context)
                                      .border // greyed out
                                : AppColors.of(context).danger,
                            tooltip: period.isCurrent
                                ? 'Cannot delete current period'
                                : 'Delete',
                            onPressed: _isSaving ? null : () => _delete(period),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
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
        color: AppColors.of(context).info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.of(context).info.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.radio_button_checked,
            size: 12,
            color: AppColors.of(context).info,
          ),
          SizedBox(width: 4),
          Text(
            'Current',
            style: TextStyle(
              color: AppColors.of(context).info,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
