import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/theme/app_dimensions.dart';

class ChangePasswordCard extends StatelessWidget {
  final Widget child;

  const ChangePasswordCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600;

    return Container(
      width: isMobile ? double.infinity : 440,
      
      constraints: BoxConstraints(
        minHeight: isMobile ? size.height : 0, 
      ),
      
      alignment: isMobile ? Alignment.center : null,
      
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(isMobile ? 0 : AppDimensions.radiusLg),
        boxShadow: isMobile
            ? null
            : [
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