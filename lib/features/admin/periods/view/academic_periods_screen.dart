import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/models/academic_period.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/core/widgets/confirm_dialog.dart';
import 'package:student_clearance_tracker/features/admin/periods/view/academic_period_form_dialog.dart';
import 'package:student_clearance_tracker/features/admin/periods/viewmodel/periods_viewmodel.dart';

class AcademicPeriodsScreen extends StatelessWidget {
  const AcademicPeriodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PeriodsViewModel()..loadPeriods(),
      child: const _AcademicPeriodsScreenContent(),
    );
  }
}

class _AcademicPeriodsScreenContent extends StatelessWidget {
  const _AcademicPeriodsScreenContent();

  Future<void> _handleCreate(BuildContext context) async {
    final result = await AcademicPeriodFormDialog.show(context);
    if (result == null) return;

    if (!context.mounted) return;
    final vm = context.read<PeriodsViewModel>();
    final success = await vm.createPeriod(result);

    if (success && context.mounted) {
      _showSuccess(context, 'Academic period created.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _handleEdit(BuildContext context, AcademicPeriod period) async {
    final result = await AcademicPeriodFormDialog.show(context, period: period);
    if (result == null) return;

    if (!context.mounted) return;
    final vm = context.read<PeriodsViewModel>();
    final success = await vm.updatePeriod(period.id, result, period.isCurrent);

    if (success && context.mounted) {
      _showSuccess(context, 'Academic period updated.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _handleDelete(BuildContext context, AcademicPeriod period) async {
    if (period.isCurrent) {
      _showError(context, 'Cannot delete the current period. Set another period as current first.');
      return;
    }

    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Period',
      message: 'Are you sure you want to delete "${period.label}"? All clearance steps for this period will also be deleted.',
    );
    if (!confirmed) return;

    if (!context.mounted) return;
    final vm = context.read<PeriodsViewModel>();
    final success = await vm.deletePeriod(period);

    if (success && context.mounted) {
      _showSuccess(context, 'Academic period deleted.');
    } else if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _handleSetCurrent(BuildContext context, AcademicPeriod period) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Set as Current Period',
      message: 'Set "${period.label}" as the current academic period? The previous current period will be unset.',
      confirmLabel: 'Set as Current',
      confirmColor: AppColors.of(context).info,
    );
    if (!confirmed) return;

    if (!context.mounted) return;
    final vm = context.read<PeriodsViewModel>();
    final success = await vm.setCurrentPeriod(period);

    if (success && context.mounted) {
      _showSuccess(context, '"${period.label}" is now the current period.');
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PeriodsViewModel>();

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
                      Text('Academic Periods', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text('Manage academic periods and set the active one.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 14)),
                    ],
                  ),
                ),
                if (vm.isSaving)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                ElevatedButton.icon(
                  onPressed: vm.isSaving ? null : () => _handleCreate(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Period'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildContent(context, vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PeriodsViewModel vm) {
    if (vm.isLoading && vm.periods.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null && vm.periods.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.errorMessage!, style: TextStyle(color: AppColors.of(context).danger)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: vm.loadPeriods, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (vm.periods.isEmpty) {
      return Center(
        child: Text('No academic periods yet.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FixedColumnWidth(140),
              3: FixedColumnWidth(180),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
                children: [
                  _headerCell(context, 'Label'),
                  _headerCell(context, 'Date Range'),
                  _headerCell(context, 'Status'),
                  _headerCell(context, ''),
                ],
              ),
              ...vm.periods.map(
                (period) => TableRow(
                  decoration: BoxDecoration(
                    color: period.isCurrent ? AppColors.of(context).info.withValues(alpha: 0.04) : null,
                    border: Border(top: BorderSide(color: AppColors.of(context).border)),
                  ),
                  children: [
                    _dataCell(
                      Row(
                        children: [
                          if (period.isCurrent) ...[
                            Icon(Icons.radio_button_checked, size: 14, color: AppColors.of(context).info),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              period.label,
                              style: TextStyle(
                                fontWeight: period.isCurrent ? FontWeight.w600 : FontWeight.normal,
                                color: period.isCurrent ? AppColors.of(context).info : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _dataCell(
                      Text(period.dateRange, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 13)),
                    ),
                    _dataCell(period.isCurrent ? const _CurrentBadge() : const SizedBox.shrink()),
                    _dataCell(
                      Row(
                        children: [
                          if (!period.isCurrent)
                            Tooltip(
                              message: 'Set as current',
                              child: IconButton(
                                icon: const Icon(Icons.radio_button_unchecked, size: 18),
                                color: AppColors.of(context).info,
                                onPressed: vm.isSaving ? null : () => _handleSetCurrent(context, period),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            color: AppColors.of(context).info,
                            tooltip: 'Edit',
                            onPressed: vm.isSaving ? null : () => _handleEdit(context, period),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            color: period.isCurrent ? AppColors.of(context).border : AppColors.of(context).danger,
                            tooltip: period.isCurrent ? 'Cannot delete current period' : 'Delete',
                            onPressed: vm.isSaving ? null : () => _handleDelete(context, period),
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

  Widget _headerCell(BuildContext context, String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
  );

  Widget _dataCell(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: child,
  );
}

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.of(context).info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.of(context).info.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.radio_button_checked, size: 12, color: AppColors.of(context).info),
          const SizedBox(width: 4),
          Text('Current', style: TextStyle(color: AppColors.of(context).info, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}