import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/staff/clearance/view/widgets/staff_clearance_screen_content.dart';
import 'package:student_clearance_tracker/features/staff/shell/viewmodel/staff_shell_viewmodel.dart';
import 'package:student_clearance_tracker/features/staff/clearance/viewmodel/staff_clearance_viewmodel.dart';

// We wrap the UI in a Provider so it gets a fresh ViewModel
class StaffClearanceScreen extends StatelessWidget {
  const StaffClearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StaffClearanceViewModel(),
      child: const _StaffClearanceScreenHost(),
    );
  }
}

class _StaffClearanceScreenHost extends StatefulWidget {
  const _StaffClearanceScreenHost();

  @override
  State<_StaffClearanceScreenHost> createState() =>
      _StaffClearanceScreenHostState();
}

class _StaffClearanceScreenHostState extends State<_StaffClearanceScreenHost>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _lastOfficeId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Listen to the global StaffShellViewModel to see if the office changed in the shell
    final currentOfficeId = context
        .watch<StaffShellViewModel>()
        .selectedOffice
        ?.id;
    final viewModel = context.read<StaffClearanceViewModel>();

    if (currentOfficeId != _lastOfficeId) {
      _lastOfficeId = currentOfficeId;

      // Schedule the data fetch to happen immediately AFTER the build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return; // Always safe to check

        if (viewModel.isLoading) {
          viewModel.loadPeriodThenSteps(currentOfficeId);
        } else {
          viewModel.loadSteps(currentOfficeId);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StaffClearanceScreenContent(tabController: _tabController);
  }
}
