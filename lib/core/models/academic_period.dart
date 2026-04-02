class AcademicPeriod {
  final int     id;
  final String  label;
  final bool    isCurrent;

  const AcademicPeriod({
    required this.id,
    required this.label,
    required this.isCurrent,
  });

  factory AcademicPeriod.fromJson(Map<String, dynamic> json) {
    return AcademicPeriod(
      id:        json['id'],
      label:     json['label'],
      isCurrent: json['is_current'] ?? false,
    );
  }
}