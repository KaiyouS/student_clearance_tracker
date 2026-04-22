import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/services/auth_service.dart';
import 'package:student_clearance_tracker/core/theme/app_dimensions.dart';
import 'package:student_clearance_tracker/features/auth/view/widgets/change_password/change_password_actions.dart';
import 'package:student_clearance_tracker/features/auth/view/widgets/change_password/change_password_card.dart';
import 'package:student_clearance_tracker/features/auth/view/widgets/change_password/change_password_header.dart';
import 'package:student_clearance_tracker/features/auth/view/widgets/password_input_field.dart';
import 'package:student_clearance_tracker/features/auth/viewmodel/change_password_viewmodel.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangePasswordViewModel(),
      child: const _ChangePasswordScreenContent(),
    );
  }
}

class _ChangePasswordScreenContent extends StatefulWidget {
  const _ChangePasswordScreenContent();

  @override
  State<_ChangePasswordScreenContent> createState() =>
      _ChangePasswordScreenContentState();
}

class _ChangePasswordScreenContentState
    extends State<_ChangePasswordScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<ChangePasswordViewModel>();
    final destination = await vm.submitNewPassword(
      _newPasswordController.text.trim(),
    );

    if (destination != null && mounted) {
      context.go(destination);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChangePasswordViewModel>();
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: ChangePasswordCard(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isKeyboardOpen) ...[
                  const SizedBox(height: AppDimensions.xl),
                  const SizedBox(height: AppDimensions.xl),
                  const SizedBox(height: AppDimensions.xl),
                ],
                if (!isKeyboardOpen) ...[
                  const ChangePasswordHeader(),
                  const SizedBox(height: AppDimensions.xl),
                ],
                PasswordInputField(
                  controller: _newPasswordController,
                  labelText: 'New Password',
                  textInputAction: TextInputAction.next,
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
                const SizedBox(height: AppDimensions.md),
                PasswordInputField(
                  controller: _confirmController,
                  labelText: 'Confirm Password',
                  textInputAction: TextInputAction.done,
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
                const SizedBox(height: AppDimensions.lg),
                ChangePasswordActions(
                  isLoading: vm.isLoading,
                  errorMessage: vm.errorMessage,
                  onSubmit: _handleSubmit,
                  onSignOut: () async {
                    await AuthService().signOut();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
