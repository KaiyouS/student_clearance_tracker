import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/clearance_step.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/core/widgets/confirm_dialog.dart';
import 'package:student_clearance_tracker/core/widgets/status_badge.dart';
import 'package:student_clearance_tracker/features/admin/clearance/viewmodel/admin_clearance_viewmodel.dart';
import 'package:student_clearance_tracker/main.dart';

class AdminClearanceScreen extends StatelessWidget {
  const AdminClearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminClearanceViewModel()..load(),
      child: const _AdminClearanceScreenContent(),
    );
  }
}

class _AdminClearanceScreenContent extends StatelessWidget {
  const _AdminClearanceScreenContent();

  Future<void> _handleGenerateForStudent(
    BuildContext context,
    AdminClearanceViewModel vm,
    String studentId,
    String name,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Generate Clearance',
      message:
          'Generate clearance steps for $name for the '
          'current period? Existing steps will not be affected.',
      confirmLabel: 'Generate',
      confirmColor: AppColors.of(context).info,
    );
    if (!confirmed) return;

    final success = await vm.generateForStudent(studentId, name);
    if (!context.mounted) return;
    _showActionResult(context, vm, success);
  }

  Future<void> _handleGenerateForAll(
    BuildContext context,
    AdminClearanceViewModel vm,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Generate Clearance for All Students',
      message:
          'This will create clearance steps for every student '
          'for the current period based on their program. '
          'Existing steps will not be affected.',
      confirmLabel: 'Generate All',
      confirmColor: AppColors.of(context).info,
    );
    if (!confirmed) return;

    final success = await vm.generateForAll();
    if (!context.mounted) return;
    _showActionResult(context, vm, success);
  }

  Future<void> _handleOverrideStep(
    BuildContext context,
    AdminClearanceViewModel vm,
    ClearanceStep step,
    String newStatus,
  ) async {
    final isReset = newStatus == 'pending';
    final confirmed = await ConfirmDialog.show(
      context,
      title: isReset ? 'Reset Step' : 'Override Step',
      message: isReset
          ? 'Reset this step back to pending?'
          : 'Override "${step.officeName}" step to $newStatus?',
      confirmLabel: isReset ? 'Reset' : 'Override',
      confirmColor: isReset
          ? AppColors.of(context).warning
          : AppColors.of(context).info,
    );
    if (!confirmed) return;

    final success = await vm.overrideStep(
      step,
      newStatus,
      supabase.auth.currentUser!.id,
    );
    if (!context.mounted) return;
    _showActionResult(context, vm, success);
  }

  Future<void> _handleFlagStep(
    BuildContext context,
    AdminClearanceViewModel vm,
    ClearanceStep step,
  ) async {
    final remarkController = TextEditingController();
    try {
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
                backgroundColor: AppColors.of(context).danger,
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

      final remarks = remarkController.text.trim();
      final success = await vm.flagWithRemark(
        step,
        supabase.auth.currentUser!.id,
        remarks.isEmpty ? null : remarks,
      );

      if (!context.mounted) return;
      _showActionResult(context, vm, success);
    } finally {
      remarkController.dispose();
    }
  }

  void _showActionResult(
    BuildContext context,
    AdminClearanceViewModel vm,
    bool success,
  ) {
    if (success && vm.actionSuccess != null) {
      _showSuccess(context, vm.actionSuccess!);
    } else if (!success && vm.actionError != null) {
      _showError(context, vm.actionError!);
    }
  }

  void _showSuccess(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.of(context).success,
      ),
    );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.of(context).danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminClearanceViewModel>();

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
                      Text(
                        'Clearance',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vm.currentPeriodLabel != null
                            ? 'Current period: ${vm.currentPeriodLabel}'
                            : 'No active period set.',
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
                if (vm.isGenerating)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: (vm.isGenerating || vm.currentPeriodId == null)
                      ? null
                      : () => _handleGenerateForAll(context, vm),
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Generate All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.of(context).success,
                  ),
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

  Widget _buildBody(BuildContext context, AdminClearanceViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              vm.error!,
              style: TextStyle(color: AppColors.of(context).danger),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: vm.load, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 380,
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildStatsRow(context, vm),
                Divider(height: 1, color: AppColors.of(context).border),
                _buildFilters(context, vm),
                Divider(height: 1, color: AppColors.of(context).border),
                Expanded(child: _buildStudentList(context, vm)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: vm.selectedStudent == null
              ? AppCard(
                  child: Center(
                    child: Text(
                      'Select a student to view their clearance.',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                )
              : _buildDetailPanel(context, vm),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, AdminClearanceViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _MiniStat(
            label: 'Total',
            value: vm.overviewStats.total,
            color: AppColors.of(context).info,
          ),
          _MiniStat(
            label: 'Complete',
            value: vm.overviewStats.complete,
            color: AppColors.of(context).statusSigned,
          ),
          _MiniStat(
            label: 'Flagged',
            value: vm.overviewStats.flagged,
            color: AppColors.of(context).statusFlagged,
          ),
          _MiniStat(
            label: 'No Steps',
            value: vm.overviewStats.noClearance,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, AdminClearanceViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            onChanged: vm.updateSearch,
            decoration: const InputDecoration(
              hintText: 'Search by name...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['all', 'complete', 'incomplete'].map((status) {
                final isSelected = vm.statusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(
                      status == 'all' ? 'All' : _capitalize(status),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Theme.of(context).colorScheme.surface
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.of(context).info,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    checkmarkColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.of(context).info
                          : AppColors.of(context).border,
                    ),
                    onSelected: (_) => vm.updateStatusFilter(status),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(BuildContext context, AdminClearanceViewModel vm) {
    if (vm.filtered.isEmpty) {
      return Center(
        child: Text(
          'No students match filters.',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: vm.filtered.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: AppColors.of(context).border),
      itemBuilder: (context, i) {
        final student = vm.filtered[i];
        final isSelected =
            vm.selectedStudent?['student_id'] == student['student_id'];
        final total = student['total_steps'] ?? 0;
        final signed = student['signed_steps'] ?? 0;
        final flagged = student['flagged_steps'] ?? 0;
        final status = student['clearance_status'] ?? 'incomplete';
        final isComplete = status == 'complete';
        final noSteps = total == 0;

        return InkWell(
          onTap: () => vm.selectStudent(student),
          child: Container(
            color: isSelected
                ? AppColors.of(context).info.withValues(alpha: 0.06)
                : null,
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
                              student['full_name'] ?? '-',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: isSelected
                                    ? AppColors.of(context).info
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (flagged > 0)
                            Icon(
                              Icons.flag,
                              size: 14,
                              color: AppColors.of(context).statusFlagged,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (noSteps)
                        Text(
                          'No clearance generated',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
                        )
                      else ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total > 0 ? signed / total : 0,
                            backgroundColor: AppColors.of(context).border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isComplete
                                  ? AppColors.of(context).statusSigned
                                  : AppColors.of(context).info,
                            ),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$signed / $total offices signed',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.65),
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

  Widget _buildDetailPanel(BuildContext context, AdminClearanceViewModel vm) {
    final student = vm.selectedStudent!;
    final total = student['total_steps'] ?? 0;
    final signed = student['signed_steps'] ?? 0;
    final status = student['clearance_status'] ?? 'incomplete';
    final noSteps = total == 0;

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
                    Text(
                      student['full_name'] ?? '-',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      noSteps
                          ? 'No clearance steps generated yet.'
                          : '$signed of $total offices signed',
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
              if (!noSteps) StatusBadge(status: status),
              const SizedBox(width: 8),
              if (noSteps || total < 20)
                TextButton.icon(
                  onPressed: vm.isSaving
                      ? null
                      : () => _handleGenerateForStudent(
                          context,
                          vm,
                          student['student_id'],
                          student['full_name'] ?? 'Student',
                        ),
                  icon: const Icon(Icons.auto_awesome, size: 14),
                  label: const Text('Generate'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.of(context).info,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.of(context).border),
          const SizedBox(height: 8),
          if (vm.isLoadingSteps)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (vm.selectedSteps.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.checklist_outlined,
                      size: 48,
                      color: AppColors.of(context).border,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No clearance steps yet.',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: vm.isSaving
                          ? null
                          : () => _handleGenerateForStudent(
                              context,
                              vm,
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
                itemCount: vm.selectedSteps.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: AppColors.of(context).border),
                itemBuilder: (context, i) =>
                    _buildStepRow(context, vm, vm.selectedSteps[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepRow(
    BuildContext context,
    AdminClearanceViewModel vm,
    ClearanceStep step,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _StepStatusIcon(status: step.status),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.officeName ?? 'Unknown Office',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                  ),
                ),
                if (step.remarks != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.remarks!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.of(context).statusFlagged,
                    ),
                  ),
                ],
                if (step.updatedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Updated ${_formatDateTime(step.updatedAt!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ],
            ),
          ),
          StatusBadge(status: step.status),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              size: 18,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.65),
            ),
            tooltip: 'Override',
            onSelected: (action) {
              if (action == 'flag') {
                _handleFlagStep(context, vm, step);
              } else {
                _handleOverrideStep(context, vm, step, action);
              }
            },
            itemBuilder: (_) => [
              if (!step.isSigned)
                PopupMenuItem(
                  value: 'signed',
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.of(context).statusSigned,
                      ),
                      const SizedBox(width: 8),
                      const Text('Mark as Signed'),
                    ],
                  ),
                ),
              if (!step.isFlagged)
                PopupMenuItem(
                  value: 'flag',
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 16,
                        color: AppColors.of(context).statusFlagged,
                      ),
                      const SizedBox(width: 8),
                      const Text('Flag'),
                    ],
                  ),
                ),
              if (!step.isPending)
                PopupMenuItem(
                  value: 'pending',
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                      const SizedBox(width: 8),
                      const Text('Reset to Pending'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

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
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepStatusIcon extends StatelessWidget {
  final String status;

  const _StepStatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColorFromString(context, status);
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