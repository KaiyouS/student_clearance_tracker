import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/features/admin/staff/viewmodel/staff_viewmodel.dart';

class StaffSearchBar extends StatelessWidget {
  const StaffSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: TextField(
        onChanged: context.read<StaffViewModel>().search,
        decoration: const InputDecoration(
          hintText: 'Search by name or employee no...',
          prefixIcon: PhosphorIcon(PhosphorIconsLight.magnifyingGlass),
        ),
      ),
    );
  }
}
