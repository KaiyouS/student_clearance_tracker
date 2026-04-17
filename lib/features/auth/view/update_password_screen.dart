import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/auth/viewmodel/update_password_viewmodel.dart';

class UpdatePasswordScreen extends StatelessWidget {
  const UpdatePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdatePasswordViewModel(),
      child: const _UpdatePasswordScreenContent(),
    );
  }
}

class _UpdatePasswordScreenContent extends StatefulWidget {
  const _UpdatePasswordScreenContent();

  @override
  State<_UpdatePasswordScreenContent> createState() => _UpdatePasswordScreenContentState();
}

class _UpdatePasswordScreenContentState extends State<_UpdatePasswordScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<UpdatePasswordViewModel>();
    final success = await vm.updatePassword(
      _currentPasswordController.text.trim(),
      _newPasswordController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Password updated successfully.'), backgroundColor: AppColors.of(context).success),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UpdatePasswordViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Change Password'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.of(context).info.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.of(context).info.withValues(alpha: 0.2))),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.of(context).info),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Enter your current password to confirm your identity, then choose a new password.', style: TextStyle(fontSize: 13, color: AppColors.of(context).info))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(icon: Icon(_obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Current password is required' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock_reset_outlined),
                  suffixIcon: IconButton(icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscureNew = !_obscureNew)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'New password is required';
                  if (v.trim().length < 8) return 'Password must be at least 8 characters';
                  if (v.trim() == _currentPasswordController.text.trim()) return 'New password must differ from current password';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please confirm your new password';
                  if (v.trim() != _newPasswordController.text.trim()) return 'Passwords do not match';
                  return null;
                },
                onFieldSubmitted: (_) => _handleSubmit(),
              ),
              const SizedBox(height: 8),
              if (vm.errorMessage != null)
                Padding(padding: const EdgeInsets.only(top: 8, bottom: 4), child: Text(vm.errorMessage!, style: TextStyle(color: AppColors.of(context).danger, fontSize: 13), textAlign: TextAlign.center)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: vm.isLoading ? null : _handleSubmit,
                child: vm.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Update Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}