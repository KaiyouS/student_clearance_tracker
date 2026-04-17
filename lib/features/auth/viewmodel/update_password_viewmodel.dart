import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_clearance_tracker/main.dart';
import 'package:student_clearance_tracker/core/services/auth_service.dart';

class UpdatePasswordViewModel extends ChangeNotifier {
  final _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = _authService.getCurrentUser();
      final email = user?.email;

      if (user == null || email == null) throw Exception('No active session.');

      // Step 1: Re-authenticate to verify identity
      final reauth = await supabase.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );

      if (reauth.user == null) {
        throw const AuthException('Current password is incorrect.');
      }

      // Step 2: Update to new password
      final response = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) throw Exception('Password update failed.');

      return true; // Success
    } on AuthException catch (e) {
      errorMessage = e.message == 'Invalid login credentials'
          ? 'Current password is incorrect.'
          : e.message;
      return false;
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}