import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

final attendanceServiceProvider =
    Provider<AttendanceService>((ref) => AttendanceService());

final studentAttendanceProvider =
    FutureProvider.family<List<AttendanceModel>, String>(
        (ref, studentId) async {
  return ref
      .read(attendanceServiceProvider)
      .getStudentAttendance(studentId);
});

final studentAttendanceStatsProvider =
    FutureProvider.family<Map<String, int>, String>((ref, studentId) async {
  return ref
      .read(attendanceServiceProvider)
      .getStudentAttendanceStats(studentId);
});

// Params class for location + date queries
class AttendanceQueryParams {
  final String locationId;
  final DateTime date;
  AttendanceQueryParams(this.locationId, this.date);
}

final attendanceByDateProvider =
    FutureProvider.family<List<AttendanceModel>, AttendanceQueryParams>(
        (ref, params) async {
  return ref
      .read(attendanceServiceProvider)
      .getAttendanceByDateAndLocation(
        locationId: params.locationId,
        date: params.date,
      );
});
