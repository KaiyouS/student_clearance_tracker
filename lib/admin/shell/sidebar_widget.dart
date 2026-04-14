import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:student_clearance_tracker/core/services/auth_service.dart';
import 'package:student_clearance_tracker/core/widgets/theme_toggle.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Container(
      width: 240,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App title / logo area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Text(
              'Clearance\nTracker',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.of(context).info,
                height: 1.2,
              ),
            ),
          ),

          Divider(height: 1, color: AppColors.of(context).border),
          const SizedBox(height: 8),

          // Nav items
          _NavItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            path: '/admin/dashboard',
            isActive: location == '/admin/dashboard',
          ),
          _NavItem(
            icon: Icons.business_outlined,
            label: 'Offices',
            path: '/admin/offices',
            isActive: location == '/admin/offices',
          ),
          _NavItem(
            icon: Icons.people_outlined,
            label: 'Staff',
            path: '/admin/staff',
            isActive: location == '/admin/staff',
          ),
          _NavItem(
            icon: Icons.school_outlined,
            label: 'Students',
            path: '/admin/students',
            isActive: location == '/admin/students',
          ),
          _NavItem(
            icon: Icons.checklist_outlined,
            label: 'Clearance',
            path: '/admin/clearance',
            isActive: location == '/admin/clearance',
          ),
          _NavItem(
            icon: Icons.account_tree_outlined,
            label: 'Prerequisites',
            path: '/admin/prerequisites',
            isActive: location == '/admin/prerequisites',
          ),
          _NavItem(
            icon: Icons.rule_outlined,
            label: 'Requirements',
            path: '/admin/requirements',
            isActive: location == '/admin/requirements',
          ),
          _NavItem(
            icon: Icons.account_balance_outlined,
            label: 'Schools',
            path: '/admin/schools',
            isActive: location == '/admin/schools',
          ),
          _NavItem(
            icon: Icons.calendar_month_outlined,
            label: 'Academic Periods',
            path: '/admin/periods',
            isActive: location == '/admin/periods',
          ),
          const Spacer(),
          Divider(height: 1, color: AppColors.of(context).border),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ThemeToggle(),
          ),
          // Sign out
          _SignOutButton(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Individual nav item ──────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final bool isActive;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isActive
            ? AppColors.of(context).info.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.go(path),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? AppColors.of(context).info
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive
                        ? AppColors.of(context).info
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sign out button ──────────────────────────────────────────
class _SignOutButton extends StatelessWidget {
  final _authService = AuthService();

  _SignOutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            await _authService.signOut();
            if (context.mounted) context.go('/login');
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  size: 20,
                  color: AppColors.of(context).danger,
                ),
                SizedBox(width: 12),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.of(context).danger,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
