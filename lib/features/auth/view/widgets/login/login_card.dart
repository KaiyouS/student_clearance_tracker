import 'package:flutter/material.dart';

class LoginCard extends StatelessWidget {
  final Widget child;

  const LoginCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    
    return Container(
      width: isMobile ? double.infinity : 400,
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: isMobile
          ? null 
          : BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
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
