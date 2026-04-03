class AcademicPeriod {
  final int     id;
  final String  label;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool    isCurrent;

  const AcademicPeriod({
    required this.id,
    required this.label,
    this.startDate,
    this.endDate,
    required this.isCurrent,
  });

  factory AcademicPeriod.fromJson(Map<String, dynamic> json) => AcademicPeriod(
    id:        json['id'],
    label:     json['label'],
    startDate: json['start_date'] != null
                 ? DateTime.parse(json['start_date'])
                 : null,
    endDate:   json['end_date'] != null
                 ? DateTime.parse(json['end_date'])
                 : null,
    isCurrent: json['is_current'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'label':      label,
    'start_date': startDate?.toIso8601String().substring(0, 10),
    'end_date':   endDate?.toIso8601String().substring(0, 10),
    'is_current': isCurrent,
  };

  // e.g. "Aug 2024 – May 2025"
  String get dateRange {
    if (startDate == null && endDate == null) return '—';
    final start = startDate != null ? _formatDate(startDate!) : '?';
    final end   = endDate   != null ? _formatDate(endDate!)   : '?';
    return '$start – $end';
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}