import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/office_staff.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/features/admin/staff/viewmodel/staff_viewmodel.dart';
import 'package:student_clearance_tracker/features/admin/staff/view/widgets/staff_table_row.dart';

class StaffTable extends StatelessWidget {
  final List<OfficeStaff> staffList;

  const StaffTable({super.key, required this.staffList});

  @override
  Widget build(BuildContext context) {
    final isSaving = context.select<StaffViewModel, bool>((vm) => vm.isSaving);

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FixedColumnWidth(140),
              2: FlexColumnWidth(3),
              3: FixedColumnWidth(130),
              4: FixedColumnWidth(120),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                children: [
                  _headerCell(context, 'Name'),
                  _headerCell(context, 'Employee No.'),
                  _headerCell(context, 'Assigned Offices'),
                  _headerCell(context, 'Status'),
                  _headerCell(context, ''),
                ],
              ),
              ...staffList.map(
                (staff) => buildStaffTableRow(
                  context: context,
                  staff: staff,
                  isSaving: isSaving,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _headerCell(BuildContext context, String label) {
  return Padding(
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
}
