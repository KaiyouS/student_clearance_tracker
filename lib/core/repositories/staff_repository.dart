import '../../main.dart';
import '../models/office_staff.dart';

class StaffRepository {
  Future<List<OfficeStaff>> getAll() async {
    final data = await supabase
        .from('office_staff')
        .select()
        .order('last_name');
    return data.map((json) => OfficeStaff.fromJson(json)).toList();
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

  Future<void> assignOffice(String staffId, int officeId) async {
    await supabase
        .from('staff_offices')
        .insert({'staff_id': staffId, 'office_id': officeId});
  }

  Future<void> removeOffice(String staffId, int officeId) async {
    await supabase
        .from('staff_offices')
        .delete()
        .eq('staff_id', staffId)
        .eq('office_id', officeId);
  }
}