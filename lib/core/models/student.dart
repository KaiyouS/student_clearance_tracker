import 'package:student_clearance_tracker/core/models/program.dart';
import 'package:student_clearance_tracker/core/models/user_profile.dart';

class Student {
  final String   id;
  final String   studentNo;
  final int?     programId;
  final int?     yearLevel;
  final Program? program;    // populated via join
  final UserProfile? profile;

  const Student({
    required this.id,
    required this.studentNo,
    this.programId,
    this.yearLevel,
    this.program,
    this.profile,
  });

  // Convenience getters
  String get fullName    => profile?.fullName ?? '';
  String get programName => program?.name ?? '—';
  String get schoolName  => program?.school?.name ?? '—';

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id:        json['id'],
    studentNo: json['student_no'],
    programId: json['program_id'],
    yearLevel: json['year_level'],
    program:   json['programs'] != null
                 ? Program.fromJson(json['programs'])
                 : null,
    profile:   json['user_profiles'] != null
                 ? UserProfile.fromJson(json['user_profiles'])
                 : null,
  );

  Map<String, dynamic> toJson() => {
    'student_no': studentNo,
    'program_id': programId,
    'year_level': yearLevel,
  };
}