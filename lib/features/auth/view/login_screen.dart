import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_clearance_tracker/core/repositories/user_profile_repository.dart';
import 'package:student_clearance_tracker/features/staff/shell/viewmodel/staff_shell_viewmodel.dart';
import 'package:student_clearance_tracker/features/student/shell/viewmodel/student_shell_viewmodel.dart';
import 'package:student_clearance_tracker/core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _profileRepo = UserProfileRepository();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final user = response.user;
      if (user == null) throw Exception('Login failed.');

      final roles = await _authService.getUserRoles(user.id);
      final profile = await _profileRepo.getById(user.id);

      if (!mounted) return;

      if (roles.contains('office_staff')) {
        if (context.mounted) {
          await context.read<StaffShellViewModel>().loadProfile(user.id);
        }
      }

      // Account status checks
      if (profile == null) {
        setState(() => _errorMessage = 'Account profile not found.');
        await _authService.signOut();
        return;
      }

      if (profile.isLocked) {
        setState(
          () => _errorMessage =
              'Your account has been locked. Please contact the administrator.',
        );
        await _authService.signOut();
        return;
      }

      if (profile.isInactive) {
        setState(
          () => _errorMessage =
              'Your account is inactive. Please contact the administrator.',
        );
        await _authService.signOut();
        return;
      }

      // Force password change on first login
      if (profile.needsPasswordChange) {
        if (!mounted) return;
        context.go('/change-password');
        return;
      }

      if (roles.contains('student')) {
        if (!mounted) return;
        await context.read<StudentShellViewModel>().loadData(user.id);
      }

      // Route based on role
      if (!mounted) return;
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Student Clearance Tracker',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to your account',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
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
                    style: TextStyle(
                      color: AppColors.of(context).danger,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.surface,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Sign In',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
