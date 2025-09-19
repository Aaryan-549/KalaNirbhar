import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = 'प्रिया शर्मा';
  String _userEmail = 'priya@example.com';
  String _userLocation = 'जयपुर, राजस्थान';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userLocation => _userLocation;

  Future<void> login(String email, String password) async {
    // Simulate login process
    await Future.delayed(const Duration(seconds: 2));
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    notifyListeners();
  }
}