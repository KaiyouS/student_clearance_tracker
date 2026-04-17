import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_clearance_tracker/features/staff/shell/viewmodel/staff_shell_viewmodel.dart';
import 'package:student_clearance_tracker/features/student/shell/viewmodel/student_shell_viewmodel.dart';
import 'package:student_clearance_tracker/core/providers/theme_provider.dart';
import 'package:student_clearance_tracker/core/theme/app_theme.dart';
import 'package:student_clearance_tracker/router/app_routes.dart';
import 'package:student_clearance_tracker/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load theme before app renders to avoid flash
  final themeProvider = ThemeProvider();
  await themeProvider.load();

  // Ensure Supabase only initializes once
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    // Already initialized — safe to ignore
    debugPrint('Supabase already initialized: $e');
  }

  runApp(MyApp(themeProvider: themeProvider));
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  const MyApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => StaffShellViewModel()),
        ChangeNotifierProvider(create: (_) => StudentShellViewModel()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp.router(
          title: 'Clearance Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.themeMode,
          routerConfig: router,
        ),
      ),
    );
  }
}
