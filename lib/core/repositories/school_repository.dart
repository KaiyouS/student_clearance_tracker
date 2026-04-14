import 'package:student_clearance_tracker/main.dart';
import 'package:student_clearance_tracker/core/models/school.dart';

class SchoolRepository {
  Future<List<School>> getAll() async {
    final data = await supabase
        .from('schools')
        .select()
        .order('name');
    return data.map((json) => School.fromJson(json)).toList();
  }

  Future<School> create(School school) async {
    final data = await supabase
        .from('schools')
        .insert(school.toJson())
        .select()
        .single();
    return School.fromJson(data);
  }

  Future<School> update(int id, School school) async {
    final data = await supabase
        .from('schools')
        .update(school.toJson())
        .eq('id', id)
        .select()
        .single();
    return School.fromJson(data);
  }

  Future<void> delete(int id) async {
    await supabase
        .from('schools')
        .delete()
        .eq('id', id);
  }
}