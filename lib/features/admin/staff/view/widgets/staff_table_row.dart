import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/admin/widgets/account_status_menu.dart';
import 'package:student_clearance_tracker/core/models/office_staff.dart';
import 'package:student_clearance_tracker/features/admin/staff/view/widgets/staff_actions.dart';
import 'package:student_clearance_tracker/features/admin/staff/view/widgets/staff_office_badge.dart';

TableRow buildStaffTableRow({
  required BuildContext context,
  required OfficeStaff staff,
  required bool isSaving,
}) {
  return TableRow(
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
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
              icon: const PhosphorIcon(
                PhosphorIconsLight.pencilSimple,
                size: 18,
              ),
              color: Theme.of(context).colorScheme.primary,
              tooltip: 'Edit',
              onPressed: isSaving
                  ? null
                  : () => handleEditStaffAction(context, staff),
            ),
            IconButton(
              icon: const PhosphorIcon(PhosphorIconsLight.trash, size: 18),
              color: Theme.of(context).colorScheme.error,
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
