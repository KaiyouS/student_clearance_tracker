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
}