import 'school.dart';

class Program {
  final int     id;
  final String  name;
  final int     schoolId;
  final School? school; // populated via join when needed

  const Program({
    required this.id,
    required this.name,
    required this.schoolId,
    this.school,
  });

  factory Program.fromJson(Map<String, dynamic> json) => Program(
    id:        json['id'],
    name:      json['name'],
    schoolId:  json['school_id'],
    school:    json['schools'] != null
                 ? School.fromJson(json['schools'])
                 : null,
  );

  Map<String, dynamic> toJson() => {
    'name':       name,
    'school_id': schoolId,
  };
}