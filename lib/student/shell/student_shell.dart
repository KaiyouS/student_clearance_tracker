import 'dart:async';

import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/providers/student_provider.dart';
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
      final provider = context.read<StudentProvider>();
      final user = supabase.auth.currentUser;

      if (user != null && !provider.initialized) {
        provider.loadData(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<StudentProvider, bool>((p) => p.isLoading);
    final latestNotification = context.select<StudentProvider, InAppNotification?>(
      (p) => p.latestNotification,
    );
    final notificationCount = context.select<StudentProvider, int>(
      (p) => p.notifications.length,
    );
    final unseenUpdates = context.select<StudentProvider, int>(
      (p) => p.unseenUpdates,
    );

    final provider = context.read<StudentProvider>();
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location == '/student/clearance') currentIndex = 1;
    if (location == '/student/profile') currentIndex = 2;

    return Scaffold(
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.child,

          // In-app notification banner (web + mobile foreground)
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
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          final leavingClearance = currentIndex == 1 && i != 1;

          if (leavingClearance) {
            provider.clearChangedSteps();
          }

          switch (i) {
            case 0:
              context.go('/student/home');
              break;
            case 1:
              context.go('/student/clearance');
              context.read<StudentProvider>().markClearanceVisited();
              break;
            case 2:
              context.go('/student/profile');
              break;
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unseenUpdates > 0,
              label: Text(unseenUpdates.toString()),
              child: Icon(Icons.checklist_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: unseenUpdates > 0,
              label: Text(unseenUpdates.toString()),
              child: Icon(Icons.checklist),
            ),
            label: 'Clearance',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ── In-app notification banner ────────────────────────────────
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
        ? AppColors.of(context).statusSigned
        : AppColors.of(context).statusFlagged;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
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
                Icon(
                  isSigned ? Icons.check_circle : Icons.flag,
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
                  icon: Icon(Icons.close, size: 16),
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
