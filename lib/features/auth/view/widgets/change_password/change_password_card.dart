import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_dimensions.dart';

class ChangePasswordCard extends StatelessWidget {
  final Widget child;

  const ChangePasswordCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 440,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
