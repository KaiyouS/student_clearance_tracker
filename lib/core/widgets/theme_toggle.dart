import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/providers/theme_provider.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<ThemeProvider, ThemeMode>(
      (p) => p.themeMode,
    );
    // TODO: do something about the button segment's label wrapping
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.light,
          icon: PhosphorIcon(PhosphorIconsLight.sun, size: 16),
          // label: Text('Light', style: TextStyle(fontSize: 12)),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: PhosphorIcon(PhosphorIconsLight.moon, size: 16),
          // label: Text('Dark', style: TextStyle(fontSize: 12)),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          icon: PhosphorIcon(PhosphorIconsLight.circleHalf, size: 16),
          // label: Text('System', style: TextStyle(fontSize: 12)),
        ),
      ],
      selected: {themeMode},
      onSelectionChanged: (values) =>
          context.read<ThemeProvider>().setTheme(values.first),
      style: ButtonStyle(visualDensity: VisualDensity.compact),
    );
  }
}
