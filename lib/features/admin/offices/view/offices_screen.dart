import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/core/models/office.dart';
import 'package:student_clearance_tracker/core/theme/app_dimensions.dart';
import 'package:student_clearance_tracker/core/theme/app_text_styles.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/core/widgets/confirm_dialog.dart';
import 'package:student_clearance_tracker/features/admin/offices/view/office_form_dialog.dart';
import 'package:student_clearance_tracker/features/admin/offices/viewmodel/offices_viewmodel.dart';

class OfficesScreen extends StatelessWidget {
  const OfficesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OfficesViewModel()..loadOffices(),
      child: const _OfficesScreenContent(),
    );
  }
}

class _OfficesScreenContent extends StatelessWidget {
  const _OfficesScreenContent();

  Future<void> _handleCreate(BuildContext context) async {
    final result = await OfficeFormDialog.show(context);
    if (result == null) return;

    if (!context.mounted) return;
    final vm = context.read<OfficesViewModel>();

    final success = await vm.createOffice(
      result['name']!,
      result['description']!.isEmpty ? null : result['description'],
    );

    if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _handleEdit(BuildContext context, Office office) async {
    final result = await OfficeFormDialog.show(context, office: office);
    if (result == null) return;

    if (!context.mounted) return;
    final vm = context.read<OfficesViewModel>();

    final success = await vm.updateOffice(
      office.id,
      result['name']!,
      result['description']!.isEmpty ? null : result['description'],
    );

    if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  Future<void> _handleDelete(BuildContext context, Office office) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Office',
      message:
          'Are you sure you want to delete "${office.name}"? This cannot be undone.',
    );
    if (!confirmed) return;

    if (!context.mounted) return;
    final vm = context.read<OfficesViewModel>();

    final success = await vm.deleteOffice(office.id);

    if (!success && context.mounted && vm.errorMessage != null) {
      _showError(context, vm.errorMessage!);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OfficesViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
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
                        'Offices',
                        style: AppTextStyles.heading1.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      Text(
                        'Manage offices and their clearance descriptions.',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: vm.isLoading ? null : () => _handleCreate(context),
                  icon: const PhosphorIcon(PhosphorIconsLight.plus),
                  label: const Text('Add Office'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),

            SizedBox(
              width: 320,
              child: TextField(
                onChanged: context.read<OfficesViewModel>().search,
                decoration: const InputDecoration(
                  hintText: 'Search offices...',
                  prefixIcon: PhosphorIcon(PhosphorIconsLight.magnifyingGlass),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),

            Expanded(child: _buildContent(context, vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, OfficesViewModel vm) {
    if (vm.isLoading && vm.filteredOffices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null && vm.filteredOffices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Failed to load offices.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: vm.loadOffices,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (vm.filteredOffices.isEmpty) {
      return Center(
        child: Text(
          vm.searchQuery.isEmpty
              ? 'No offices yet.'
              : 'No offices match "${vm.searchQuery}".',
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: SingleChildScrollView(
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
              2: FixedColumnWidth(120),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                children: [
                  _headerCell(context, 'Office Name'),
                  _headerCell(context, 'Description'),
                  _headerCell(context, ''),
                ],
              ),
              ...vm.filteredOffices.map(
                (office) => TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  children: [
                    _dataCell(
                      Text(
                        office.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    _dataCell(
                      Text(
                        office.description ?? '-',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _dataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const PhosphorIcon(
                              PhosphorIconsLight.pencilSimple,
                              size: 18,
                            ),
                            color: Theme.of(context).colorScheme.primary,
                            tooltip: 'Edit',
                            onPressed: vm.isLoading
                                ? null
                                : () => _handleEdit(context, office),
                          ),
                          IconButton(
                            icon: const PhosphorIcon(
                              PhosphorIconsLight.trash,
                              size: 18,
                            ),
                            color: Theme.of(context).colorScheme.error,
                            tooltip: 'Delete',
                            onPressed: vm.isLoading
                                ? null
                                : () => _handleDelete(context, office),
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
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.md,
      vertical: 12,
    ),
    child: Text(
      label,
      style: AppTextStyles.bodySm.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
      ),
    ),
  );

  Widget _dataCell(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.md,
      vertical: 12,
    ),
    child: child,
  );
}
