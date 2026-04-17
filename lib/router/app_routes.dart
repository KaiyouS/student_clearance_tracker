import 'package:go_router/go_router.dart';
import 'package:student_clearance_tracker/core/models/user_profile.dart';
import 'package:student_clearance_tracker/core/repositories/user_profile_repository.dart';
import 'package:student_clearance_tracker/features/auth/view/change_password_screen.dart';
import 'package:student_clearance_tracker/features/auth/view/login_screen.dart';
import 'package:student_clearance_tracker/features/auth/view/student_onboarding_screen.dart';
import 'package:student_clearance_tracker/core/services/auth_service.dart';
import 'package:student_clearance_tracker/features/auth/view/update_password_screen.dart';
import 'package:student_clearance_tracker/main.dart';
import 'admin_routes.dart';
import 'staff_routes.dart';
import 'student_routes.dart';

final _authService = AuthService();
const _accessCacheTtl = Duration(seconds: 30);

class _AccessSnapshot {
  final String userId;
  final UserProfile? profile;
  final List<String> roles;
  final DateTime fetchedAt;

  const _AccessSnapshot({
    required this.userId,
    required this.profile,
    required this.roles,
    required this.fetchedAt,
  });

  bool get isFresh => DateTime.now().difference(fetchedAt) < _accessCacheTtl;
}

_AccessSnapshot? _accessSnapshot;

void _clearAccessSnapshot() {
  _accessSnapshot = null;
}

Future<_AccessSnapshot> _getAccessSnapshot(String userId) async {
  final cached = _accessSnapshot;
  if (cached != null && cached.userId == userId && cached.isFresh) {
    return cached;
  }

  final profile = await UserProfileRepository().getById(userId);
  final roles = profile == null
      ? <String>[]
      : await _authService.getUserRoles(userId);

  final snapshot = _AccessSnapshot(
    userId: userId,
    profile: profile,
    roles: roles,
    fetchedAt: DateTime.now(),
  );
  // Never cache null-profile snapshots; onboarding completion should reflect immediately.
  if (profile != null) {
    _accessSnapshot = snapshot;
  } else {
    _clearAccessSnapshot();
  }
  return snapshot;
}

bool _isGoogleUser() {
  final user = supabase.auth.currentUser;
  if (user == null) return false;

  final provider = user.appMetadata['provider'];
  if (provider == 'google') return true;

  return user.identities?.any((identity) => identity.provider == 'google') ??
      false;
}

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final session = supabase.auth.currentSession;
    final location = state.matchedLocation;

    final isLoggingIn = location == '/login';
    final isChangingPw = location == '/change-password';
    final isUpdatingPw = location == '/update-password';
    final isStudentOnboarding = location == '/student/onboarding';

    // Not logged in → always go to login
    if (session == null) {
      _clearAccessSnapshot();
      return isLoggingIn ? null : '/login';
    }

    if (_isGoogleUser() &&
        !_authService.isAllowedStudentEmail(session.user.email)) {
      _clearAccessSnapshot();
      await supabase.auth.signOut();
      return '/login';
    }

    // ── Logged in — load cached access context ──
    final access = await _getAccessSnapshot(session.user.id);
    final profile = access.profile;
    final roles = access.roles;

    // First-time Google student account: route to onboarding until profile is created.
    if (profile == null) {
      if (_isGoogleUser()) {
        return isStudentOnboarding ? null : '/student/onboarding';
      }
      _clearAccessSnapshot();
      await supabase.auth.signOut();
      return '/login';
    }

    // Profile exists already; onboarding page should not be reachable.
    if (isStudentOnboarding) {
      return _shellRoute(roles);
    }

    if (_isGoogleUser() && !roles.contains('student')) {
      _clearAccessSnapshot();
      await supabase.auth.signOut();
      return '/login';
    }

    // Account locked or inactive → back to login
    // (login screen will show the error on next attempt)
    if (profile.isLocked || profile.isInactive) {
      _clearAccessSnapshot();
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
      return _shellRoute(roles);
    }

    // Updating password is allowed for students in profile flow.
    if (isUpdatingPw) return null;

    final isAdminRoute = location.startsWith('/admin');
    final isStaffRoute = location.startsWith('/staff');
    final isStudentRoute = location.startsWith('/student');

    if (isAdminRoute && !roles.contains('super_admin')) {
      return _shellRoute(roles);
    }

    if (isStaffRoute) {
      if (!roles.contains('office_staff') && !roles.contains('super_admin')) {
        return _shellRoute(roles);
      }
    }

    if (isStudentRoute && !roles.contains('student')) {
      return _shellRoute(roles);
    }

    // Already logged in, trying to visit /login → redirect to shell
    if (isLoggingIn) {
      return _shellRoute(roles);
    }

    return null; // all good, let them through
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/student/onboarding',
      builder: (context, state) => const StudentOnboardingScreen(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/update-password',
      builder: (context, state) => const UpdatePasswordScreen(),
    ),

    ...adminRoutes,
    ...staffRoutes,
    ...studentRoutes,
  ],
);

String _shellRoute(List<String> roles) {
  if (roles.contains('super_admin')) return '/admin/dashboard';
  if (roles.contains('office_staff')) return '/staff/clearance';
  if (roles.contains('student')) return '/student/home';
  return '/login';
}
