import 'package:go_router/go_router.dart';
import 'admin/screens/admin_clearance_screen.dart';
import 'admin/screens/office_requirements_screen.dart';
import 'core/repositories/user_profile_repository.dart';
import 'core/screens/change_password_screen.dart';
import 'core/screens/login_screen.dart';
import 'core/services/auth_service.dart';
import 'admin/shell/admin_shell.dart';
import 'admin/screens/academic_periods_screen.dart';
import 'admin/screens/dashboard_screen.dart';
import 'admin/screens/offices_screen.dart';
import 'admin/screens/prerequisites_screen.dart';
import 'admin/screens/schools_screen.dart';
import 'admin/screens/staff_screen.dart';
import 'admin/screens/students_screen.dart';
import 'student/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'core/providers/staff_provider.dart';
import 'staff/shell/staff_shell.dart';
import 'staff/screens/staff_clearance_screen.dart';
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
    
    final isAdminRoute = location.startsWith('/admin');
    final isStaffRoute = location.startsWith('/staff');

    if (isAdminRoute) {
      final roles = await _authService.getUserRoles(session.user.id);
      if (!roles.contains('super_admin')) return '/staff/clearance';
    }

    if (isStaffRoute) {
      final roles = await _authService.getUserRoles(session.user.id);
      if (!roles.contains('office_staff') && !roles.contains('super_admin')) {
        return '/login';
      }
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
        GoRoute(
          path: '/admin/schools',
          builder: (context, state) => const SchoolsScreen(),
        ),
        GoRoute(
          path: '/admin/periods',
          builder: (context, state) => const AcademicPeriodsScreen(),
        ),
        GoRoute(
          path: '/admin/requirements',
          builder: (context, state) => const OfficeRequirementsScreen(),
        ),
        GoRoute(
          path: '/admin/clearance',
          builder: (context, state) => const AdminClearanceScreen(),
        ),
      ],
    ),
    
    // Staff routes
    ShellRoute(
      builder: (context, state, child) => StaffShell(child: child),
      routes: [
        GoRoute(
          path:    '/staff/clearance',
          builder: (context, state) => const StaffClearanceScreen(),
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
  if (roles.contains('super_admin'))  return '/admin/dashboard';
  if (roles.contains('office_staff')) return '/staff/clearance';
  if (roles.contains('student'))      return '/student/home';
  return '/login';
}