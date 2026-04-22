import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/core/constants/app_assets.dart';
import 'package:student_clearance_tracker/core/constants/app_config.dart';
import 'package:student_clearance_tracker/core/services/auth_service.dart';
import 'package:student_clearance_tracker/core/theme/app_dimensions.dart';
import 'package:student_clearance_tracker/core/theme/app_text_styles.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox.square(
                    dimension: 75,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        AppAssets.appLogo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.sm),
                Text(
                  AppConfig.appName,
                  style: AppTextStyles.heading2.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // Text(
            //   AppConfig.appName,
            //   style: TextStyle(
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //     color: Theme.of(context).colorScheme.primary,
            //     height: 1.2,
            //   ),
            // ),
          ),

          // Divider(height: 1, color: Theme.of(context).dividerColor),
          // const SizedBox(height: 8),

          // Nav items
          _NavItem(
            icon: PhosphorIconsLight.squaresFour,
            label: 'Dashboard',
            path: '/admin/dashboard',
            isActive: location == '/admin/dashboard',
          ),
          _NavItem(
            icon: PhosphorIconsLight.buildings,
            label: 'Offices',
            path: '/admin/offices',
            isActive: location == '/admin/offices',
          ),
          _NavItem(
            icon: PhosphorIconsLight.user,
            label: 'Staff',
            path: '/admin/staff',
            isActive: location == '/admin/staff',
          ),
          _NavItem(
            icon: PhosphorIconsLight.graduationCap,
            label: 'Students',
            path: '/admin/students',
            isActive: location == '/admin/students',
          ),
          _NavItem(
            icon: PhosphorIconsLight.listChecks,
            label: 'Clearance',
            path: '/admin/clearance',
            isActive: location == '/admin/clearance',
          ),
          _NavItem(
            icon: PhosphorIconsLight.treeStructure,
            label: 'Prerequisites',
            path: '/admin/prerequisites',
            isActive: location == '/admin/prerequisites',
          ),
          _NavItem(
            icon: PhosphorIconsLight.listDashes,
            label: 'Requirements',
            path: '/admin/requirements',
            isActive: location == '/admin/requirements',
          ),
          _NavItem(
            icon: PhosphorIconsLight.bank,
            label: 'Schools',
            path: '/admin/schools',
            isActive: location == '/admin/schools',
          ),
          _NavItem(
            icon: PhosphorIconsLight.calendar,
            label: 'Academic Periods',
            path: '/admin/periods',
            isActive: location == '/admin/periods',
          ),
          const Spacer(),
          Divider(height: 1, color: Theme.of(context).dividerColor),
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

// —— Individual nav item ——————————————————————————————————————
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
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.go(path),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                PhosphorIcon(
                  icon,
                  size: 20,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
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
                        ? Theme.of(context).colorScheme.primary
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

// —— Sign out button ——————————————————————————————————————————
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
                PhosphorIcon(
                  PhosphorIconsLight.signOut,
                  size: 20,
                  color: Theme.of(context).colorScheme.error,
                ),
                SizedBox(width: 12),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.error,
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
