import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/core/constants/app_assets.dart';
import 'package:student_clearance_tracker/core/theme/app_dimensions.dart';
import 'package:student_clearance_tracker/core/theme/app_text_styles.dart';

class ChangePasswordHeader extends StatelessWidget {
  const ChangePasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(AppAssets.appLogo, fit: BoxFit.cover),
          ),
        ),

        const SizedBox(height: AppDimensions.sm),
        Text(
          'Set a New Password',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          'Your account requires a password change before you can continue. Choose a strong password you haven\'t used before.',
          style: AppTextStyles.bodyMd.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.65),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
