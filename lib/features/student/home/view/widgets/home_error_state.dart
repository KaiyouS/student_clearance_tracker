import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:student_clearance_tracker/features/student/shell/viewmodel/student_shell_viewmodel.dart';
import 'package:student_clearance_tracker/main.dart';

class HomeErrorState extends StatelessWidget {
  const HomeErrorState({super.key});

  @override
  Widget build(BuildContext context) {
    final error = context.select<StudentShellViewModel, String?>(
      (p) => p.error,
    );

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(
            PhosphorIconsLight.warningCircle,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            error ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.read<StudentShellViewModel>().loadData(
              supabase.auth.currentUser!.id,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
