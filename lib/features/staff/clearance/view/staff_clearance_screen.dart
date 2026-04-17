import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/clearance_step.dart';
import 'package:student_clearance_tracker/features/staff/shell/viewmodel/staff_shell_viewmodel.dart';
import 'package:student_clearance_tracker/features/staff/clearance/viewmodel/staff_clearance_viewmodel.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/core/widgets/status_badge.dart';
import 'package:student_clearance_tracker/main.dart';

// We wrap the UI in a Provider so it gets a fresh ViewModel
class StaffClearanceScreen extends StatelessWidget {
  const StaffClearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StaffClearanceViewModel(),
      child: const _StaffClearanceScreenContent(),
    );
  }
}

class _StaffClearanceScreenContent extends StatefulWidget {
  const _StaffClearanceScreenContent();

  @override
  State<_StaffClearanceScreenContent> createState() => _StaffClearanceScreenContentState();
}

class _StaffClearanceScreenContentState extends State<_StaffClearanceScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _lastOfficeId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Listen to the global StaffShellViewModel to see if the office changed in the shell
    final currentOfficeId = context.watch<StaffShellViewModel>().selectedOffice?.id;
    final viewModel = context.read<StaffClearanceViewModel>();

    if (currentOfficeId != _lastOfficeId) {
      _lastOfficeId = currentOfficeId;
      
      // Schedule the data fetch to happen immediately AFTER the build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return; // Always safe to check
        
        if (viewModel.isLoading) {
          viewModel.loadPeriodThenSteps(currentOfficeId);
        } else {
          viewModel.loadSteps(currentOfficeId);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleSign(ClearanceStep step) async {
    final vm = context.read<StaffClearanceViewModel>();
    final success = await vm.signStep(step, supabase.auth.currentUser!.id);
    if (success) {
      _showSuccess('Clearance signed for ${step.studentName ?? 'student'}.');
    } else {
      _showError(vm.error ?? 'Failed to sign.');
    }
  }

  Future<void> _handleFlag(ClearanceStep step) async {
    final remarkController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Flag ${step.studentName ?? 'Student'}'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: remarkController,
            decoration: const InputDecoration(labelText: 'Reason for flagging', hintText: 'Describe the issue...'),
            maxLines: 3,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.of(context).danger, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
            child: const Text('Flag'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    
    if (!mounted) return;
    
    final vm = context.read<StaffClearanceViewModel>();
    final success = await vm.flagStep(step, supabase.auth.currentUser!.id, remarkController.text.trim());
    remarkController.dispose();
    
    if (success) {
      _showSuccess('Step flagged.');
    } else {
      _showError(vm.error ?? 'Failed to flag.');
    }
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.of(context).success));
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.of(context).danger));
  }

  @override
  Widget build(BuildContext context) {
    final officeName = context.select<StaffShellViewModel, String>((p) => p.selectedOffice?.name ?? 'No Office Selected');
    final vm = context.watch<StaffClearanceViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(officeName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text('Review and sign student clearance requests.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  color: AppColors.of(context).info,
                  tooltip: 'Refresh',
                  onPressed: vm.isLoading ? null : () => vm.loadSteps(_lastOfficeId),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 320,
              child: TextField(
                onChanged: vm.updateSearch,
                decoration: const InputDecoration(hintText: 'Search by name or student no...', prefixIcon: Icon(Icons.search), isDense: true),
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.of(context).info,
                    unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    indicatorColor: AppColors.of(context).info,
                    tabs: [
                      _buildTab('Pending', vm.statusCounts['pending'] ?? 0, AppColors.of(context).statusPending),
                      _buildTab('Flagged', vm.statusCounts['flagged'] ?? 0, AppColors.of(context).statusFlagged),
                      _buildTab('Signed', vm.statusCounts['signed'] ?? 0, AppColors.of(context).statusSigned),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 320,
                    child: vm.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : vm.error != null
                        ? Center(child: Text(vm.error!, style: TextStyle(color: AppColors.of(context).danger)))
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildStepList(vm.filteredByStatus['pending']!, vm),
                              _buildStepList(vm.filteredByStatus['flagged']!, vm),
                              _buildStepList(vm.filteredByStatus['signed']!, vm),
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
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Text(count.toString(), style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStepList(List<ClearanceStep> steps, StaffClearanceViewModel vm) {
    if (steps.isEmpty) return Center(child: Text('No steps found.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))));

    return ListView.separated(
      padding: const EdgeInsets.all(0),
      itemCount: steps.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: AppColors.of(context).border),
      itemBuilder: (context, i) => _buildStepRow(steps[i], vm),
    );
  }

  Widget _buildStepRow(ClearanceStep step, StaffClearanceViewModel vm) {
    final canSign = vm.prereqCache[step.id] ?? false;
    final isPending = step.isPending;
    final isFlagged = step.isFlagged;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.studentName ?? '—', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(step.studentNo ?? '—', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
                if (isPending && !canSign) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.lock_outline, size: 12, color: AppColors.of(context).warning),
                      const SizedBox(width: 4),
                      Text('Prerequisites not yet complete', style: TextStyle(fontSize: 11, color: AppColors.of(context).warning)),
                    ],
                  ),
                ],
                if (isFlagged && step.remarks != null) ...[
                  const SizedBox(height: 4),
                  Text(step.remarks!, style: TextStyle(fontSize: 12, color: AppColors.of(context).statusFlagged)),
                ],
              ],
            ),
          ),
          StatusBadge(status: step.status),
          const SizedBox(width: 12),
          if (isPending) ...[
            ElevatedButton(
              onPressed: (vm.isSaving || !canSign) ? null : () => _handleSign(step),
              style: ElevatedButton.styleFrom(backgroundColor: canSign ? AppColors.of(context).statusSigned : AppColors.of(context).border, foregroundColor: Colors.white, minimumSize: const Size(72, 36)),
              child: const Text('Sign', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: vm.isSaving ? null : () => _handleFlag(step),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.of(context).danger, side: BorderSide(color: AppColors.of(context).danger), minimumSize: const Size(72, 36)),
              child: const Text('Flag', style: TextStyle(fontSize: 13)),
            ),
          ] else if (isFlagged) ...[
            ElevatedButton(
              onPressed: vm.isSaving ? null : () => _handleSign(step),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.of(context).statusSigned, foregroundColor: Colors.white, minimumSize: const Size(80, 36)),
              child: const Text('Sign', style: TextStyle(fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}