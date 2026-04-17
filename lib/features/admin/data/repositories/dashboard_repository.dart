import 'package:student_clearance_tracker/main.dart';

class DashboardStats {
  final int totalStudents;
  final int totalOffices;
  final int totalStaff;
  final int pendingSteps;
  final int flaggedSteps;
  final int completedStudents;
  final String currentPeriodLabel;

  const DashboardStats({
    required this.totalStudents,
    required this.totalOffices,
    required this.totalStaff,
    required this.pendingSteps,
    required this.flaggedSteps,
    required this.completedStudents,
    required this.currentPeriodLabel,
  });
}

class DashboardRepository {
  Future<DashboardStats> getStats() async {
    final data = await supabase.rpc('get_dashboard_stats');

    return DashboardStats(
      totalStudents: data['total_students'] ?? 0,
      totalOffices: data['total_offices'] ?? 0,
      totalStaff: data['total_staff'] ?? 0,
      pendingSteps: data['pending_steps'] ?? 0,
      flaggedSteps: data['flagged_steps'] ?? 0,
      completedStudents: data['completed_students'] ?? 0,
      currentPeriodLabel: data['current_period_label'] ?? 'No active period',
    );
  }
}