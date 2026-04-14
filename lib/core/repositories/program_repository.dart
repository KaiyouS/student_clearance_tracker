import 'package:student_clearance_tracker/main.dart';
import 'package:student_clearance_tracker/core/models/program.dart';

class ProgramRepository {
  // All programs with their school info
  Future<List<Program>> getAll() async {
    final data = await supabase
        .from('programs')
        .select('*, schools(id, name)')
        .order('name');
    return data.map((json) => Program.fromJson(json)).toList();
  }

  // Programs for a specific school — used in cascading dropdown
  Future<List<Program>> getBySchool(int schoolId) async {
    final data = await supabase
        .from('programs')
        .select('*, schools(id, name)')
        .eq('school_id', schoolId)
        .order('name');
    return data.map((json) => Program.fromJson(json)).toList();
  }

  Future<Program> create(Program program) async {
    final data = await supabase
        .from('programs')
        .insert(program.toJson())
        .select('*, schools(id, name)')
        .single();
    return Program.fromJson(data);
  }

  Future<Program> update(int id, Program program) async {
    final data = await supabase
        .from('programs')
        .update(program.toJson())
        .eq('id', id)
        .select('*, schools(id, name)')
        .single();
    return Program.fromJson(data);
  }

  Future<void> delete(int id) async {
    await supabase
        .from('programs')
        .delete()
        .eq('id', id);
  }
}