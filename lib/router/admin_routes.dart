import 'package:go_router/go_router.dart';
import 'package:student_clearance_tracker/features/admin/shell/admin_shell.dart';
import 'package:student_clearance_tracker/features/admin/dashboard/view/dashboard_screen.dart';
import 'package:student_clearance_tracker/features/admin/offices/view/offices_screen.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/view/prerequisites_screen.dart';
import 'package:student_clearance_tracker/features/admin/schools/view/schools_screen.dart';
import 'package:student_clearance_tracker/features/admin/staff/view/staff_screen.dart';
import 'package:student_clearance_tracker/features/admin/students/view/students_screen.dart';
import 'package:student_clearance_tracker/features/admin/periods/view/academic_periods_screen.dart';
import 'package:student_clearance_tracker/features/admin/requirements/view/office_requirements_screen.dart';
import 'package:student_clearance_tracker/features/admin/clearance/view/admin_clearance_screen.dart';

final List<RouteBase> adminRoutes = [
  ShellRoute(
    builder: (context, state, child) => AdminShell(child: child),
    routes: [
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/offices',
        builder: (context, state) => const OfficesScreen(),
      ),
      GoRoute(
        path: '/admin/prerequisites',
        builder: (context, state) => const PrerequisitesScreen(),
      ),
      GoRoute(
        path: '/admin/staff',
        builder: (context, state) => const StaffScreen(),
      ),
      GoRoute(
        path: '/admin/students',
        builder: (context, state) => const StudentsScreen(),
      ),
      GoRoute(
        path: '/admin/schools',
        builder: (context, state) => const SchoolsScreen(),
      ),
      GoRoute(
        path: '/admin/periods',
        builder: (context, state) => const AcademicPeriodsScreen(),
      ),
      GoRoute(
        path: '/admin/requirements',
        builder: (context, state) => const OfficeRequirementsScreen(),
      ),
      GoRoute(
        path: '/admin/clearance',
        builder: (context, state) => const AdminClearanceScreen(),
      ),
    ],
  ),
];