class Student {
  final String  id;
  final String  studentNo;
  final String  firstName;
  final String? middleName;
  final String  lastName;
  final String  fullName;
  final String? course;
  final int?    yearLevel;

  const Student({
    required this.id,
    required this.studentNo,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.fullName,
    this.course,
    this.yearLevel,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id:          json['id'],
      studentNo:   json['student_no'],
      firstName:   json['first_name'],
      middleName:  json['middle_name'],
      lastName:    json['last_name'],
      fullName:    json['full_name'],
      course:      json['course'],
      yearLevel:   json['year_level'],
    );
  }

  Map<String, dynamic> toJson() => {
    'student_no':   studentNo,
    'first_name':   firstName,
    'middle_name':  middleName,
    'last_name':    lastName,
    'course':       course,
    'year_level':   yearLevel,
  };
}