import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_dimensions.dart';
import 'package:student_clearance_tracker/features/auth/view/widgets/password_input_field.dart';
import 'package:student_clearance_tracker/features/auth/view/widgets/update_password/update_password_actions.dart';
import 'package:student_clearance_tracker/features/auth/view/widgets/update_password/update_password_card.dart';
import 'package:student_clearance_tracker/features/auth/view/widgets/update_password/update_password_header.dart';
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
  State<_UpdatePasswordScreenContent> createState() =>
      _UpdatePasswordScreenContentState();
}

class _UpdatePasswordScreenContentState
    extends State<_UpdatePasswordScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();

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
        SnackBar(
          content: const Text('Password updated successfully.'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
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
        leading: IconButton(
          icon: const PhosphorIcon(PhosphorIconsLight.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: UpdatePasswordCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const UpdatePasswordHeader(),
              const SizedBox(height: AppDimensions.lg),
              PasswordInputField(
                controller: _currentPasswordController,
                labelText: 'Current Password',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Current password is required'
                    : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDimensions.md),
              const Divider(),
              const SizedBox(height: AppDimensions.md),
              PasswordInputField(
                controller: _newPasswordController,
                labelText: 'New Password',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'New password is required';
                  }
                  if (v.trim().length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  if (v.trim() == _currentPasswordController.text.trim()) {
                    return 'New password must differ from current password';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                prefixIcon: PhosphorIconsLight.key,
              ),
              const SizedBox(height: AppDimensions.md),
              PasswordInputField(
                controller: _confirmController,
                labelText: 'Confirm New Password',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (v.trim() != _newPasswordController.text.trim()) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleSubmit(),
              ),
              UpdatePasswordActions(
                isLoading: vm.isLoading,
                errorMessage: vm.errorMessage,
                onSubmit: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
