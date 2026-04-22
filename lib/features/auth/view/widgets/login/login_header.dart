import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/constants/app_assets.dart';
import 'package:student_clearance_tracker/core/constants/app_config.dart';
import 'package:student_clearance_tracker/core/theme/app_dimensions.dart';
import 'package:student_clearance_tracker/core/theme/app_text_styles.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(AppAssets.appLogo, fit: BoxFit.cover),
          ),
        ),

        // const SizedBox(height: AppDimensions.sm),
        Text(
          AppConfig.appName,
          style: AppTextStyles.heading1.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'A Student Clearance Tracker App',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.lg)
      ],
    );
  }
}
