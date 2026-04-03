import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../repositories/user_profile_repository.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey               = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmController     = TextEditingController();
  final _profileRepo           = UserProfileRepository();
  final _authService           = AuthService();

  bool    _isLoading       = false;
  bool    _obscureNew      = true;
  bool    _obscureConfirm  = true;
  String? _errorMessage;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('No active session.');

      // 1. Update password in Supabase Auth
      final response = await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text.trim()),
      );

      if (response.user == null) throw Exception('Password update failed.');

      // 2. Mark password changed + set account to active
      await _profileRepo.markPasswordChanged(user.id);

      if (!mounted) return;

      // 3. Redirect to correct dashboard based on role
      final roles = await _authService.getUserRoles(user.id);

      if (!mounted) return;

      if (roles.contains('super_admin') || roles.contains('office_staff')) {
        context.go('/admin/dashboard');
      } else if (roles.contains('student')) {
        context.go('/student/home');
      } else {
        context.go('/login');
      }

    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset:     const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Container(
                  width:  56,
                  height: 56,
                  decoration: BoxDecoration(
                    color:        AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lock_reset_outlined,
                    color: AppTheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Set a New Password',
                  style: TextStyle(
                    fontSize:   24,
                    fontWeight: FontWeight.bold,
                    color:      AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your account requires a password change before you '
                  'can continue. Choose a strong password you haven\'t '
                  'used before.',
                  style: TextStyle(
                    color:    AppTheme.textSecondary,
                    fontSize: 14,
                    height:   1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // New password
                TextFormField(
                  controller:   _newPasswordController,
                  obscureText:  _obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Password is required';
                    }
                    if (v.trim().length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm password
                TextFormField(
                  controller:  _confirmController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText:  'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (v.trim() != _newPasswordController.text.trim()) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleSubmit(),
                ),
                const SizedBox(height: 8),

                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color:    AppTheme.danger,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 8),

                // Submit button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          width:  20,
                          height: 20,
                          child:  CircularProgressIndicator(
                            color:       AppTheme.surface,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Set Password & Continue'),
                ),

                const SizedBox(height: 16),

                // Sign out option — in case they logged in by mistake
                Center(
                  child: TextButton(
                    onPressed: () async {
                      await AuthService().signOut();
                      if (context.mounted) context.go('/login');
                    },
                    child: const Text(
                      'Sign out',
                      style: TextStyle(
                        color:    AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}