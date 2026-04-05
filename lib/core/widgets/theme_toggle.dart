import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    // TODO: do something about the button segment's label wrapping
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.light,
          icon:  Icon(Icons.light_mode_outlined, size: 16),
          // label: Text('Light', style: TextStyle(fontSize: 12)),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon:  Icon(Icons.dark_mode_outlined, size: 16),
          // label: Text('Dark', style: TextStyle(fontSize: 12)),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          icon:  Icon(Icons.brightness_auto_outlined, size: 16),
          // label: Text('System', style: TextStyle(fontSize: 12)),
        ),
      ],
      selected:          {provider.themeMode},
      onSelectionChanged: (values) =>
          provider.setTheme(values.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}