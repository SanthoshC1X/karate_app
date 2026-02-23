import '../models/attendance_model.dart';
import 'mock_api_store.dart';

class AttendanceService {
  final _store = MockApiStore.instance;

  /// Mark or update attendance for a list of students on a given date.
  Future<void> markAttendance({
    required String locationId,
    required DateTime date,
    required Map<String, bool> studentPresenceMap, // studentId -> isPresent
  }) async {
    await _store.upsertAttendance(
      locationId: locationId,
      date: date,
      studentPresenceMap: studentPresenceMap,
    );
  }

  /// Get all attendance for a specific date + location (for admin marking).
  Future<List<AttendanceModel>> getAttendanceByDateAndLocation({
    required String locationId,
    required DateTime date,
  }) async {
    final data = await _store.getAttendanceByDateAndLocation(
      locationId: locationId,
      date: date,
    );
    return data.map(AttendanceModel.fromMap).toList();
  }

  /// Get attendance history for one student.
  Future<List<AttendanceModel>> getStudentAttendance(String studentId) async {
    final data = await _store.getStudentAttendance(studentId);
    return data.map(AttendanceModel.fromMap).toList();
  }

  /// Get aggregate stats: total sessions and present count.
  Future<Map<String, int>> getStudentAttendanceStats(String studentId) async {
    final all = await getStudentAttendance(studentId);
    final presentCount = all.where((a) => a.isPresent).length;
    return {'total': all.length, 'present': presentCount};
  }

  /// For admin: get ALL attendance (with student names).
  Future<List<AttendanceModel>> getAllAttendance() async {
    final data = await _store.getAllAttendance();
    return data.map(AttendanceModel.fromMap).toList();
  }
}
