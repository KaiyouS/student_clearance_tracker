import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_clearance_tracker/core/constants/app_config.dart';
import 'package:student_clearance_tracker/main.dart';

class GoogleAuthSignInResult {
  final AuthResponse authResponse;
  final String googleEmail;

  const GoogleAuthSignInResult({
    required this.authResponse,
    required this.googleEmail,
  });
}

class AuthService {
  static bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;

    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleWebClientId,
      hostedDomain: AppConfig.allowNonAdduEmails ? null : 'addu.edu.ph',
    );
    _googleInitialized = true;
  }

  // Sign in with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with Google and exchange token with Supabase
  Future<GoogleAuthSignInResult> signInWithGoogle() async {
    await _ensureGoogleInitialized();

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw AuthException('Google sign in is not available on this platform.');
    }

    // Force account selection to avoid silently reusing a previous non-ADdU account.
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore failures and continue with interactive auth.
    }

    final account = await GoogleSignIn.instance.authenticate();
    final googleEmail = account.email.trim();
    if (!isAllowedStudentEmail(googleEmail)) {
      await supabase.auth.signOut();
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Ignore cleanup failures.
      }
      throw AuthException('Use your addu.edu.ph Google account to continue.');
    }

    final auth = account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw AuthException('Google sign in did not return an ID token.');
    }

    final authResponse = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    return GoogleAuthSignInResult(
      authResponse: authResponse,
      googleEmail: googleEmail,
    );
  }

  bool isAllowedStudentEmail(String? email) {
    if (AppConfig.allowNonAdduEmails) return true;
    if (email == null) return false;
    return RegExp(
      r'^[^@\s]+@addu\.edu\.ph$',
      caseSensitive: false,
    ).hasMatch(email.trim());
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (_googleInitialized) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (_) {
      // Ignore Google sign-out failures and still sign out from Supabase.
    }
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
