import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/academic_period.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/features/admin/periods/view/widgets/academic_periods_table_row.dart';
import 'package:student_clearance_tracker/features/admin/periods/viewmodel/periods_viewmodel.dart';

class AcademicPeriodsTable extends StatelessWidget {
  final List<AcademicPeriod> periods;

  const AcademicPeriodsTable({super.key, required this.periods});

  @override
  Widget build(BuildContext context) {
    final isSaving = context.select<PeriodsViewModel, bool>(
      (vm) => vm.isSaving,
    );

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
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                children: [
                  _headerCell(context, 'Label'),
                  _headerCell(context, 'Date Range'),
                  _headerCell(context, 'Status'),
                  _headerCell(context, ''),
                ],
              ),
              ...periods.map(
                (period) => buildAcademicPeriodsTableRow(
                  context: context,
                  period: period,
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
