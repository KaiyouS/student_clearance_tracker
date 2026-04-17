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
      final user = response.user;
      
      if (user == null) throw Exception('Login failed.');

      final profile = await _profileRepo.getById(user.id);

      // Account status checks
      if (profile == null) {
        await _authService.signOut();
        throw Exception('Account profile not found.');
      }

      if (profile.isLocked) {
        await _authService.signOut();
        throw Exception('Your account has been locked. Please contact the administrator.');
      }

      if (profile.isInactive) {
        await _authService.signOut();
        throw Exception('Your account is inactive. Please contact the administrator.');
      }

      // Force password change on first login
      if (profile.needsPasswordChange) {
        return '/change-password';
      }

      // Route based on role
      final roles = await _authService.getUserRoles(user.id);
      
      if (roles.contains('super_admin') || roles.contains('office_staff')) {
        return '/admin/dashboard';
      } else if (roles.contains('student')) {
        return '/student/home';
      } else {
        await _authService.signOut();
        throw Exception('Your account has no assigned role.');
      }
      
    } on AuthException catch (e) {
      errorMessage = e.message;
      return null;
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}