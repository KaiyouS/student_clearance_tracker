import 'package:go_router/go_router.dart';
import 'package:student_clearance_tracker/features/staff/shell/staff_shell.dart';
import 'package:student_clearance_tracker/features/staff/clearance/view/staff_clearance_screen.dart';

final List<RouteBase> staffRoutes = [
  ShellRoute(
    builder: (context, state, child) => StaffShell(child: child),
    routes: [
      GoRoute(
        path: '/staff/clearance',
        builder: (context, state) => const StaffClearanceScreen(),
      ),
    ],
  ),
];