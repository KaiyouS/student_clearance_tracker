import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_dimensions.dart';
import 'package:student_clearance_tracker/core/theme/app_text_styles.dart';

class UpdatePasswordActions extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;

  const UpdatePasswordActions({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(
              top: AppDimensions.sm,
              bottom: AppDimensions.xs,
            ),
            child: Text(
              errorMessage!,
              style: AppTextStyles.bodySm.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: AppDimensions.md),
        ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Update Password'),
        ),
      ],
    );
  }
}
