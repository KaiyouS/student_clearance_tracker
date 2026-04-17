import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/models/office.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/features/admin/requirements/viewmodel/requirements_viewmodel.dart';

class OfficeRequirementsScreen extends StatelessWidget {
  const OfficeRequirementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RequirementsViewModel()..loadData(),
      child: const _OfficeRequirementsScreenContent(),
    );
  }
}

class _OfficeRequirementsScreenContent extends StatelessWidget {
  const _OfficeRequirementsScreenContent();

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  Color _requirementColor(BuildContext context, Office office, RequirementsViewModel vm) {
    final summary = vm.requirementSummary(office);
    if (summary == 'No students') return AppColors.contentSecondary(context);
    if (summary == 'All students') return Theme.of(context).colorScheme.tertiary;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RequirementsViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Office Requirements', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text('Define which programs each office applies to when generating student clearance.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 14)),
            const SizedBox(height: 24),
            Expanded(child: _buildBody(context, vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, RequirementsViewModel vm) {
    if (vm.isLoading && vm.offices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null && vm.offices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: vm.loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left - office list
        SizedBox(
          width: 300,
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Text('Offices', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                Expanded(
                  child: ListView.separated(
                    itemCount: vm.offices.length,
                    separatorBuilder: (_, _) => Divider(height: 1, color: Theme.of(context).dividerColor),
                    itemBuilder: (context, i) {
                      final office = vm.offices[i];
                      final isSelected = vm.selectedOffice?.id == office.id;
                      final summary = vm.requirementSummary(office);
                      final color = _requirementColor(context, office, vm);

                      return ListTile(
                        selected: isSelected,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                        title: Text(office.name, style: const TextStyle(fontSize: 13)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: Text(summary, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
                        ),
                        onTap: () => context.read<RequirementsViewModel>().selectOffice(office),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Right - requirements for selected office
        Expanded(
          child: vm.selectedOffice == null
              ? AppCard(
                  child: Center(
                    child: Text('Select an office to manage its requirements.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
                  ),
                )
              : _buildRequirementsPanel(context, vm, vm.selectedOffice!),
        ),
      ],
    );
  }

  Widget _buildRequirementsPanel(BuildContext context, RequirementsViewModel vm, Office office) {
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
                    Text(office.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 4),
                    Text(
                      vm.appliesToAll
                          ? 'Required for all graduating students.'
                          : vm.assignedProgramIds.isEmpty
                          ? 'Not assigned to any program yet.'
                          : 'Required for ${vm.assignedProgramIds.length} program${vm.assignedProgramIds.length != 1 ? 's' : ''}.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (vm.isSaving) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: Theme.of(context).dividerColor),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: vm.appliesToAll ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.06) : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: vm.appliesToAll ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3) : Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                Icon(Icons.people_outlined, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Applies to all students', style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                      Text('Every graduating student must clear this office regardless of program.', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
                    ],
                  ),
                ),
                Switch(
                  value: vm.appliesToAll,
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                  onChanged: vm.isSaving ? null : (v) async {
                    final success = await context.read<RequirementsViewModel>().toggleAppliesToAll(v);
                    if (!success && context.mounted && vm.errorMessage != null) _showError(context, vm.errorMessage!);
                  },
                ),
              ],
            ),
          ),

          if (!vm.appliesToAll) ...[
            const SizedBox(height: 16),
            Text('Specific Programs', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text('Only students enrolled in the selected programs will have this office on their clearance.', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: vm.programsBySchool.entries.map((entry) {
                    final school = entry.key;
                    final programs = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 4),
                          child: Text(school.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), letterSpacing: 0.5)),
                        ),
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor), borderRadius: BorderRadius.circular(8)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Column(
                              children: programs.asMap().entries.map((e) {
                                final idx = e.key;
                                final program = e.value;
                                final checked = vm.assignedProgramIds.contains(program.id);

                                return Column(
                                  children: [
                                    if (idx > 0) Divider(height: 1, color: Theme.of(context).dividerColor),
                                    CheckboxListTile(
                                      dense: true,
                                      value: checked,
                                      activeColor: Theme.of(context).colorScheme.primary,
                                      title: Text(program.name, style: const TextStyle(fontSize: 13)),
                                      controlAffinity: ListTileControlAffinity.leading,
                                      onChanged: vm.isSaving ? null : (v) async {
                                        final success = await context.read<RequirementsViewModel>().toggleProgram(program.id, v ?? false);
                                        if (!success && context.mounted && vm.errorMessage != null) _showError(context, vm.errorMessage!);
                                      },
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

