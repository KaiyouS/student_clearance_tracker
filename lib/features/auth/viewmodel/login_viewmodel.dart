import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_clearance_tracker/core/repositories/user_profile_repository.dart';
import 'package:student_clearance_tracker/core/services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final _authService = AuthService();
  final _profileRepo = UserProfileRepository();

  bool isLoading = false;
  String? errorMessage;

  // Returns the route to navigate to on success, or null on failure.
  Future<String?> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signIn(email, password);
      return await _resolveDestinationAfterSignIn(
        response,
        allowGoogleOnboarding: false,
      );
    } on AuthException catch (e) {
      errorMessage = e.message;
      return null;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> loginWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signInWithGoogle();
      return await _resolveDestinationAfterSignIn(
        response,
        allowGoogleOnboarding: true,
      );
    } on AuthException catch (e) {
      errorMessage = e.message;
      return null;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _resolveDestinationAfterSignIn(
    AuthResponse response, {
    required bool allowGoogleOnboarding,
  }) async {
    final user = response.user;
    if (user == null) throw Exception('Login failed.');

    final email = user.email;
    if (allowGoogleOnboarding && !_authService.isAllowedStudentEmail(email)) {
      await _authService.signOut();
      throw AuthException('Use your addu.edu.ph Google account to continue.');
    }

    final profile = await _profileRepo.getById(user.id);

    // First-time Google users go directly to student onboarding.
    if (allowGoogleOnboarding && profile == null) {
      return '/student/onboarding';
    }

    if (profile == null) {
      await _authService.signOut();
      throw Exception('Account profile not found.');
    }

    if (profile.isLocked) {
      await _authService.signOut();
      throw Exception(
        'Your account has been locked. Please contact the administrator.',
      );
    }

    if (profile.isInactive) {
      await _authService.signOut();
      throw Exception(
        'Your account is inactive. Please contact the administrator.',
      );
    }

    if (profile.needsPasswordChange) {
      return '/change-password';
    }

    final roles = await _authService.getUserRoles(user.id);

    if (allowGoogleOnboarding) {
      if (roles.contains('student')) {
        return '/student/home';
      }

      await _authService.signOut();
      throw Exception('Google sign in is only available for student accounts.');
    }

    if (roles.contains('super_admin') || roles.contains('office_staff')) {
      return '/admin/dashboard';
    }
    if (roles.contains('student')) {
      return '/student/home';
    }

    await _authService.signOut();
    throw Exception('Your account has no assigned role.');
  }
}
