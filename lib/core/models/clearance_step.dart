class ClearanceStep {
  final int      id;
  final String   studentId;
  final int      officeId;
  final int      academicPeriodId;
  final String   status; // 'pending' | 'signed' | 'flagged'
  final String?  remarks;
  final DateTime? updatedAt;
  final String?  updatedBy;

  // Optionally populated via joins
  final String?  studentName;
  final String?  officeName;

  const ClearanceStep({
    required this.id,
    required this.studentId,
    required this.officeId,
    required this.academicPeriodId,
    required this.status,
    this.remarks,
    this.updatedAt,
    this.updatedBy,
    this.studentName,
    this.officeName,
  });

  factory ClearanceStep.fromJson(Map<String, dynamic> json) {
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
      // From joins (may or may not be present)
      studentName:       json['students']?['full_name'],
      officeName:        json['offices']?['name'],
    );
  }
}