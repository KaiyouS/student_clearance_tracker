import 'package:student_clearance_tracker/main.dart';

class RequirementsRepository {
  // Set office to apply to all — removes specific entries, inserts NULL
  Future<void> setAppliesToAll(int officeId) async {
    await supabase
        .from('office_requirements')
        .delete()
        .eq('office_id', officeId);
    await supabase
        .from('office_requirements')
        .insert({'office_id': officeId, 'program_id': null});
  }

  // Remove all requirements for an office
  Future<void> clearRequirements(int officeId) async {
    await supabase
        .from('office_requirements')
        .delete()
        .eq('office_id', officeId);
  }

  // Add a specific program requirement
  Future<void> addRequirement(int officeId, int programId) async {
    // Remove "applies to all" entry if it exists first
    await supabase
        .from('office_requirements')
        .delete()
        .eq('office_id', officeId)
        .isFilter('program_id', null);

    await supabase
        .from('office_requirements')
        .insert({'office_id': officeId, 'program_id': programId});
  }

  // Remove a specific program requirement
  Future<void> removeRequirement(int officeId, int programId) async {
    await supabase
        .from('office_requirements')
        .delete()
        .eq('office_id', officeId)
        .eq('program_id', programId);
  }

  // Get all requirements as a map: office_id → list of program_ids (null = all)
  Future<Map<int, List<int?>>> getAllRequirements() async {
    final data = await supabase
        .from('office_requirements')
        .select('office_id, program_id');

    final Map<int, List<int?>> result = {};
    for (final row in data) {
      final officeId  = row['office_id'] as int;
      final programId = row['program_id'] as int?;
      result.putIfAbsent(officeId, () => []).add(programId);
    }
    return result;
  }
}