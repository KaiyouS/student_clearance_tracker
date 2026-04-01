import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/screens/login_screen.dart';
import 'core/services/auth_service.dart';
import 'admin/shell/admin_shell.dart';
import 'admin/screens/dashboard_screen.dart';
import 'student/screens/home_screen.dart';
import 'main.dart';

final _authService = AuthService();

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final session = supabase.auth.currentSession;
    final isLoggingIn = state.matchedLocation == '/login';

    // Not logged in → always go to login
    if (session == null) {
      return isLoggingIn ? null : '/login';
    }

    // Already logged in and trying to visit /login → redirect to correct shell
    if (isLoggingIn) {
      final roles = await _authService.getUserRoles(session.user.id);
      if (roles.contains('super_admin') || roles.contains('office_staff')) {
        return '/admin/dashboard';
      } else if (roles.contains('student')) {
        return '/student/home';
      }
    }

    return null; // no redirect needed
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Admin routes — wrapped in shell (sidebar layout)
    ShellRoute(
      builder: (context, state, child) => AdminShell(child: child),
      routes: [
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        // We'll add more admin routes here as we build them
        // GoRoute(path: '/admin/offices', ...),
        // GoRoute(path: '/admin/staff', ...),
      ],
    ),

    // Student routes — wrapped in shell (bottom nav layout) later
    GoRoute(
      path: '/student/home',
      builder: (context, state) => const StudentHomeScreen(),
    ),
  ],
);