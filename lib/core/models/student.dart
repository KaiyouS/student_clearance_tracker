import 'user_profile.dart';

class Student {
  final String  id;
  final String  studentNo;
  final String? course;
  final int?    yearLevel;

  // Populated via join with user_profiles
  final UserProfile? profile;

  const Student({
    required this.id,
    required this.studentNo,
    this.course,
    this.yearLevel,
    this.profile,
  });

  // Convenience getter so existing code referencing fullName still works
  String get fullName => profile?.fullName ?? '';

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id:        json['id'],
      studentNo: json['student_no'],
      course:    json['course'],
      yearLevel: json['year_level'],
      profile:   json['user_profiles'] != null
                   ? UserProfile.fromJson(json['user_profiles'])
                   : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'student_no': studentNo,
    'course':     course,
    'year_level': yearLevel,
  };
}