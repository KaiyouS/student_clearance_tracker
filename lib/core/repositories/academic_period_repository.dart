import '../../main.dart';
import '../models/academic_period.dart';

class AcademicPeriodRepository {
  Future<List<AcademicPeriod>> getAll() async {
    final data = await supabase
        .from('academic_periods')
        .select()
        .order('start_date', ascending: false);
    return data.map((json) => AcademicPeriod.fromJson(json)).toList();
  }

  Future<AcademicPeriod?> getCurrent() async {
    try {
      final data = await supabase
          .from('academic_periods')
          .select()
          .eq('is_current', true)
          .single();
      return AcademicPeriod.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<AcademicPeriod> create(AcademicPeriod period) async {
    final data = await supabase
        .from('academic_periods')
        .insert(period.toJson())
        .select()
        .single();
    return AcademicPeriod.fromJson(data);
  }

  Future<AcademicPeriod> update(int id, AcademicPeriod period) async {
    final data = await supabase
        .from('academic_periods')
        .update({
          'label':      period.label,
          'start_date': period.startDate?.toIso8601String().substring(0, 10),
          'end_date':   period.endDate?.toIso8601String().substring(0, 10),
        })
        .eq('id', id)
        .select()
        .single();
    return AcademicPeriod.fromJson(data);
  }

  Future<void> delete(int id) async {
    await supabase
        .from('academic_periods')
        .delete()
        .eq('id', id);
  }

  // Calls the DB function we created in the schema
  // Safely unsets old current + sets new one atomically
  Future<void> setCurrent(int id) async {
    await supabase.rpc('set_current_period', params: {'period_id': id});
  }
}