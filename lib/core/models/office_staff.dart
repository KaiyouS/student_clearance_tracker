import 'office.dart';
import 'user_profile.dart';

class OfficeStaff {
  final String  id;
  final String  employeeNo;
  final List<Office>? offices;

  // Populated via join with user_profiles
  final UserProfile? profile;

  const OfficeStaff({
    required this.id,
    required this.employeeNo,
    this.offices,
    this.profile,
  });

  // Convenience getters so existing code still works
  String  get fullName   => profile?.fullName ?? '';
  String  get firstName  => profile?.firstName ?? '';
  String? get middleName => profile?.middleName;
  String  get lastName   => profile?.lastName ?? '';

  factory OfficeStaff.fromJson(Map<String, dynamic> json) {
    return OfficeStaff(
      id:         json['id'],
      employeeNo: json['employee_no'],
      profile:    json['user_profiles'] != null
                    ? UserProfile.fromJson(json['user_profiles'])
                    : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'employee_no': employeeNo,
  };
}