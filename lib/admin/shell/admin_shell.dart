import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/admin/shell/sidebar_widget.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          const SidebarWidget(),
          // Divider line
          Container(width: 1, color: AppColors.of(context).border),
          // Main content area
          Expanded(child: child),
        ],
      ),
    );
  }
}
