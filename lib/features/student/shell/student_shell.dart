import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/student/shell/viewmodel/student_shell_viewmodel.dart';
import 'package:student_clearance_tracker/main.dart';

class StudentShell extends StatefulWidget {
  final Widget child;
  const StudentShell({super.key, required this.child});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  @override
  void initState() {
    super.initState();
    // Load student data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StudentShellViewModel>();
      final user = supabase.auth.currentUser;

      if (user != null && !provider.initialized) {
        provider.loadData(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<StudentShellViewModel, bool>(
      (p) => p.isLoading,
    );
    // final latestNotification = context
    //     .select<StudentShellViewModel, InAppNotification?>(
    //       (p) => p.latestNotification,
    //     );
    final latestNotification = InAppNotification(
      officeName: 'Test A',
      status: "signed", // Change to 'flagged' to test the red error color!
    );
    final notificationCount = context.select<StudentShellViewModel, int>(
      (p) => p.notifications.length,
    );
    final unseenUpdates = context.select<StudentShellViewModel, int>(
      (p) => p.unseenUpdates,
    );

    final provider = context.read<StudentShellViewModel>();
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location == '/student/clearance') currentIndex = 1;
    if (location == '/student/profile') currentIndex = 2;

    // Determine if we are on a wide screen (Web/Desktop)
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    // Centralize the navigation logic so both Navbars can use it
    void handleNavigation(int index) {
      final leavingClearance = currentIndex == 1 && index != 1;
      if (leavingClearance) {
        provider.clearChangedSteps();
      }

      switch (index) {
        case 0:
          context.go('/student/home');
          break;
        case 1:
          context.go('/student/clearance');
          provider.markClearanceVisited();
          break;
        case 2:
          context.go('/student/profile');
          break;
      }
    }

    // Package your main screen content (including the banner) into a variable
    Widget mainContent = Stack(
      children: [
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : widget.child,

        // In-app notification banner
        if (latestNotification != null)
          _NotificationBanner(
            key: ValueKey(latestNotification.time.microsecondsSinceEpoch),
            notification: latestNotification,
            onDismiss: () {
              if (notificationCount > 0) {
                provider.dismissNotification(notificationCount - 1);
              }
            },
          ),
      ],
    );

    return Scaffold(
      // If Desktop, put the NavigationRail and mainContent side-by-side in a Row
      body: isMobile
          ? mainContent
          : Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: handleNavigation,
                  labelType:
                      NavigationRailLabelType.all, // Shows text under icons
                  destinations: [
                    const NavigationRailDestination(
                      icon: PhosphorIcon(PhosphorIconsLight.house),
                      selectedIcon: PhosphorIcon(PhosphorIconsLight.house),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Badge(
                        isLabelVisible: unseenUpdates > 0,
                        label: Text(unseenUpdates.toString()),
                        child: const PhosphorIcon(
                          PhosphorIconsLight.listChecks,
                        ),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: unseenUpdates > 0,
                        label: Text(unseenUpdates.toString()),
                        child: const PhosphorIcon(
                          PhosphorIconsLight.listChecks,
                        ),
                      ),
                      label: const Text('Clearance'),
                    ),
                    const NavigationRailDestination(
                      icon: PhosphorIcon(PhosphorIconsLight.user),
                      selectedIcon: PhosphorIcon(PhosphorIconsLight.user),
                      label: Text('Profile'),
                    ),
                  ],
                ),
                // A subtle divider line separating the rail from the content
                const VerticalDivider(thickness: 1, width: 1),
                // Expanded makes the mainContent take up the rest of the screen
                Expanded(child: mainContent),
              ],
            ),

      // If Mobile, show the bottom nav. If Desktop, hide it.
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: handleNavigation,
              destinations: [
                const NavigationDestination(
                  icon: PhosphorIcon(PhosphorIconsLight.house),
                  selectedIcon: PhosphorIcon(PhosphorIconsLight.house),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: unseenUpdates > 0,
                    label: Text(unseenUpdates.toString()),
                    child: const PhosphorIcon(PhosphorIconsLight.listChecks),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: unseenUpdates > 0,
                    label: Text(unseenUpdates.toString()),
                    child: const PhosphorIcon(PhosphorIconsLight.listChecks),
                  ),
                  label: 'Clearance',
                ),
                const NavigationDestination(
                  icon: PhosphorIcon(PhosphorIconsLight.user),
                  selectedIcon: PhosphorIcon(PhosphorIconsLight.user),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }
}

// In-app notification banner
class _NotificationBanner extends StatefulWidget {
  final InAppNotification notification;
  final VoidCallback onDismiss;

  const _NotificationBanner({
    super.key,
    required this.notification,
    required this.onDismiss,
  });

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  void _dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;
    _dismissTimer?.cancel();

    _ctrl.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();

    // Auto-dismiss after 4 seconds
    _dismissTimer = Timer(const Duration(seconds: 4), _dismiss);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSigned = widget.notification.status == 'signed';
    final color = isSigned
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.error;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: Material(
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
          color: color,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                PhosphorIcon(
                  isSigned
                      ? PhosphorIconsLight.checkCircle
                      : PhosphorIconsLight.flag,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.notification.message,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                IconButton(
                  icon: PhosphorIcon(PhosphorIconsLight.x, size: 16),
                  color: Colors.white,
                  onPressed: _dismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
