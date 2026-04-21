import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_dimensions.dart';
import 'package:student_clearance_tracker/core/theme/app_text_styles.dart';

class ChangePasswordActions extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;
  final VoidCallback onSignOut;

  const ChangePasswordActions({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.sm),
            child: Text(
              errorMessage!,
              style: AppTextStyles.bodySm.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: AppDimensions.sm),
        ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.surface,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Set Password & Continue'),
        ),
        const SizedBox(height: AppDimensions.md),
        Center(
          child: TextButton(
            onPressed: onSignOut,
            child: Text(
              'Sign out',
              style: AppTextStyles.bodySm.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
