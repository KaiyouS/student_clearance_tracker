import 'package:go_router/go_router.dart';
import 'package:student_clearance_tracker/features/student/shell/student_shell.dart';
import 'package:student_clearance_tracker/features/student/home/view/home_screen.dart';
import 'package:student_clearance_tracker/features/student/clearance/view/student_clearance_screen.dart';
import 'package:student_clearance_tracker/features/student/profile/view/student_profile_screen.dart';

final List<RouteBase> studentRoutes = [
  ShellRoute(
    builder: (context, state, child) => StudentShell(child: child),
    routes: [
      GoRoute(
        path: '/student/home',
        builder: (context, state) => const StudentHomeScreen(),
      ),
      GoRoute(
        path: '/student/clearance',
        builder: (context, state) => const StudentClearanceScreen(),
      ),
      GoRoute(
        path: '/student/profile',
        builder: (context, state) => const StudentProfileScreen(),
      ),
    ],
  ),
];