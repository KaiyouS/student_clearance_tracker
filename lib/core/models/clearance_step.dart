class ClearanceStep {
  final int       id;
  final String    studentId;
  final int       officeId;
  final int       academicPeriodId;
  final String    status;
  final String?   remarks;
  final DateTime? updatedAt;
  final String?   updatedBy;
  final String?   officeName;
  final String?   studentName;
  final String?   studentNo;

  const ClearanceStep({
    required this.id,
    required this.studentId,
    required this.officeId,
    required this.academicPeriodId,
    required this.status,
    this.remarks,
    this.updatedAt,
    this.updatedBy,
    this.officeName,
    this.studentName,
    this.studentNo,
  });

  factory ClearanceStep.fromJson(Map<String, dynamic> json) {
    // Handle nested joins from different query shapes
    final officeData  = json['offices'];
    final studentData = json['students'];

    return ClearanceStep(
      id:                json['id'],
      studentId:         json['student_id'],
      officeId:          json['office_id'],
      academicPeriodId:  json['academic_period_id'],
      status:            json['status'],
      remarks:           json['remarks'],
      updatedAt:         json['updated_at'] != null
                           ? DateTime.parse(json['updated_at'])
                           : null,
      updatedBy:         json['updated_by'],
      officeName:        officeData?['name'],
      studentName:       studentData?['user_profiles']?['full_name'],
      studentNo:         studentData?['student_no'],
    );
  }

  bool get isSigned  => status == 'signed';
  bool get isFlagged => status == 'flagged';
  bool get isPending => status == 'pending';
}