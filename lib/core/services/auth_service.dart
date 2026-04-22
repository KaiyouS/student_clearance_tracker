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
  static String? _googleInitializedDomain;

  Future<void> _ensureGoogleInitialized() async {
    final targetDomain = AppConfig.allowNonEduEmails ? null : 'addu.edu.ph';
    
    if (_googleInitializedDomain == (targetDomain ?? '')) return;

    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleWebClientId,
      hostedDomain: targetDomain,
    );
    _googleInitializedDomain = targetDomain ?? '';
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

    // Force account selection to avoid silently reusing a previous non-edu account.
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore failures and continue with interactive auth.
    }

    GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      throw AuthException(_googleErrorMessage(e));
    }
    final googleEmail = account.email.trim();
    if (!isAllowedStudentEmail(googleEmail)) {
      await supabase.auth.signOut();
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Ignore cleanup failures.
      }
      throw AuthException('Only institutional (.edu) email accounts are allowed.');
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

  String _googleErrorMessage(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Google sign in was cancelled.';
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google sign in is misconfigured. Check your Google OAuth app configuration (client ID, SHA-1/SHA-256, and consent screen user type).';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google sign in UI is unavailable on this device right now.';
      case GoogleSignInExceptionCode.interrupted:
        return 'Google sign in was interrupted. Please try again.';
      case GoogleSignInExceptionCode.userMismatch:
        return 'Google account mismatch detected. Please try again.';
      case GoogleSignInExceptionCode.unknownError:
        return error.description?.trim().isNotEmpty == true
            ? error.description!.trim()
            : 'Google sign in failed. Please try again.';
    }
  }

  bool isAllowedStudentEmail(String? email) {
    if (AppConfig.allowNonEduEmails) return true;
    if (email == null) return false;
    // Check the domain portion only, not the full email string
    final domain = email.split('@').last.toLowerCase();
    return domain.endsWith('.edu') || domain.contains('.edu.');
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (_googleInitializedDomain != null) {
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
