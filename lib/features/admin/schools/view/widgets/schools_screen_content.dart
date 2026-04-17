import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/admin/schools/view/widgets/schools_body.dart';
import 'package:student_clearance_tracker/features/admin/schools/viewmodel/schools_viewmodel.dart';

class SchoolsScreenContent extends StatelessWidget {
  const SchoolsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SchoolsViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schools & Programs',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage schools and the programs they offer.',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.65),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (vm.isSaving)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const Expanded(child: SchoolsBody()),
          ],
        ),
      ),
    );
  }
}
