import '../models/user_model.dart';
import 'mock_api_store.dart';

class UserService {
  final _store = MockApiStore.instance;

  Future<List<UserModel>> getAllStudents() async {
    final data = await _store.getUsers(role: 'student');
    return data.map(UserModel.fromMap).toList();
  }

  Future<List<UserModel>> getStudentsByLocation(String locationId) async {
    final data = await _store.getUsers(role: 'student', locationId: locationId);
    return data.map(UserModel.fromMap).toList();
  }

  Future<UserModel?> getStudentById(String id) async {
    final data = _store.getUserById(id);
    if (data == null) return null;
    return UserModel.fromMap(data);
  }

  Future<void> updateStudent(String id, Map<String, dynamic> updates) async {
    await _store.updateUser(id, updates);
  }
}
