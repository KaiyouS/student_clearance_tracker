import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/student.dart';
import 'package:student_clearance_tracker/core/models/user_profile.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/widgets/account_status_badge.dart';
import 'package:student_clearance_tracker/features/student/profile/view/widgets/profile_formatters.dart';

class ProfileAvatarBlock extends StatelessWidget {
  final UserProfile profile;
  final Student? student;

  const ProfileAvatarBlock({
    super.key,
    required this.profile,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.of(context).info.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                profileInitials(profile.fullName),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).info,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.fullName,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          if (student != null)
            Text(
              student!.studentNo,
              style: TextStyle(
                color: AppColors.of(context).neutral,
                fontSize: 14,
              ),
            ),
          const SizedBox(height: 8),
          AccountStatusBadge(status: profile.accountStatus),
        ],
      ),
    );
  }
}
