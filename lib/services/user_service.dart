import '../models/user_model.dart';
import 'api_client.dart';

class UserService {
  final _api = ApiClient.instance;

  Future<List<UserModel>> getAllStudents() async {
    final data = await _api.get('/users', query: {'role': 'student'}) as List<dynamic>;
    return data
        .map((item) => UserModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserModel>> getStudentsByLocation(String locationId) async {
    final data = await _api.get('/users', query: {
      'role': 'student',
      'location_id': locationId,
    }) as List<dynamic>;
    return data
        .map((item) => UserModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel?> getStudentById(String id) async {
    try {
      final data = await _api.get('/users/$id') as Map<String, dynamic>;
      return UserModel.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateStudent(String id, Map<String, dynamic> updates) async {
    await _api.patch('/users/$id', body: updates);
  }
}

