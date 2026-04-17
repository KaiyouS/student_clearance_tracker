import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/features/admin/clearance/viewmodel/admin_clearance_viewmodel.dart';

class AdminClearanceFilters extends StatelessWidget {
  const AdminClearanceFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final statusFilter = context.select<AdminClearanceViewModel, String>(
      (vm) => vm.statusFilter,
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            onChanged: context.read<AdminClearanceViewModel>().updateSearch,
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
                final isSelected = statusFilter == status;
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
                    onSelected: (_) => context
                        .read<AdminClearanceViewModel>()
                        .updateStatusFilter(status),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
