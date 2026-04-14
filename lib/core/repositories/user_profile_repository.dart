import 'package:student_clearance_tracker/main.dart';
import 'package:student_clearance_tracker/core/models/user_profile.dart';

class UserProfileRepository {
  // Get profile for any user
  Future<UserProfile?> getById(String userId) async {
    try {
      final data = await supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserProfile.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  // Called after successful password change
  Future<void> markPasswordChanged(String userId) async {
    await supabase
        .from('user_profiles')
        .update({
          'needs_password_change': false,
          'account_status':        'active',
        })
        .eq('id', userId);
  }

  // Admin: update account status
  Future<void> updateStatus(String userId, String status) async {
    await supabase
        .from('user_profiles')
        .update({ 'account_status': status })
        .eq('id', userId);
  }
  
  // Get clearance_last_visited for the current user
  Future<DateTime?> getClearanceLastVisited(String userId) async {
    try {
      final data = await supabase
          .from('user_profiles')
          .select('clearance_last_visited')
          .eq('id', userId)
          .single();
      
      final raw = data['clearance_last_visited'];
      return raw != null ? DateTime.parse(raw) : null;
    } catch (_) {
      return null;
    }
  }

  // Calls the DB function — updates clearance_last_visited to NOW()
  Future<void> markClearanceVisited() async {
    await supabase.rpc('mark_clearance_as_read');
  }
}