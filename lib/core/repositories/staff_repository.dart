import 'package:student_clearance_tracker/main.dart';
import 'package:student_clearance_tracker/core/models/office_staff.dart';
import 'package:student_clearance_tracker/core/models/office.dart';

class StaffRepository {
  Future<List<OfficeStaff>> getAll() async {
    final data = await supabase
        .from('office_staff')
        .select(
          '*, user_profiles(*), staff_offices(office_id, offices(id, name))',
        )
        .order('employee_no');

    return data.map((json) {
      final staff = OfficeStaff.fromJson(json);
      final officeRows = json['staff_offices'] as List<dynamic>? ?? [];
      final offices = officeRows
          .map((row) => Office.fromJson(row['offices']))
          .toList();
      return OfficeStaff(
        id: staff.id,
        employeeNo: staff.employeeNo,
        profile: staff.profile,
        offices: offices,
      );
    }).toList();
  }

  Future<OfficeStaff> getById(String id) async {
    final data = await supabase
        .from('office_staff')
        .select()
        .eq('id', id)
        .single();
    return OfficeStaff.fromJson(data);
  }

  Future<List<int>> getOfficeIds(String staffId) async {
    final data = await supabase
        .from('staff_offices')
        .select('office_id')
        .eq('staff_id', staffId);
    return List<int>.from(data.map((row) => row['office_id']));
  }

  // Create via Edge Function
  Future<void> create({
    required String email,
    required String employeeNo,
    required String firstName,
    String? middleName,
    required String lastName,
    required List<int> officeIds,
  }) async {
    final response = await supabase.functions.invoke(
      'create_staff',
      body: {
        'email': email,
        'employee_no': employeeNo,
        'first_name': firstName,
        'middle_name': middleName,
        'last_name': lastName,
        'office_ids': officeIds,
      },
    );

    if (response.status != 200) {
      final error = response.data['error'] ?? 'Failed to create staff.';
      throw Exception(error);
    }
  }

  // Edit — only updates profile + office assignments, not auth
  Future<void> update({
    required String    id,
    required String    employeeNo,
    required String    firstName,
    String?            middleName,
    required String    lastName,
    required List<int> officeIds,
  }) async {
    // ── Update name fields in user_profiles ──────────────
    await supabase
        .from('user_profiles')
        .update({
          'first_name':  firstName,
          'middle_name': middleName,
          'last_name':   lastName,
        })
        .eq('id', id);

    // ── Update employee_no in office_staff ────────────────
    await supabase
        .from('office_staff')
        .update({ 'employee_no': employeeNo })
        .eq('id', id);

    // ── Replace office assignments ────────────────────────
    await supabase
        .from('staff_offices')
        .delete()
        .eq('staff_id', id);

    if (officeIds.isNotEmpty) {
      await supabase
          .from('staff_offices')
          .insert(officeIds
              .map((oId) => {'staff_id': id, 'office_id': oId})
              .toList());
    }
  }

  // Delete via Edge Function
  Future<void> delete(String userId) async {
    final response = await supabase.functions.invoke(
      'delete_user',
      body: {'user_id': userId},
    );

    if (response.status != 200) {
      final error = response.data['error'] ?? 'Failed to delete user.';
      throw Exception(error);
    }
  }
  
  Future<List<Office>> getAllOffices() async {
    final data = await supabase
        .from('offices')
        .select()
        .order('name');
    return data.map((json) => Office.fromJson(json)).toList();
  }
}
