import 'package:go_router/go_router.dart';
import 'package:student_clearance_tracker/admin/screens/admin_clearance_screen.dart';
import 'package:student_clearance_tracker/admin/screens/office_requirements_screen.dart';
import 'package:student_clearance_tracker/core/repositories/user_profile_repository.dart';
import 'package:student_clearance_tracker/core/screens/change_password_screen.dart';
import 'package:student_clearance_tracker/core/screens/login_screen.dart';
import 'package:student_clearance_tracker/core/services/auth_service.dart';
import 'package:student_clearance_tracker/admin/shell/admin_shell.dart';
import 'package:student_clearance_tracker/admin/screens/academic_periods_screen.dart';
import 'package:student_clearance_tracker/admin/screens/dashboard_screen.dart';
import 'package:student_clearance_tracker/admin/screens/offices_screen.dart';
import 'package:student_clearance_tracker/admin/screens/prerequisites_screen.dart';
import 'package:student_clearance_tracker/admin/screens/schools_screen.dart';
import 'package:student_clearance_tracker/admin/screens/staff_screen.dart';
import 'package:student_clearance_tracker/admin/screens/students_screen.dart';
import 'package:student_clearance_tracker/student/screens/home_screen.dart';
import 'package:student_clearance_tracker/student/shell/student_shell.dart';
import 'package:student_clearance_tracker/student/screens/student_clearance_screen.dart';
import 'package:student_clearance_tracker/student/screens/student_profile_screen.dart';
import 'package:student_clearance_tracker/student/screens/update_password_screen.dart';
// import 'package:provider/provider.dart';
// import 'core/providers/staff_provider.dart';
import 'package:student_clearance_tracker/staff/shell/staff_shell.dart';
import 'package:student_clearance_tracker/staff/screens/staff_clearance_screen.dart';
import 'package:student_clearance_tracker/main.dart';

final _authService = AuthService();

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final session  = supabase.auth.currentSession;
    final location = state.matchedLocation;

    final isLoggingIn    = location == '/login';
    final isChangingPw   = location == '/change-password';
    final isUpdatingPw   = location == '/update-password'; 

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
    
    // TODO: check the behavior of this code on the admin site (manually visiting the url)
    if (isChangingPw || isUpdatingPw) return null;
    
    // Password is fine but still trying to visit /change-password
    // → redirect to correct shell
    if (isChangingPw) {
      final roles = await _authService.getUserRoles(session.user.id);
      return _shellRoute(roles);
    }
    
    final isAdminRoute = location.startsWith('/admin');
    final isStaffRoute = location.startsWith('/staff');
    final isStudentRoute = location.startsWith('/student');

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
    
    if (isStudentRoute) {
      final roles = await _authService.getUserRoles(session.user.id);
      if (!roles.contains('student')) return '/login';
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
    GoRoute(
      path:    '/update-password',
      builder: (context, state) => const UpdatePasswordScreen(),
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
    
    // Student routes
    ShellRoute(
      builder: (context, state, child) => StudentShell(child: child),
      routes: [
        GoRoute(
          path:    '/student/home',
          builder: (context, state) => const StudentHomeScreen(),
        ),
        GoRoute(
          path:    '/student/clearance',
          builder: (context, state) => const StudentClearanceScreen(),
        ),
        GoRoute(
          path:    '/student/profile',
          builder: (context, state) => const StudentProfileScreen(),
        ),
      ],
    ),
  ],
);

String _shellRoute(List<String> roles) {
  if (roles.contains('super_admin'))  return '/admin/dashboard';
  if (roles.contains('office_staff')) return '/staff/clearance';
  if (roles.contains('student'))      return '/student/home';
  return '/login';
}