import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';

class LoginActions extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSignIn;

  const LoginActions({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: isLoading ? null : onSignIn,
          child: isLoading
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
                    color: AppColors.darkTextPrimary,
                  ),
                ),
        ),
      ],
    );
  }
}
