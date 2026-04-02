import '../../main.dart';
import '../models/office.dart';

class OfficeRepository {
  Future<List<Office>> getAll() async {
    final data = await supabase
        .from('offices')
        .select()
        .order('name');
    return data.map((json) => Office.fromJson(json)).toList();
  }

  Future<Office> create(Office office) async {
    final data = await supabase
        .from('offices')
        .insert(office.toJson())
        .select()
        .single();
    return Office.fromJson(data);
  }

  Future<Office> update(int id, Office office) async {
    final data = await supabase
        .from('offices')
        .update(office.toJson())
        .eq('id', id)
        .select()
        .single();
    return Office.fromJson(data);
  }

  Future<void> delete(int id) async {
    await supabase
        .from('offices')
        .delete()
        .eq('id', id);
  }
  
  // Get all prerequisites for a specific office
  Future<List<Office>> getPrerequisites(int officeId) async {
    final data = await supabase
        .from('office_prerequisites')
        .select('requires_office_id, offices!office_prerequisites_requires_office_id_fkey(id, name, description)')
        .eq('office_id', officeId);

    return data
        .map((row) => Office.fromJson(row['offices']))
        .toList();
  }

  // Add a prerequisite
  Future<void> addPrerequisite(int officeId, int requiresOfficeId) async {
    await supabase
        .from('office_prerequisites')
        .insert({
          'office_id':          officeId,
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
}