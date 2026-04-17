import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_clearance_tracker/main.dart';
import 'package:student_clearance_tracker/core/repositories/user_profile_repository.dart';
import 'package:student_clearance_tracker/core/services/auth_service.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final _profileRepo = UserProfileRepository();
  final _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  Future<String?> submitNewPassword(String newPassword) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = _authService.getCurrentUser();
      if (user == null) throw Exception('No active session.');

      // Update password
      final response = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      if (response.user == null) throw Exception('Password update failed.');

      // Mark password changed + set account to active
      await _profileRepo.markPasswordChanged(user.id);

      // Determine route based on roles
      final roles = await _authService.getUserRoles(user.id);
      
      if (roles.contains('super_admin') || roles.contains('office_staff')) {
        return '/admin/dashboard';
      } else if (roles.contains('student')) {
        return '/student/home';
      } else {
        return '/login';
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