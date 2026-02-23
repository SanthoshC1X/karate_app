class AttendanceModel {
  final String id;
  final String studentId;
  final String? locationId;
  final DateTime date;
  final String status; // 'present' or 'absent'
  final DateTime createdAt;

  // Optional joined fields
  final String? studentName;
  final String? locationName;

  AttendanceModel({
    required this.id,
    required this.studentId,
    this.locationId,
    required this.date,
    required this.status,
    required this.createdAt,
    this.studentName,
    this.locationName,
  });

  bool get isPresent => status == 'present';

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] as String,
      studentId: map['student_id'] as String,
      locationId: map['location_id'] as String?,
      date: DateTime.parse(map['date'] as String),
      status: map['status'] as String? ?? 'present',
      createdAt: DateTime.parse(map['created_at'] as String),
      studentName: map['users'] != null
          ? (map['users'] as Map<String, dynamic>)['name'] as String?
          : null,
      locationName: map['locations'] != null
          ? (map['locations'] as Map<String, dynamic>)['name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'location_id': locationId,
      'date': date.toIso8601String().split('T')[0],
      'status': status,
    };
  }
}
