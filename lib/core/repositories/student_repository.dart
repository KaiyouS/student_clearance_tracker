import 'package:student_clearance_tracker/main.dart';
import 'package:student_clearance_tracker/core/models/student.dart';

class StudentRepository {
  Future<List<Student>> getAll() async {
    final data = await supabase
        .from('students')
        .select('*, user_profiles(*), programs(*, schools(*))')
        .order('student_no');
    return data.map((json) => Student.fromJson(json)).toList();
  }

  Future<Student> getById(String id) async {
    final data = await supabase
        .from('students')
        .select('*, user_profiles(*), programs(*, schools(*))')
        .eq('id', id)
        .single();
    return Student.fromJson(data);
  }

  Future<void> create({
    required String email,
    required String studentNo,
    required String firstName,
    String?         middleName,
    required String lastName,
    int?            programId,
    int?            yearLevel,
  }) async {
    final response = await supabase.functions.invoke(
      'create_student',
      body: {
        'email':       email,
        'student_no':  studentNo,
        'first_name':  firstName,
        'middle_name': middleName,
        'last_name':   lastName,
        'program_id':  programId,
        'year_level':  yearLevel,
      },
    );
    if (response.status != 200) {
      final error = response.data['error'] ?? 'Failed to create student.';
      throw Exception(error);
    }
  }

  Future<void> update({
    required String id,
    required String studentNo,
    required String firstName,
    String?         middleName,
    required String lastName,
    int?            programId,
    int?            yearLevel,
  }) async {
    await supabase
        .from('user_profiles')
        .update({
          'first_name':  firstName,
          'middle_name': middleName,
          'last_name':   lastName,
        })
        .eq('id', id);

    await supabase
        .from('students')
        .update({
          'student_no': studentNo,
          'program_id': programId,
          'year_level': yearLevel,
        })
        .eq('id', id);
  }
}