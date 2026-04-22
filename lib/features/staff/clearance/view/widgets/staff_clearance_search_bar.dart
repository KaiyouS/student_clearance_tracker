import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/features/staff/clearance/viewmodel/staff_clearance_viewmodel.dart';

class StaffClearanceSearchBar extends StatelessWidget {
  const StaffClearanceSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: TextField(
        onChanged: context.read<StaffClearanceViewModel>().updateSearch,
        decoration: const InputDecoration(
          hintText: 'Search by name or student no...',
          prefixIcon: PhosphorIcon(PhosphorIconsLight.magnifyingGlass),
          isDense: true,
        ),
      ),
    );
  }
}
