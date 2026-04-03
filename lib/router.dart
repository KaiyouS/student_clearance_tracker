import 'package:go_router/go_router.dart';
import 'core/repositories/user_profile_repository.dart';
import 'core/screens/change_password_screen.dart';
import 'core/screens/login_screen.dart';
import 'core/services/auth_service.dart';
import 'admin/shell/admin_shell.dart';
import 'admin/screens/dashboard_screen.dart';
import 'admin/screens/offices_screen.dart';
import 'admin/screens/prerequisites_screen.dart';
import 'admin/screens/staff_screen.dart';
import 'admin/screens/students_screen.dart';
import 'student/screens/home_screen.dart';
import 'main.dart';

final _authService = AuthService();

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final session  = supabase.auth.currentSession;
    final location = state.matchedLocation;

    final isLoggingIn    = location == '/login';
    final isChangingPw   = location == '/change-password';

    // Not logged in → always go to login
    if (session == null) {
      return isLoggingIn ? null : '/login';
    }

    // ── Logged in — check profile on every navigation ──
    final profile = await UserProfileRepository()
        .getById(session.user.id);

    // Profile missing → something is wrong → back to login
    if (profile == null) {
      await supabase.auth.signOut();
      return '/login';
    }

    // Account locked or inactive → back to login
    // (login screen will show the error on next attempt)
    if (profile.isLocked || profile.isInactive) {
      await supabase.auth.signOut();
      return '/login';
    }

    // Must change password → ONLY /change-password is allowed
    if (profile.needsPasswordChange) {
      return isChangingPw ? null : '/change-password';
    }

    // Password is fine but still trying to visit /change-password
    // → redirect to correct shell
    if (isChangingPw) {
      final roles = await _authService.getUserRoles(session.user.id);
      return _shellRoute(roles);
    }

    // Already logged in, trying to visit /login → redirect to shell
    if (isLoggingIn) {
      final roles = await _authService.getUserRoles(session.user.id);
      return _shellRoute(roles);
    }

    return null; // all good, let them through
  },
  routes: [
    GoRoute(
      path: '/login', 
      builder: (context, state) => const LoginScreen()
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    
    // Admin routes — wrapped in shell (sidebar layout)
    ShellRoute(
      builder: (context, state, child) => AdminShell(child: child),
      routes: [
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/admin/offices',
          builder: (context, state) => const OfficesScreen(),
        ),
        GoRoute(
          path: '/admin/prerequisites',
          builder: (context, state) => const PrerequisitesScreen(),
        ),
        GoRoute(
          path: '/admin/staff',
          builder: (context, state) => const StaffScreen(),
        ),
        GoRoute(
          path: '/admin/students',
          builder: (context, state) => const StudentsScreen(),
        ),
      ],
    ),

    // Student routes — wrapped in shell (bottom nav layout) later
    GoRoute(
      path: '/student/home',
      builder: (context, state) => const StudentHomeScreen(),
    ),
  ],
);

String _shellRoute(List<String> roles) {
  if (roles.contains('super_admin') || roles.contains('office_staff')) {
    return '/admin/dashboard';
  } else if (roles.contains('student')) {
    return '/student/home';
  }
  return '/login';
}