import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_dimensions.dart';

class UpdatePasswordCard extends StatelessWidget {
  final Widget child;

  const UpdatePasswordCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: child,
    );
  }
}
