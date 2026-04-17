import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/academic_period.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/features/admin/periods/view/widgets/academic_periods_actions.dart';
import 'package:student_clearance_tracker/features/admin/periods/view/widgets/current_period_badge.dart';

TableRow buildAcademicPeriodsTableRow({
  required BuildContext context,
  required AcademicPeriod period,
  required bool isSaving,
}) {
  return TableRow(
    decoration: BoxDecoration(
      color: period.isCurrent
          ? AppColors.of(context).info.withValues(alpha: 0.04)
          : null,
      border: Border(top: BorderSide(color: AppColors.of(context).border)),
    ),
    children: [
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
      _dataCell(
        period.isCurrent ? const CurrentPeriodBadge() : const SizedBox.shrink(),
      ),
      _dataCell(
        Row(
          children: [
            if (!period.isCurrent)
              Tooltip(
                message: 'Set as current',
                child: IconButton(
                  icon: const Icon(Icons.radio_button_unchecked, size: 18),
                  color: AppColors.of(context).info,
                  onPressed: isSaving
                      ? null
                      : () => handleSetCurrentPeriodAction(context, period),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: AppColors.of(context).info,
              tooltip: 'Edit',
              onPressed: isSaving
                  ? null
                  : () => handleEditPeriodAction(context, period),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: period.isCurrent
                  ? AppColors.of(context).border
                  : AppColors.of(context).danger,
              tooltip: period.isCurrent
                  ? 'Cannot delete current period'
                  : 'Delete',
              onPressed: isSaving
                  ? null
                  : () => handleDeletePeriodAction(context, period),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _dataCell(Widget child) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: child,
  );
}
