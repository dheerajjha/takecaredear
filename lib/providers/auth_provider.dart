import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool _isAuthenticated = false;
  String? _userId;
  String? _userEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userEmail => _userEmail;

  Future<bool> login(String email, String password) async {
    try {
      // TODO: Implement actual authentication logic
      await _storage.write(key: 'email', value: email);
      await _storage.write(
          key: 'userId',
          value: 'user_${DateTime.now().millisecondsSinceEpoch}');
      _isAuthenticated = true;
      _userEmail = email;
      _userId = await _storage.read(key: 'userId');
      notifyListeners();
      return true;
    } catch (e) {
      _isAuthenticated = false;
      return false;
    }
  }

  Future<bool> signup(String email, String password, String name) async {
    try {
      // TODO: Implement actual signup logic
      await _storage.write(key: 'email', value: email);
      await _storage.write(
          key: 'userId',
          value: 'user_${DateTime.now().millisecondsSinceEpoch}');
      _isAuthenticated = true;
      _userEmail = email;
      _userId = await _storage.read(key: 'userId');
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _isAuthenticated = false;
    _userId = null;
    _userEmail = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final email = await _storage.read(key: 'email');
    final userId = await _storage.read(key: 'userId');
    if (email != null && userId != null) {
      _isAuthenticated = true;
      _userEmail = email;
      _userId = userId;
      notifyListeners();
    }
  }
}
