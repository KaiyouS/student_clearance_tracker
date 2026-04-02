import 'office.dart';

class OfficeStaff {
  final String  id;
  final String  employeeNo;
  final String  firstName;
  final String? middleName;
  final String  lastName;
  final String  fullName;
  final List<Office>? offices; // populated via join when needed

  const OfficeStaff({
    required this.id,
    required this.employeeNo,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.fullName,
    this.offices,
  });

  factory OfficeStaff.fromJson(Map<String, dynamic> json) {
    return OfficeStaff(
      id:          json['id'],
      employeeNo:  json['employee_no'],
      firstName:   json['first_name'],
      middleName:  json['middle_name'],
      lastName:    json['last_name'],
      fullName:    json['full_name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'employee_no':  employeeNo,
    'first_name':   firstName,
    'middle_name':  middleName,
    'last_name':    lastName,
  };
}