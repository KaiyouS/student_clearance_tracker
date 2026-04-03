import '../../main.dart';
import '../models/user_profile.dart';

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
}