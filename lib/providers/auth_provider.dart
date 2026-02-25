import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;

  AuthProvider({AuthService? service}) : _service = service ?? AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _service.isLoggedIn;
  String? get error => _error;
  String? get currentUserId => _service.currentUserId;

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.init();
      if (_service.isLoggedIn) {
        _currentUser = await _service.getCurrentUserProfile();
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _service.signIn(email, password);
      _currentUser = user;
      return user;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _service.signUp(
        email: email,
        password: password,
        name: name,
        age: age,
        beltLevel: beltLevel,
        phone: phone,
        locationId: locationId,
      );
      _currentUser = user;
      return user;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _service.getCurrentUserProfile();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.signOut();
      _currentUser = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
