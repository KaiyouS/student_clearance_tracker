import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService        = AuthService();

  bool    _isLoading    = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final response = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final user = response.user;
      if (user == null) throw Exception('Login failed.');

      final roles   = await _authService.getUserRoles(user.id);
      final profile = await _authService.getUserProfile(user.id);

      if (!mounted) return;

      // Account status checks
      if (profile == null) {
        setState(() => _errorMessage = 'Account profile not found.');
        await _authService.signOut();
        return;
      }

      if (profile.isLocked) {
        setState(() => _errorMessage = 
          'Your account has been locked. Please contact the administrator.');
        await _authService.signOut();
        return;
      }

      if (profile.isInactive) {
        setState(() => _errorMessage = 
          'Your account is inactive. Please contact the administrator.');
        await _authService.signOut();
        return;
      }

      // Force password change on first login
      if (profile.needsPasswordChange) {
        context.go('/change-password');
        return;
      }

      // Route based on role
      if (roles.contains('super_admin') || roles.contains('office_staff')) {
        context.go('/admin/dashboard');
      } else if (roles.contains('student')) {
        context.go('/student/home');
      } else {
        setState(() => _errorMessage = 'Your account has no assigned role.');
        await _authService.signOut();
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08), // ✅ fixed
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Student Clearance Tracker',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to your account',
                style: TextStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 8),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppTheme.danger,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppTheme.surface,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}