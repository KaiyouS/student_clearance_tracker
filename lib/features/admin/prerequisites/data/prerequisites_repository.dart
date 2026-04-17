import 'package:student_clearance_tracker/main.dart';
import 'package:student_clearance_tracker/core/models/office.dart';

class PrerequisitesRepository {
  // Get all prerequisites (all rows) — for the full overview
  Future<Map<int, List<Office>>> getAllPrerequisites() async {
    final data = await supabase
        .from('office_prerequisites')
        .select('office_id, offices!office_prerequisites_requires_office_id_fkey(id, name, description)');

    final Map<int, List<Office>> result = {};
    for (final row in data) {
      final officeId = row['office_id'] as int;
      final required = Office.fromJson(row['offices']);
      result.putIfAbsent(officeId, () => []).add(required);
    }
    return result;
  }

  // Add a prerequisite
  Future<void> addPrerequisite(int officeId, int requiresOfficeId) async {
    await supabase.from('office_prerequisites').insert({
      'office_id': officeId,
      'requires_office_id': requiresOfficeId,
    });
  }

  // Remove a prerequisite
  Future<void> removePrerequisite(int officeId, int requiresOfficeId) async {
    await supabase
        .from('office_prerequisites')
        .delete()
        .eq('office_id', officeId)
        .eq('requires_office_id', requiresOfficeId);
  }
}