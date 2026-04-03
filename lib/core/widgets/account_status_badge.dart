import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AccountStatusBadge extends StatelessWidget {
  final String status;

  const AccountStatusBadge({super.key, required this.status});

  Color get _color => switch (status) {
    'active'   => AppTheme.statusSigned,
    'inactive' => AppTheme.textSecondary,
    'locked'   => AppTheme.danger,
    'pending'  => AppTheme.statusPending,
    _          => AppTheme.textSecondary,
  };

  IconData get _icon => switch (status) {
    'active'   => Icons.check_circle_outline,
    'inactive' => Icons.pause_circle_outline,
    'locked'   => Icons.lock_outline,
    'pending'  => Icons.hourglass_empty_outlined,
    _          => Icons.help_outline,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:        _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _color),
          const SizedBox(width: 4),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(
              color:      _color,
              fontSize:   12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}