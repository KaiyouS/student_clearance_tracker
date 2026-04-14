import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/office.dart';
import 'package:student_clearance_tracker/core/providers/staff_provider.dart';
import 'package:student_clearance_tracker/core/services/auth_service.dart';
import 'package:student_clearance_tracker/main.dart';

class StaffShell extends StatefulWidget {
  final Widget child;
  const StaffShell({super.key, required this.child});

  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StaffProvider>();
      final user = supabase.auth.currentUser;
      if (user != null && !provider.initialized) {
        provider.loadProfile(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffProvider>();

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Row(
          children: [
            // App name
            Text(
              'Clearance Tracker',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.of(context).info,
              ),
            ),
            const SizedBox(width: 24),

            // Office selector
            if (provider.assignedOffices.isEmpty)
              Text(
                'No offices assigned',
                style: TextStyle(color: AppColors.of(context).danger, fontSize: 13),
              )
            else
              _OfficeSelector(
                offices: provider.assignedOffices,
                selectedOffice: provider.selectedOffice,
                onChanged: provider.selectOffice,
              ),
          ],
        ),
        actions: [
          // Staff name
          if (provider.profile != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    // FIXME: full name not displaying
                    provider.profile!.fullName,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          // Sign out
          TextButton.icon(
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) context.go('/login');
            },
            icon: Icon(
              Icons.logout,
              size: 16,
              color: AppColors.of(context).danger,
            ),
            label: Text(
              'Sign Out',
              style: TextStyle(color: AppColors.of(context).danger, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.of(context).border),
        ),
      ),
      body: widget.child,
    );
  }
}

// ── Office selector dropdown ──────────────────────────────────
class _OfficeSelector extends StatelessWidget {
  final List<Office> offices;
  final Office? selectedOffice;
  final ValueChanged<Office> onChanged;

  const _OfficeSelector({
    required this.offices,
    required this.selectedOffice,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.of(context).info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.of(context).info.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Office>(
          value: selectedOffice,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: AppColors.of(context).info,
          ),
          style: TextStyle(
            fontSize: 13,
            color: AppColors.of(context).info,
            fontWeight: FontWeight.w600,
          ),
          items: offices
              .map((o) => DropdownMenuItem(value: o, child: Text(o.name)))
              .toList(),
          onChanged: (o) {
            if (o != null) onChanged(o);
          },
        ),
      ),
    );
  }
}
