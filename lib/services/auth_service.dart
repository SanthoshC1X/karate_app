import '../models/user_model.dart';
import 'mock_api_store.dart';

class AuthService {
  final _store = MockApiStore.instance;

  String? get currentUserId => _store.currentUserId;
  bool get isLoggedIn => currentUserId != null;

  Future<UserModel?> getCurrentUserProfile() async {
    final data = _store.getCurrentUserProfile();
    if (data == null) return null;
    return UserModel.fromMap(data);
  }

  Future<UserModel> signIn(String email, String password) async {
    final data = await _store.signIn(email, password);
    return UserModel.fromMap(data);
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    int? age,
    required String beltLevel,
    String? phone,
    String? locationId,
  }) async {
    final data = await _store.signUp(
      email: email,
      password: password,
      name: name,
      age: age,
      beltLevel: beltLevel,
      phone: phone,
      locationId: locationId,
    );
    return UserModel.fromMap(data);
  }

  Future<void> signOut() async {
    await _store.signOut();
  }

  Stream<MockAuthState> get authStateChanges => _store.authStateChanges;
}
