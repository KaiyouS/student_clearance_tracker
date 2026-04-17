import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/core/models/user_profile.dart';
import 'package:student_clearance_tracker/core/widgets/theme_toggle.dart';
import 'package:student_clearance_tracker/features/student/profile/view/widgets/profile_info_card.dart';
import 'package:student_clearance_tracker/features/student/profile/view/widgets/profile_info_row.dart';
import 'package:student_clearance_tracker/features/student/profile/view/widgets/profile_section_title.dart';
import 'package:student_clearance_tracker/main.dart';

class ProfileAccountSection extends StatelessWidget {
  final UserProfile profile;

  const ProfileAccountSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionTitle(title: 'Account'),
        const SizedBox(height: 8),
        ProfileInfoCard(
          children: [
            ProfileInfoRow(
              label: 'Email',
              value: supabase.auth.currentUser?.email ?? '-',
            ),
            ProfileInfoRow(label: 'Status', value: profile.accountStatus),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      'Theme',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.contentSecondary(context),
                      ),
                    ),
                  ),
                  const Expanded(child: ThemeToggle()),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}


