import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _service;

  UserProvider({UserService? service}) : _service = service ?? UserService();

  List<UserModel> _students = const [];
  bool _isLoading = false;
  String? _error;
  final Map<String, UserModel?> _detailCache = {};

  List<UserModel> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _students = await _service.getAllStudents();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<UserModel>> fetchStudentsByLocation(String locationId) async {
    _error = null;
    notifyListeners();
    try {
      return await _service.getStudentsByLocation(locationId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<UserModel?> fetchStudentDetail(String studentId) async {
    _error = null;
    notifyListeners();
    try {
      final detail = await _service.getStudentById(studentId);
      _detailCache[studentId] = detail;
      notifyListeners();
      return detail;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  UserModel? getStudentDetail(String studentId) => _detailCache[studentId];

  Future<void> updateStudent(String id, Map<String, dynamic> updates) async {
    _error = null;
    notifyListeners();
    try {
      await _service.updateStudent(id, updates);
      if (_students.isNotEmpty) {
        await fetchAllStudents();
      }
      await fetchStudentDetail(id);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
}
