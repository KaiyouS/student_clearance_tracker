import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/account_status_badge.dart';

class AccountStatusMenu extends StatelessWidget {
  final String   currentStatus;
  final Function(String) onStatusChanged;

  const AccountStatusMenu({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  static const _allStatuses = ['active', 'inactive', 'locked', 'pending'];

  Color _colorFor(String status) => switch (status) {
    'active'   => AppTheme.statusSigned,
    'inactive' => AppTheme.textSecondary,
    'locked'   => AppTheme.danger,
    'pending'  => AppTheme.statusPending,
    _          => AppTheme.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip:      'Change account status',
      // Show the current status as the button itself
      child: AccountStatusBadge(status: currentStatus),
      itemBuilder: (_) => _allStatuses
          .where((s) => s != currentStatus) // don't show current status
          .map((s) => PopupMenuItem<String>(
                value: s,
                child: Row(
                  children: [
                    Icon(
                      _iconFor(s),
                      size:  16,
                      color: _colorFor(s),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Set to ${s[0].toUpperCase()}${s.substring(1)}',
                      style: TextStyle(
                        color: _colorFor(s),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
      onSelected: onStatusChanged,
    );
  }

  IconData _iconFor(String status) => switch (status) {
    'active'   => Icons.check_circle_outline,
    'inactive' => Icons.pause_circle_outline,
    'locked'   => Icons.lock_outline,
    'pending'  => Icons.hourglass_empty_outlined,
    _          => Icons.help_outline,
  };
}