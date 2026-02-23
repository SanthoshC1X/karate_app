import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';

enum MockAuthChangeEvent { initialSession, signedIn, signedOut }

class MockAuthState {
  final MockAuthChangeEvent event;
  const MockAuthState(this.event);
}

class MockApiStore {
  MockApiStore._() {
    _seedFromJson();
  }

  static final MockApiStore instance = MockApiStore._();

  final _uuid = const Uuid();
  final _authController = StreamController<MockAuthState>.broadcast();

  final Map<String, Map<String, String>> _accountsByEmail = {};
  final List<Map<String, dynamic>> _users = [];
  final List<Map<String, dynamic>> _locations = [];
  final List<Map<String, dynamic>> _posts = [];
  final List<Map<String, dynamic>> _attendance = [];

  String? _currentUserId;

  Stream<MockAuthState> get authStateChanges async* {
    yield const MockAuthState(MockAuthChangeEvent.initialSession);
    yield* _authController.stream;
  }

  String? get currentUserId => _currentUserId;

  void _seedFromJson() {
    const now = '2026-02-22T00:00:00.000Z';
    const locationsJson = '''
[
  {"id":"11111111-1111-1111-1111-111111111111","name":"Bolloine","address":"Tower A","notes":"Morning batch","created_at":"$now"},
  {"id":"22222222-2222-2222-2222-222222222222","name":"DLF","address":"Club House","notes":"Evening batch","created_at":"$now"},
  {"id":"33333333-3333-3333-3333-333333333333","name":"Gemgrove","address":"Community Hall","notes":null,"created_at":"$now"},
  {"id":"44444444-4444-4444-4444-444444444444","name":"RC Blossom","address":"Block C","notes":null,"created_at":"$now"},
  {"id":"55555555-5555-5555-5555-555555555555","name":"Jonesh Casio","address":"Basement Studio","notes":null,"created_at":"$now"},
  {"id":"66666666-6666-6666-6666-666666666666","name":"TVH","address":"Indoor Arena","notes":"Weekend special","created_at":"$now"},
  {"id":"77777777-7777-7777-7777-777777777777","name":"TCH","address":"Community Center","notes":null,"created_at":"$now"}
]
''';

    const usersJson = '''
[
  {"id":"a1111111-1111-1111-1111-111111111111","name":"karate_admin","age":30,"belt_level":"Black","phone":"9999999999","role":"admin","location_id":"11111111-1111-1111-1111-111111111111","created_at":"$now"},
  {"id":"b1111111-1111-1111-1111-111111111111","name":"Arun","age":14,"belt_level":"Yellow","phone":"8888888881","role":"student","location_id":"11111111-1111-1111-1111-111111111111","created_at":"$now"},
  {"id":"c1111111-1111-1111-1111-111111111111","name":"Meena","age":16,"belt_level":"Green","phone":"8888888882","role":"student","location_id":"22222222-2222-2222-2222-222222222222","created_at":"$now"},
  {"id":"d1111111-1111-1111-1111-111111111111","name":"Ravi","age":13,"belt_level":"Orange","phone":"8888888883","role":"student","location_id":"11111111-1111-1111-1111-111111111111","created_at":"$now"}
]
''';

    const postsJson = '''
[
  {"id":"p1111111-1111-1111-1111-111111111111","title":"Sunday Sparring","description":"Bring safety gear.","date":"2026-03-01","image_url":"https://picsum.photos/900/500?random=11","type":"upcoming","created_at":"$now"},
  {"id":"p2222222-1111-1111-1111-111111111111","title":"Belt Test Results","description":"Congrats to all students!","date":"2026-02-15","image_url":"https://picsum.photos/900/500?random=12","type":"recent","created_at":"$now"}
]
''';

    const attendanceJson = '''
[
  {"id":"at111111-1111-1111-1111-111111111111","student_id":"b1111111-1111-1111-1111-111111111111","location_id":"11111111-1111-1111-1111-111111111111","date":"2026-02-20","status":"present","created_at":"$now"},
  {"id":"at222222-1111-1111-1111-111111111111","student_id":"b1111111-1111-1111-1111-111111111111","location_id":"11111111-1111-1111-1111-111111111111","date":"2026-02-18","status":"absent","created_at":"$now"},
  {"id":"at333333-1111-1111-1111-111111111111","student_id":"c1111111-1111-1111-1111-111111111111","location_id":"22222222-2222-2222-2222-222222222222","date":"2026-02-20","status":"present","created_at":"$now"}
]
''';

    _locations.addAll(
      (jsonDecode(locationsJson) as List).cast<Map<String, dynamic>>(),
    );
    _users.addAll((jsonDecode(usersJson) as List).cast<Map<String, dynamic>>());
    _posts.addAll((jsonDecode(postsJson) as List).cast<Map<String, dynamic>>());
    _attendance.addAll(
      (jsonDecode(attendanceJson) as List).cast<Map<String, dynamic>>(),
    );

    _accountsByEmail['iyappansanthosh2004@gmail.com'] = {
      'password': '123456789',
      'user_id': 'a1111111-1111-1111-1111-111111111111',
    };
    _accountsByEmail['student1@dojo.app'] = {
      'password': '123456',
      'user_id': 'b1111111-1111-1111-1111-111111111111',
    };
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final account = _accountsByEmail[email];
    if (account == null || account['password'] != password) {
      throw Exception('Invalid email or password');
    }
    _currentUserId = account['user_id'];
    _authController.add(const MockAuthState(MockAuthChangeEvent.signedIn));
    return getUserById(_currentUserId!)!;
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    int? age,
    required String beltLevel,
    String? phone,
    String? locationId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (_accountsByEmail.containsKey(email)) {
      throw Exception('Email already registered');
    }
    final userId = _uuid.v4();
    final user = <String, dynamic>{
      'id': userId,
      'name': name,
      'age': age,
      'belt_level': beltLevel,
      'phone': phone,
      'role': 'student',
      'location_id': locationId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };
    _users.add(user);
    _accountsByEmail[email] = {'password': password, 'user_id': userId};
    _currentUserId = userId;
    _authController.add(const MockAuthState(MockAuthChangeEvent.signedIn));
    return user;
  }

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _currentUserId = null;
    _authController.add(const MockAuthState(MockAuthChangeEvent.signedOut));
  }

  Map<String, dynamic>? getCurrentUserProfile() {
    if (_currentUserId == null) return null;
    return getUserById(_currentUserId!);
  }

  Map<String, dynamic>? getUserById(String id) {
    for (final user in _users) {
      if (user['id'] == id) return Map<String, dynamic>.from(user);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getUsers({
    String? role,
    String? locationId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    var data = _users.map(Map<String, dynamic>.from).toList();
    if (role != null) {
      data = data.where((u) => u['role'] == role).toList();
    }
    if (locationId != null) {
      data = data.where((u) => u['location_id'] == locationId).toList();
    }
    data.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    return data;
  }

  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    for (var i = 0; i < _users.length; i++) {
      if (_users[i]['id'] == id) {
        _users[i] = {..._users[i], ...updates};
        return;
      }
    }
    throw Exception('User not found');
  }

  Future<List<Map<String, dynamic>>> getLocations() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    final data = _locations.map(Map<String, dynamic>.from).toList();
    data.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    return data;
  }

  Future<Map<String, dynamic>> addLocation({
    required String name,
    String? address,
    String? notes,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final map = <String, dynamic>{
      'id': _uuid.v4(),
      'name': name,
      'address': address,
      'notes': notes,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };
    _locations.add(map);
    return Map<String, dynamic>.from(map);
  }

  Future<void> updateLocation(String id, Map<String, dynamic> updates) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    for (var i = 0; i < _locations.length; i++) {
      if (_locations[i]['id'] == id) {
        _locations[i] = {..._locations[i], ...updates};
        return;
      }
    }
    throw Exception('Location not found');
  }

  Future<void> deleteLocation(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    _locations.removeWhere((l) => l['id'] == id);
    for (var i = 0; i < _users.length; i++) {
      if (_users[i]['location_id'] == id) {
        _users[i] = {..._users[i], 'location_id': null};
      }
    }
    for (var i = 0; i < _attendance.length; i++) {
      if (_attendance[i]['location_id'] == id) {
        _attendance[i] = {..._attendance[i], 'location_id': null};
      }
    }
  }

  Future<List<Map<String, dynamic>>> getPosts() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final data = _posts.map(Map<String, dynamic>.from).toList();
    data.sort(
      (a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String),
    );
    return data;
  }

  Future<Map<String, dynamic>?> getPostById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    for (final post in _posts) {
      if (post['id'] == id) return Map<String, dynamic>.from(post);
    }
    return null;
  }

  Future<Map<String, dynamic>> createPost({
    required String title,
    String? description,
    DateTime? date,
    String? imageUrl,
    required String type,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final post = <String, dynamic>{
      'id': _uuid.v4(),
      'title': title,
      'description': description,
      'date': date?.toIso8601String().split('T')[0],
      'image_url': imageUrl,
      'type': type,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };
    _posts.add(post);
    return Map<String, dynamic>.from(post);
  }

  Future<void> deletePost(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    _posts.removeWhere((p) => p['id'] == id);
  }

  Future<void> upsertAttendance({
    required String locationId,
    required DateTime date,
    required Map<String, bool> studentPresenceMap,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    final dateStr = date.toIso8601String().split('T')[0];
    for (final entry in studentPresenceMap.entries) {
      final studentId = entry.key;
      final status = entry.value ? 'present' : 'absent';
      final idx = _attendance.indexWhere(
        (a) => a['student_id'] == studentId && a['date'] == dateStr,
      );
      if (idx == -1) {
        _attendance.add({
          'id': _uuid.v4(),
          'student_id': studentId,
          'location_id': locationId,
          'date': dateStr,
          'status': status,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      } else {
        _attendance[idx] = {
          ..._attendance[idx],
          'location_id': locationId,
          'status': status,
        };
      }
    }
  }

  Future<List<Map<String, dynamic>>> getAttendanceByDateAndLocation({
    required String locationId,
    required DateTime date,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final dateStr = date.toIso8601String().split('T')[0];
    final usersById = {for (final u in _users) u['id'] as String: u};
    return _attendance
        .where((a) => a['location_id'] == locationId && a['date'] == dateStr)
        .map((a) {
          final joined = Map<String, dynamic>.from(a);
          final user = usersById[a['student_id']];
          if (user != null) {
            joined['users'] = {'name': user['name']};
          }
          return joined;
        })
        .toList();
  }

  Future<List<Map<String, dynamic>>> getStudentAttendance(String studentId) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final locationsById = {for (final l in _locations) l['id'] as String: l};
    final data = _attendance
        .where((a) => a['student_id'] == studentId)
        .map((a) {
          final joined = Map<String, dynamic>.from(a);
          final location = locationsById[a['location_id']];
          if (location != null) {
            joined['locations'] = {'name': location['name']};
          }
          return joined;
        })
        .toList();
    data.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    return data;
  }

  Future<List<Map<String, dynamic>>> getAllAttendance() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final usersById = {for (final u in _users) u['id'] as String: u};
    final locationsById = {for (final l in _locations) l['id'] as String: l};
    final data = _attendance.map((a) {
      final joined = Map<String, dynamic>.from(a);
      final user = usersById[a['student_id']];
      final location = locationsById[a['location_id']];
      if (user != null) joined['users'] = {'name': user['name']};
      if (location != null) joined['locations'] = {'name': location['name']};
      return joined;
    }).toList();
    data.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    return data;
  }
}
