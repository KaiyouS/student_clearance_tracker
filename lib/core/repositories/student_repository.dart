import '../../main.dart';
import '../models/student.dart';

class StudentRepository {
  Future<List<Student>> getAll() async {
    final data = await supabase
        .from('students')
        .select('*, user_profiles(*)')
        .order('student_no');
    return data.map((json) => Student.fromJson(json)).toList();
  }

  Future<Student> getById(String id) async {
    final data = await supabase
        .from('students')
        .select('*, user_profiles(*)')
        .eq('id', id)
        .single();
    return Student.fromJson(data);
  }

  // Create via Edge Function
  Future<void> create({
    required String email,
    required String studentNo,
    required String firstName,
    String?         middleName,
    required String lastName,
    String?         course,
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
        'course':      course,
        'year_level':  yearLevel,
      },
    );

    if (response.status != 200) {
      final error = response.data['error'] ?? 'Failed to create student.';
      throw Exception(error);
    }
  }

  // Edit — updates user_profiles + students, not auth
  Future<void> update({
    required String id,
    required String studentNo,
    required String firstName,
    String?         middleName,
    required String lastName,
    String?         course,
    int?            yearLevel,
  }) async {
    // Update name fields in user_profiles
    await supabase
        .from('user_profiles')
        .update({
          'first_name':  firstName,
          'middle_name': middleName,
          'last_name':   lastName,
        })
        .eq('id', id);

    // Update student-specific fields
    await supabase
        .from('students')
        .update({
          'student_no': studentNo,
          'course':     course,
          'year_level': yearLevel,
        })
        .eq('id', id);
  }

  // Delete via Edge Function
  Future<void> delete(String userId) async {
    final response = await supabase.functions.invoke(
      'delete_user',
      body: { 'user_id': userId },
    );

    if (response.status != 200) {
      final error = response.data['error'] ?? 'Failed to delete student.';
      throw Exception(error);
    }
  }
}