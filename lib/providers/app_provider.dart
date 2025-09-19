import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _selectedLanguage = 'hi';
  int _currentTabIndex = 0;

  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;
  int get currentTabIndex => _currentTabIndex;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void changeLanguage(String languageCode) {
    _selectedLanguage = languageCode;
    notifyListeners();
  }

  void setCurrentTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }
}