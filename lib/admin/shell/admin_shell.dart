import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import 'sidebar_widget.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          const SidebarWidget(),
          // Divider line
          Container(width: 1, color: AppTheme.border),
          // Main content area
          Expanded(child: child),
        ],
      ),
    );
  }
}