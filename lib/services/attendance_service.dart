import '../models/attendance_model.dart';
import 'api_client.dart';

class AttendanceService {
  final _api = ApiClient.instance;

  Future<void> markAttendance({
    required String locationId,
    required DateTime date,
    required Map<String, bool> studentPresenceMap,
  }) async {
    await _api.put('/attendance/upsert', body: {
      'location_id': locationId,
      'date': date.toIso8601String().split('T')[0],
      'student_presence_map': studentPresenceMap,
    });
  }

  Future<List<AttendanceModel>> getAttendanceByDateAndLocation({
    required String locationId,
    required DateTime date,
  }) async {
    final data = await _api.get('/attendance/by-date', query: {
      'location_id': locationId,
      'date': date.toIso8601String().split('T')[0],
    }) as List<dynamic>;

    return data
        .map((item) => AttendanceModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<AttendanceModel>> getStudentAttendance(String studentId) async {
    final data = await _api.get('/attendance/student/$studentId') as List<dynamic>;
    return data
        .map((item) => AttendanceModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, int>> getStudentAttendanceStats(String studentId) async {
    final all = await getStudentAttendance(studentId);
    final presentCount = all.where((a) => a.isPresent).length;
    return {'total': all.length, 'present': presentCount};
  }

  Future<List<AttendanceModel>> getAllAttendance() async {
    final data = await _api.get('/attendance/all') as List<dynamic>;
    return data
        .map((item) => AttendanceModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}

