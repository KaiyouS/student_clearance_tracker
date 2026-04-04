import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/models/office.dart';
import '../../core/providers/staff_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';

class StaffShell extends StatelessWidget {
  final Widget child;
  const StaffShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation:       0,
        title: Row(
          children: [
            // App name
            const Text(
              'Clearance Tracker',
              style: TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.bold,
                color:      AppTheme.primary,
              ),
            ),
            const SizedBox(width: 24),

            // Office selector
            if (provider.assignedOffices.isEmpty)
              const Text(
                'No offices assigned',
                style: TextStyle(
                  color:    AppTheme.danger,
                  fontSize: 13,
                ),
              )
            else
              _OfficeSelector(
                offices:        provider.assignedOffices,
                selectedOffice: provider.selectedOffice,
                onChanged:      provider.selectOffice,
              ),
          ],
        ),
        actions: [
          // Staff name
          if (provider.profile != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 12,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size:  16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    provider.profile!.fullName,
                    style: const TextStyle(
                      fontSize: 13,
                      color:    AppTheme.textSecondary,
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
            icon:  const Icon(
              Icons.logout,
              size:  16,
              color: AppTheme.danger,
            ),
            label: const Text(
              'Sign Out',
              style: TextStyle(
                color:   AppTheme.danger,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.border),
        ),
      ),
      body: child,
    );
  }
}

// ── Office selector dropdown ──────────────────────────────────
class _OfficeSelector extends StatelessWidget {
  final List<Office>     offices;
  final Office?          selectedOffice;
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
        color:        AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Office>(
          value:       selectedOffice,
          isDense:     true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size:  16,
            color: AppTheme.primary,
          ),
          style: const TextStyle(
            fontSize: 13,
            color:    AppTheme.primary,
            fontWeight: FontWeight.w600,
          ),
          items: offices
              .map((o) => DropdownMenuItem(
                    value: o,
                    child: Text(o.name),
                  ))
              .toList(),
          onChanged: (o) { if (o != null) onChanged(o); },
        ),
      ),
    );
  }
}