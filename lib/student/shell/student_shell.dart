import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/student_provider.dart';
import '../../core/theme/app_theme.dart';

class StudentShell extends StatelessWidget {
  final Widget child;
  const StudentShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<StudentProvider>();
    final location  = GoRouterState.of(context).matchedLocation;
    final isDark    = Theme.of(context).brightness == Brightness.dark;

    int currentIndex = 0;
    if (location == '/student/clearance') currentIndex = 1;
    if (location == '/student/profile')   currentIndex = 2;

    return Scaffold(
      body: Stack(
        children: [
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : child,

          // In-app notification banner (web + mobile foreground)
          if (provider.notifications.isNotEmpty)
            _NotificationBanner(
              notification: provider.notifications.last,
              onDismiss:    () => provider.dismissNotification(
                provider.notifications.length - 1,
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/student/home');      break;
            case 1: context.go('/student/clearance'); break;
            case 2: context.go('/student/profile');   break;
          }
        },
        destinations: [
          const NavigationDestination(
            icon:         Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label:        'Home',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: provider.flaggedSteps > 0,
              label:          Text(provider.flaggedSteps.toString()),
              child: const Icon(Icons.checklist_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: provider.flaggedSteps > 0,
              label:          Text(provider.flaggedSteps.toString()),
              child: const Icon(Icons.checklist),
            ),
            label: 'Clearance',
          ),
          const NavigationDestination(
            icon:         Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label:        'Profile',
          ),
        ],
      ),
    );
  }
}

// ── In-app notification banner ────────────────────────────────
class _NotificationBanner extends StatefulWidget {
  final InAppNotification notification;
  final VoidCallback      onDismiss;

  const _NotificationBanner({
    required this.notification,
    required this.onDismiss,
  });

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _ctrl.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSigned = widget.notification.status == 'signed';
    final color    = isSigned ? AppTheme.statusSigned : AppTheme.statusFlagged;

    return Positioned(
      top:   MediaQuery.of(context).padding.top + 8,
      left:  16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: Material(
          borderRadius: BorderRadius.circular(12),
          elevation:    4,
          color:        color,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  isSigned
                      ? Icons.check_circle
                      : Icons.flag,
                  color: Colors.white,
                  size:  20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.notification.message,
                    style: const TextStyle(
                      color:      Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize:   13,
                    ),
                  ),
                ),
                IconButton(
                  icon:       const Icon(Icons.close, size: 16),
                  color:      Colors.white,
                  onPressed:  widget.onDismiss,
                  padding:    EdgeInsets.zero,
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