import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';

class AuthService {
  // Sign in with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // Get the roles of a user from user_roles table
  Future<List<String>> getUserRoles(String userId) async {
    final response = await supabase
        .from('user_roles')
        .select('role')
        .eq('user_id', userId);

    return List<String>.from(response.map((row) => row['role']));
  }

  // Get the currently logged in user
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}