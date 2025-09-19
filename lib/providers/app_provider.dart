import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _selectedLanguage = 'hi';
  int _currentTabIndex = 0;
  String _userName = '';

  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;
  int get currentTabIndex => _currentTabIndex;
  String get userName => _userName;

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

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  // Get localized greeting based on language and time
  String getGreeting() {
    final hour = DateTime.now().hour;
    String greeting = '';
    
    if (hour < 12) {
      switch (_selectedLanguage) {
        case 'hi':
          greeting = 'सुप्रभात';
          break;
        case 'pa':
          greeting = 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ';
          break;
        case 'bn':
          greeting = 'সুপ্রভাত';
          break;
        case 'mr':
          greeting = 'सुप्रभात';
          break;
        default:
          greeting = 'Good Morning';
      }
    } else if (hour < 17) {
      switch (_selectedLanguage) {
        case 'hi':
          greeting = 'नमस्ते';
          break;
        case 'pa':
          greeting = 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ';
          break;
        case 'bn':
          greeting = 'নমস্কার';
          break;
        case 'mr':
          greeting = 'नमस्कार';
          break;
        default:
          greeting = 'Good Afternoon';
      }
    } else {
      switch (_selectedLanguage) {
        case 'hi':
          greeting = 'शुभ संध्या';
          break;
        case 'pa':
          greeting = 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ';
          break;
        case 'bn':
          greeting = 'শুভ সন্ধ্যা';
          break;
        case 'mr':
          greeting = 'शुभ संध्या';
          break;
        default:
          greeting = 'Good Evening';
      }
    }
    
    if (_userName.isNotEmpty) {
      switch (_selectedLanguage) {
        case 'hi':
          return '$greeting, ${_userName} जी';
        case 'pa':
          return '$greeting, ${_userName} ਜੀ';
        case 'bn':
          return '$greeting, ${_userName} জি';
        case 'mr':
          return '$greeting, ${_userName} जी';
        default:
          return '$greeting, $_userName';
      }
    }
    
    return greeting;
  }
}