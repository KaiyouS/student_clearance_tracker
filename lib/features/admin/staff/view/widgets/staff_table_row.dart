import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/admin/widgets/account_status_menu.dart';
import 'package:student_clearance_tracker/core/models/office_staff.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/features/admin/staff/view/widgets/staff_actions.dart';
import 'package:student_clearance_tracker/features/admin/staff/view/widgets/staff_office_badge.dart';

TableRow buildStaffTableRow({
  required BuildContext context,
  required OfficeStaff staff,
  required bool isSaving,
}) {
  return TableRow(
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.of(context).border)),
    ),
    children: [
      _dataCell(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              staff.fullName,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      _dataCell(
        Text(
          staff.employeeNo,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.65),
            fontSize: 13,
          ),
        ),
      ),
      _dataCell(
        staff.offices == null || staff.offices!.isEmpty
            ? Text(
                'No offices assigned',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.65),
                  fontSize: 13,
                ),
              )
            : Wrap(
                spacing: 6,
                runSpacing: 4,
                children: staff.offices!
                    .map((o) => StaffOfficeBadge(name: o.name))
                    .toList(),
              ),
      ),
      _dataCell(
        staff.profile != null
            ? AccountStatusMenu(
                currentStatus: staff.profile!.accountStatus,
                onStatusChanged: (s) =>
                    handleUpdateStaffStatusAction(context, staff, s),
              )
            : const SizedBox.shrink(),
      ),
      _dataCell(
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: AppColors.of(context).info,
              tooltip: 'Edit',
              onPressed: isSaving
                  ? null
                  : () => handleEditStaffAction(context, staff),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppColors.of(context).danger,
              tooltip: 'Delete',
              onPressed: isSaving
                  ? null
                  : () => handleDeleteStaffAction(context, staff),
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
