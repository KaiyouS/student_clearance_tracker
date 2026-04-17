import 'package:flutter/material.dart';

class StepDetailRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const StepDetailRow({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 12, color: color)),
        ),
        Icon(
          Icons.chevron_right,
          size: 16,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.65),
        ),
      ],
    );
  }
}
