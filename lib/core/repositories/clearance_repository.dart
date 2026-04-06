import '../../main.dart';
import '../models/clearance_step.dart';

class ClearanceRepository {
  // ── Admin: all students' clearance status for current period ──
  Future<List<Map<String, dynamic>>> getAdminOverview() async {
    final data = await supabase
        .from('student_clearance_status')
        .select()
        .order('full_name');
    return List<Map<String, dynamic>>.from(data);
  }

  // ── Steps for a specific student + period ─────────────────────
  Future<List<ClearanceStep>> getByStudent(
    String studentId,
    int academicPeriodId,
  ) async {
    final data = await supabase
        .from('clearance_steps')
        .select('*, offices(name)')
        .eq('student_id', studentId)
        .eq('academic_period_id', academicPeriodId)
        .order('office_id');
    return data.map((json) => ClearanceStep.fromJson(json)).toList();
  }

  // ── Steps for a specific office + period (for staff) ──────────
  Future<List<ClearanceStep>> getByOffice(
    int officeId,
    int academicPeriodId,
  ) async {
    final data = await supabase
        .from('clearance_steps')
        .select('*, students(student_no, user_profiles(full_name))')
        .eq('office_id', officeId)
        .eq('academic_period_id', academicPeriodId)
        .order('status');
    return data.map((json) => ClearanceStep.fromJson(json)).toList();
  }

  // ── Generate clearance for one student ────────────────────────
  Future<int> generateForStudent(String studentId) async {
    final result = await supabase.rpc(
      'generate_clearance_for_student',
      params: {'p_student_id': studentId},
    );
    return result as int;
  }

  // ── Generate clearance for ALL students ───────────────────────
  Future<int> generateForAllStudents() async {
    final result = await supabase.rpc(
      'generate_clearance_for_all_students',
    );
    return result as int;
  }

  // ── Update step status (staff sign/flag, admin override) ──────
  Future<void> updateStatus({
    required int     stepId,
    required String  status,
    required String  updatedBy,
    String?          remarks,
  }) async {
    await supabase
        .from('clearance_steps')
        .update({
          'status':     status,
          'updated_by': updatedBy,
          'remarks':    remarks,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', stepId);
  }

  // ── Reset a step back to pending (admin only) ─────────────────
  Future<void> resetStep(int stepId) async {
    await supabase
        .from('clearance_steps')
        .update({
          'status':     'pending',
          'updated_by': null,
          'remarks':    null,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', stepId);
  }

  // ── Prerequisite check ────────────────────────────────────────
  Future<bool> canOfficeSign({
    required String studentId,
    required int    officeId,
    required int    academicPeriodId,
  }) async {
    final result = await supabase.rpc('can_office_sign', params: {
      'p_student_id':         studentId,
      'p_office_id':          officeId,
      'p_academic_period_id': academicPeriodId,
    });
    return result as bool;
  }

  Future<List<Map<String, dynamic>>> getStepLogs(int stepId) async {
    final data = await supabase
        .from('clearance_step_logs')
        .select('''
          id,
          old_status,
          new_status,
          remarks,
          changed_at,
          changed_by,
          office_staff (
            user_profiles ( full_name )
          )
        ''')
        .eq('clearance_step_id', stepId)
        .order('changed_at', ascending: true);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<ClearanceStep> getStepById(int stepId) async {
    final data = await supabase
        .from('clearance_steps')
        .select('*, offices(name, description)')
        .eq('id', stepId)
        .single();
    return ClearanceStep.fromJson(data);
  }
}