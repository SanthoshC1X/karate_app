import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import 'api_client.dart';

enum AuthChangeEvent { initialSession, signedIn, signedOut }

class AuthState {
  final AuthChangeEvent event;
  const AuthState(this.event);
}

class AuthService {
  static const _tokenKey = 'auth_token';
  static final _authController = StreamController<AuthState>.broadcast();

  static String? _currentUserId;
  static bool _initialized = false;

  final _api = ApiClient.instance;

  String? get currentUserId => _currentUserId;
  bool get isLoggedIn => _api.token != null;

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    _api.setToken(token);

    if (token != null) {
      try {
        final profile = await getCurrentUserProfile();
        _currentUserId = profile?.id;
      } catch (_) {
        await signOut();
      }
    }

    _initialized = true;
  }

  Future<UserModel?> getCurrentUserProfile() async {
    if (_api.token == null) return null;
    final data = await _api.get('/auth/me') as Map<String, dynamic>?;
    if (data == null) return null;
    _currentUserId = data['id'] as String?;
    return UserModel.fromMap(data);
  }

  Future<UserModel> signIn(String email, String password) async {
    final data = await _api.post('/auth/login', body: {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;

    final token = data['token'] as String?;
    final userMap = data['user'] as Map<String, dynamic>?;
    if (token == null || userMap == null) {
      throw Exception('Invalid login response');
    }

    _api.setToken(token);
    _currentUserId = userMap['id'] as String?;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _authController.add(const AuthState(AuthChangeEvent.signedIn));

    return UserModel.fromMap(userMap);
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    int? age,
    String? phone,
    String? locationId,
    List<String>? masterIds,
    List<String>? classIds,
    List<Map<String, String>>? rankValues,
  }) async {
    final data = await _api.post('/auth/register', body: {
      'email': email,
      'password': password,
      'name': name,
      'age': age,
      'phone': phone,
      'location_id': locationId,
      'master_ids': masterIds ?? const <String>[],
      'class_ids': classIds ?? const <String>[],
      if (rankValues != null && rankValues.isNotEmpty)
        'rank_values': rankValues,
    }) as Map<String, dynamic>;

    final token = data['token'] as String?;
    final userMap = data['user'] as Map<String, dynamic>?;
    if (token == null || userMap == null) {
      throw Exception('Invalid registration response');
    }

    _api.setToken(token);
    _currentUserId = userMap['id'] as String?;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _authController.add(const AuthState(AuthChangeEvent.signedIn));

    return UserModel.fromMap(userMap);
  }

  Future<UserModel> signUpMaster({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? bio,
    required List<String> locationIds,
    List<Map<String, String?>>? newLocations,
    List<String>? classIds,
    // Each map has 'name', 'description', and optionally 'rank_fields'
    List<Map<String, dynamic>>? newClasses,
    // Rank fields for existing selected classes, keyed by class_id
    Map<String, List<Map<String, dynamic>>>? classRankFields,
  }) async {
    final data = await _api.post('/auth/register-master', body: {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'bio': bio,
      'location_ids': locationIds,
      'new_locations': newLocations ?? const <Map<String, String?>>[],
      'class_ids': classIds ?? const <String>[],
      'new_classes': newClasses ?? const <Map<String, dynamic>>[],
      if (classRankFields != null && classRankFields.isNotEmpty)
        'class_rank_fields': classRankFields,
    }) as Map<String, dynamic>;

    final token = data['token'] as String?;
    final userMap = data['user'] as Map<String, dynamic>?;
    if (token == null || userMap == null) {
      throw Exception('Invalid master registration response');
    }

    _api.setToken(token);
    _currentUserId = userMap['id'] as String?;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _authController.add(const AuthState(AuthChangeEvent.signedIn));

    return UserModel.fromMap(userMap);
  }

  Future<void> signOut() async {
    _api.setToken(null);
    _currentUserId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _authController.add(const AuthState(AuthChangeEvent.signedOut));
  }

  Stream<AuthState> get authStateChanges async* {
    await init();
    yield const AuthState(AuthChangeEvent.initialSession);
    yield* _authController.stream;
  }
}
