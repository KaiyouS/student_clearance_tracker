import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/widgets/app_card.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/view/widgets/prerequisites_office_list_tile.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/viewmodel/prerequisites_viewmodel.dart';

class PrerequisitesOfficeListPanel extends StatelessWidget {
  const PrerequisitesOfficeListPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select<PrerequisitesViewModel, int>(
      (vm) => vm.allOffices.length,
    );

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          itemCount: count,
          separatorBuilder: (_, _) =>
              Divider(height: 1, color: Theme.of(context).dividerColor),
          itemBuilder: (context, i) => PrerequisitesOfficeListTile(index: i),
        ),
      ),
    );
  }
}

