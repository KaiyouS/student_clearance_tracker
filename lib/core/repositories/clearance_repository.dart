import '../../main.dart';
import '../models/clearance_step.dart';

class ClearanceRepository {
  // All steps for a specific student + period
  Future<List<ClearanceStep>> getByStudent(
    String studentId,
    int academicPeriodId,
  ) async {
    final data = await supabase
        .from('clearance_steps')
        .select('*, offices(name)')
        .eq('student_id', studentId)
        .eq('academic_period_id', academicPeriodId);
    return data.map((json) => ClearanceStep.fromJson(json)).toList();
  }

  // All steps for a specific office + period
  Future<List<ClearanceStep>> getByOffice(
    int officeId,
    int academicPeriodId,
  ) async {
    final data = await supabase
        .from('clearance_steps')
        .select('*, students(full_name)')
        .eq('office_id', officeId)
        .eq('academic_period_id', academicPeriodId)
        .order('status');
    return data.map((json) => ClearanceStep.fromJson(json)).toList();
  }

  // Update status (sign or flag)
  Future<void> updateStatus({
    required int    stepId,
    required String status,
    required String updatedBy,
    String?         remarks,
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

  // Call the DB function to check prerequisites
  Future<bool> canOfficeSign({
    required String studentId,
    required int    officeId,
    required int    academicPeriodId,
  }) async {
    final result = await supabase.rpc('can_office_sign', params: {
      'p_student_id':          studentId,
      'p_office_id':           officeId,
      'p_academic_period_id':  academicPeriodId,
    });
    return result as bool;
  }
}