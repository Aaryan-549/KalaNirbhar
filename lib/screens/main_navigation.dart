import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/dynamic_localization_service.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'marketplace_screen.dart';
import 'ai_assistant_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  Map<String, String> _navTexts = {};

  final List<Widget> _screens = [
    const HomeScreen(),
    const MarketplaceScreen(),
    const AIAssistantScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadNavigationTexts();
  }

  Future<void> _loadNavigationTexts() async {
    final texts = <String, String>{};
    final keys = ['home', 'marketplace', 'assistant', 'profile'];
    
    for (final key in keys) {
      texts[key] = await DynamicLocalizationService.getText(key);
    }
    
    if (mounted) {
      setState(() {
        _navTexts = texts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Reload texts when language changes
        if (_navTexts.isEmpty) {
          _loadNavigationTexts();
        }
        
        return Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withOpacity(.1),
                )
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: GNav(
                  rippleColor: AppTheme.primaryBlue.withOpacity(0.1),
                  hoverColor: AppTheme.primaryBlue.withOpacity(0.1),
                  gap: 8,
                  activeColor: Colors.white,
                  iconSize: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: AppTheme.primaryBlue,
                  color: AppTheme.textLight,
                  tabs: [
                    GButton(
                      icon: Icons.home_rounded,
                      text: _navTexts['home'] ?? 'Home',
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    GButton(
                      icon: Icons.store_rounded,
                      text: _navTexts['marketplace'] ?? 'Marketplace',
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    GButton(
                      icon: Icons.smart_toy_rounded,
                      text: _navTexts['assistant'] ?? 'Assistant',
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    GButton(
                      icon: Icons.person_rounded,
                      text: _navTexts['profile'] ?? 'Profile',
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  selectedIndex: _selectedIndex,
                  onTabChange: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}