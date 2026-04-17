import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student_clearance_tracker/core/services/auth_service.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';

class ProfileActionsSection extends StatelessWidget {
  const ProfileActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/update-password'),
            icon: const Icon(Icons.lock_reset_outlined),
            label: const Text('Change Password'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: Icon(Icons.logout, color: AppColors.of(context).danger),
            label: Text(
              'Sign Out',
              style: TextStyle(color: AppColors.of(context).danger),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.of(context).danger),
            ),
          ),
        ),
      ],
    );
  }
}
