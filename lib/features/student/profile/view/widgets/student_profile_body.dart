import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/models/student.dart';
import 'package:student_clearance_tracker/core/models/user_profile.dart';
import 'package:student_clearance_tracker/features/student/profile/view/widgets/profile_account_section.dart';
import 'package:student_clearance_tracker/features/student/profile/view/widgets/profile_actions_section.dart';
import 'package:student_clearance_tracker/features/student/profile/view/widgets/profile_avatar_block.dart';
import 'package:student_clearance_tracker/features/student/profile/view/widgets/profile_info_card.dart';
import 'package:student_clearance_tracker/features/student/profile/view/widgets/profile_info_row.dart';
import 'package:student_clearance_tracker/features/student/profile/view/widgets/profile_section_title.dart';
import 'package:student_clearance_tracker/features/student/shell/viewmodel/student_shell_viewmodel.dart';
import 'package:student_clearance_tracker/main.dart';

class StudentProfileBody extends StatelessWidget {
  const StudentProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<StudentShellViewModel, bool>(
      (p) => p.isLoading,
    );
    final profile = context.select<StudentShellViewModel, UserProfile?>(
      (p) => p.profile,
    );
    final student = context.select<StudentShellViewModel, Student?>(
      (p) => p.student,
    );

    if (isLoading || profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => context.read<StudentShellViewModel>().loadData(
        supabase.auth.currentUser!.id,
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileAvatarBlock(profile: profile, student: student),
            const SizedBox(height: 28),
            const ProfileSectionTitle(title: 'Student Information'),
            const SizedBox(height: 8),
            ProfileInfoCard(
              children: [
                ProfileInfoRow(label: 'Full Name', value: profile.fullName),
                ProfileInfoRow(
                  label: 'Student No.',
                  value: student?.studentNo ?? '—',
                ),
                ProfileInfoRow(
                  label: 'Program',
                  value: student?.programName ?? '—',
                ),
                ProfileInfoRow(
                  label: 'School',
                  value: student?.schoolName ?? '—',
                ),
                ProfileInfoRow(
                  label: 'Year Level',
                  value: student?.yearLevel != null
                      ? 'Year ${student!.yearLevel}'
                      : '—',
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            ProfileAccountSection(profile: profile),
            const SizedBox(height: 16),
            const ProfileActionsSection(),
          ],
        ),
      ),
    );
  }
}
