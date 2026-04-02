import '../../main.dart';
import '../models/student.dart';

class StudentRepository {
  Future<List<Student>> getAll() async {
    final data = await supabase
        .from('students')
        .select()
        .order('last_name');
    return data.map((json) => Student.fromJson(json)).toList();
  }

  Future<Student> getById(String id) async {
    final data = await supabase
        .from('students')
        .select()
        .eq('id', id)
        .single();
    return Student.fromJson(data);
  }

  Future<void> update(String id, Map<String, dynamic> fields) async {
    await supabase
        .from('students')
        .update(fields)
        .eq('id', id);
  }
}