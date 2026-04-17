import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_colors.dart';
import 'package:student_clearance_tracker/features/auth/viewmodel/student_onboarding_viewmodel.dart';

class StudentOnboardingScreen extends StatelessWidget {
  const StudentOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentOnboardingViewModel()..initialize(),
      child: const _StudentOnboardingView(),
    );
  }
}

class _StudentOnboardingView extends StatefulWidget {
  const _StudentOnboardingView();

  @override
  State<_StudentOnboardingView> createState() => _StudentOnboardingViewState();
}

class _StudentOnboardingViewState extends State<_StudentOnboardingView> {
  final _formKey = GlobalKey<FormState>();
  final _studentNoController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  int? _programId;
  int? _yearLevel;

  @override
  void dispose() {
    _studentNoController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<StudentOnboardingViewModel>();
    final destination = await vm.completeOnboarding(
      studentNo: _studentNoController.text.trim(),
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim().isEmpty
          ? null
          : _middleNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      programId: _programId,
      yearLevel: _yearLevel,
    );

    if (destination != null && mounted) {
      context.go(destination);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentOnboardingViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 620,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.contentSecondary(
                  context,
                ).withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Student Onboarding',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete your student profile to continue.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (vm.currentEmail != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        vm.currentEmail!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _studentNoController,
                    decoration: const InputDecoration(
                      labelText: 'Student Number',
                      hintText: 'e.g. 2021-00001',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Student number is required.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _middleNameController,
                          decoration: const InputDecoration(
                            labelText: 'Middle Name',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Last name is required.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    initialValue: _programId,
                    decoration: const InputDecoration(
                      labelText: 'Program',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    hint: Text(
                      vm.loadingPrograms
                          ? 'Loading programs...'
                          : 'Select program',
                    ),
                    items: vm.programs
                        .map(
                          (program) => DropdownMenuItem<int>(
                            value: program.id,
                            child: Text(program.name),
                          ),
                        )
                        .toList(),
                    onChanged: vm.loadingPrograms
                        ? null
                        : (value) => setState(() => _programId = value),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    initialValue: _yearLevel,
                    decoration: const InputDecoration(
                      labelText: 'Year Level',
                      prefixIcon: Icon(Icons.stairs_outlined),
                    ),
                    hint: const Text('Select year level'),
                    items: [1, 2, 3, 4, 5]
                        .map(
                          (year) => DropdownMenuItem<int>(
                            value: year,
                            child: Text('Year $year'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _yearLevel = value),
                  ),
                  const SizedBox(height: 10),
                  if (vm.errorMessage != null)
                    Text(
                      vm.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: vm.submitting ? null : _submit,
                    child: vm.submitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          )
                        : const Text('Complete Setup'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
