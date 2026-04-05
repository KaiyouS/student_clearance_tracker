import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/student_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/account_status_badge.dart';
import '../../core/widgets/theme_toggle.dart';
import '../../main.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final profile  = provider.profile;
    final student  = provider.student;
    final isDark   = Theme.of(context).brightness == Brightness.dark;

    if (provider.isLoading || profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () =>
          provider.loadData(supabase.auth.currentUser!.id),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + name
            Center(
              child: Column(
                children: [
                  // Avatar circle with initials
                  Container(
                    width:  80,
                    height: 80,
                    decoration: BoxDecoration(
                      color:  AppTheme.primary.withValues(alpha: 0.15),
                      shape:  BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _initials(profile.fullName),
                        style: const TextStyle(
                          fontSize:   28,
                          fontWeight: FontWeight.bold,
                          color:      AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.fullName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  if (student != null)
                    Text(
                      student.studentNo,
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 8),
                  AccountStatusBadge(status: profile.accountStatus),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Info section
            Text(
              'Student Information',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            _InfoCard(
              children: [
                _InfoRow(
                  label: 'Full Name',
                  value: profile.fullName,
                ),
                _InfoRow(
                  label: 'Student No.',
                  value: student?.studentNo ?? '—',
                ),
                _InfoRow(
                  label: 'Program',
                  value: student?.programName ?? '—',
                ),
                _InfoRow(
                  label: 'School',
                  value: student?.schoolName ?? '—',
                ),
                _InfoRow(
                  label: 'Year Level',
                  value: student?.yearLevel != null
                      ? 'Year ${student!.yearLevel}'
                      : '—',
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Account section
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            _InfoCard(
              children: [
                _InfoRow(
                  label: 'Email',
                  value: supabase.auth.currentUser?.email ?? '—',
                ),
                _InfoRow(
                  label: 'Status',
                  value: profile.accountStatus,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(
                          'Theme',
                          style: TextStyle(
                            fontSize: 13,
                            color:    isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      const Expanded(child: ThemeToggle()),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Change password
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/change-password'),
                icon:  const Icon(Icons.lock_reset_outlined),
                label: const Text('Change Password'),
              ),
            ),
            const SizedBox(height: 12),

            // Sign out
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await AuthService().signOut();
                  if (context.mounted) context.go('/login');
                },
                icon:  const Icon(
                  Icons.logout,
                  color: AppTheme.danger,
                ),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: AppTheme.danger),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.danger),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

// ── Info card ─────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(children: children),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool   isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color:    isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color:  Theme.of(context).dividerColor,
          ),
      ],
    );
  }
}