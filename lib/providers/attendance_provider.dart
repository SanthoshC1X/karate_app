import 'package:flutter/foundation.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class AttendanceQueryParams {
  final String locationId;
  final DateTime date;
  const AttendanceQueryParams(this.locationId, this.date);
}

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _service;

  AttendanceProvider({AttendanceService? service})
      : _service = service ?? AttendanceService();

  bool _isLoading = false;
  String? _error;
  final Map<String, List<AttendanceModel>> _studentAttendance = {};
  final Map<String, Map<String, int>> _studentStats = {};
  final Map<String, List<AttendanceModel>> _byDate = {};

  bool get isLoading => _isLoading;
  String? get error => _error;

  String _dateKey(String locationId, DateTime date) =>
      '$locationId|${date.toIso8601String().split('T')[0]}';

  List<AttendanceModel> getStudentAttendance(String studentId) =>
      _studentAttendance[studentId] ?? const [];

  Map<String, int> getStudentStats(String studentId) =>
      _studentStats[studentId] ?? const {'total': 0, 'present': 0};

  List<AttendanceModel> getByDate(String locationId, DateTime date) =>
      _byDate[_dateKey(locationId, date)] ?? const [];

  Future<void> fetchStudentAttendance(String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final list = await _service.getStudentAttendance(studentId);
      _studentAttendance[studentId] = list;
      final present = list.where((a) => a.isPresent).length;
      _studentStats[studentId] = {'total': list.length, 'present': present};
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchByDate({
    required String locationId,
    required DateTime date,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _service.getAttendanceByDateAndLocation(
        locationId: locationId,
        date: date,
      );
      _byDate[_dateKey(locationId, date)] = data;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAttendance({
    required String locationId,
    required DateTime date,
    required Map<String, bool> studentPresenceMap,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.markAttendance(
        locationId: locationId,
        date: date,
        studentPresenceMap: studentPresenceMap,
      );
      await fetchByDate(locationId: locationId, date: date);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
