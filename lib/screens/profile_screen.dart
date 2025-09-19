import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_theme.dart';
import '../services/translation_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, Map<String, String>> _localizedTexts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalizedTexts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appProvider = Provider.of<AppProvider>(context);
    if (_localizedTexts[appProvider.selectedLanguage] == null) {
      _loadLocalizedTexts();
    }
  }

  Future<void> _loadLocalizedTexts() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentLang = appProvider.selectedLanguage;
    
    if (_localizedTexts[currentLang] != null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final texts = <String, String>{};
    
    // Fallback translations for all profile texts
    final fallbackTexts = {
      'hi': {
        'profile': 'प्रोफ़ाइल',
        'achievements': 'आपकी उपलब्धियां',
        'total_products': 'कुल उत्पाद',
        'total_sales': 'कुल बिक्री',
        'orders': 'ऑर्डर',
        'views': 'व्यू',
        'change_language': 'भाषा बदलें',
        'theme': 'थीम',
        'light_mode': 'लाइट मोड',
        'dark_mode': 'डार्क मोड',
        'notifications': 'सूचनाएं',
        'on': 'चालू',
        'off': 'बंद',
        'data_security': 'डेटा सुरक्षा',
        'help_center': 'सहायता केंद्र',
        'give_feedback': 'फीडबैक दें',
        'about_app': 'ऐप के बारे में',
        'logout': 'लॉग आउट',
        'meenakaari_artist': 'मीनाकारी कलाकार',
        'handicraft_artist': 'हस्तशिल्प कलाकार',
        'traditional_artist': 'पारंपरिक कलाकार',
      },
      'en': {
        'profile': 'Profile',
        'achievements': 'Your Achievements',
        'total_products': 'Total Products',
        'total_sales': 'Total Sales',
        'orders': 'Orders',
        'views': 'Views',
        'change_language': 'Change Language',
        'theme': 'Theme',
        'light_mode': 'Light Mode',
        'dark_mode': 'Dark Mode',
        'notifications': 'Notifications',
        'on': 'On',
        'off': 'Off',
        'data_security': 'Data Security',
        'help_center': 'Help Center',
        'give_feedback': 'Give Feedback',
        'about_app': 'About App',
        'logout': 'Logout',
        'meenakaari_artist': 'Meenakaari Artist',
        'handicraft_artist': 'Handicraft Artist',
        'traditional_artist': 'Traditional Artist',
      },
      'pa': {
        'profile': 'ਪ੍ਰੋਫਾਈਲ',
        'achievements': 'ਤੁਹਾਡੀਆਂ ਪ੍ਰਾਪਤੀਆਂ',
        'total_products': 'ਕੁੱਲ ਉਤਪਾਦ',
        'total_sales': 'ਕੁੱਲ ਵਿਕਰੀ',
        'orders': 'ਆਰਡਰ',
        'views': 'ਦ੍ਰਿਸ਼',
        'change_language': 'ਭਾਸ਼ਾ ਬਦਲੋ',
        'theme': 'ਥੀਮ',
        'light_mode': 'ਲਾਈਟ ਮੋਡ',
        'notifications': 'ਸੂਚਨਾਵਾਂ',
        'on': 'ਚਾਲੂ',
        'off': 'ਬੰਦ',
        'data_security': 'ਡੇਟਾ ਸੁਰੱਖਿਆ',
        'help_center': 'ਸਹਾਇਤਾ ਕੇਂਦਰ',
        'give_feedback': 'ਫੀਡਬੈਕ ਦਿਓ',
        'about_app': 'ਐਪ ਬਾਰੇ',
        'logout': 'ਲਾਗ ਆਊਟ',
        'handicraft_artist': 'ਹਸਤਸ਼ਿਲਪ ਕਲਾਕਾਰ',
      },
      'bn': {
        'profile': 'প্রোফাইল',
        'achievements': 'আপনার অর্জন',
        'total_products': 'মোট পণ্য',
        'total_sales': 'মোট বিক্রয়',
        'orders': 'অর্ডার',
        'views': 'দেখা',
        'change_language': 'ভাষা পরিবর্তন করুন',
        'theme': 'থিম',
        'light_mode': 'লাইট মোড',
        'notifications': 'বিজ্ঞপ্তি',
        'on': 'চালু',
        'off': 'বন্ধ',
        'data_security': 'ডেটা নিরাপত্তা',
        'help_center': 'সহায়তা কেন্দ্র',
        'give_feedback': 'মতামত দিন',
        'about_app': 'অ্যাপ সম্পর্কে',
        'logout': 'লগ আউট',
        'handicraft_artist': 'হস্তশিল্প শিল্পী',
      },
    };

    texts.addAll(fallbackTexts[currentLang] ?? fallbackTexts['en']!);

    // Try to get translations from service if available
    try {
      for (final key in fallbackTexts['en']!.keys) {
        if (currentLang != 'en') {
          try {
            final translated = await TranslationService.translateText(
              fallbackTexts['en']![key]!,
              currentLang,
              sourceLanguage: 'en'
            );
            texts[key] = translated;
          } catch (e) {
            print('Translation error for $key: $e');
          }
        }
      }
    } catch (e) {
      print('Translation service error: $e');
    }

    if (mounted) {
      setState(() {
        _localizedTexts[currentLang] = texts;
        _isLoading = false;
      });
    }
  }

  String _getText(String key) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentLang = appProvider.selectedLanguage;
    return _localizedTexts[currentLang]?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildStatsSection(),
                        const SizedBox(height: 30),
                        _buildSettingsSection(),
                        const SizedBox(height: 30),
                        _buildHelpSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer2<AppProvider, AuthProvider>(
      builder: (context, appProvider, authProvider, child) {
        final userName = appProvider.userName.isNotEmpty 
            ? appProvider.userName 
            : (authProvider.userName.isNotEmpty ? authProvider.userName : 'User');
        
        final userLocation = authProvider.userLocation.isNotEmpty 
            ? authProvider.userLocation 
            : 'India';

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    _getText('profile'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // TODO: Implement edit profile
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userLocation,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getText('handicraft_artist'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getText('achievements'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      _getText('total_products'),
                      '${productProvider.products?.length ?? 12}',
                      Icons.inventory,
                      AppTheme.primaryBlue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      _getText('total_sales'),
                      '₹${productProvider.getTotalRevenue?.call()?.toInt() ?? 45230}',
                      Icons.monetization_on,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      _getText('orders'),
                      '${productProvider.getTotalSales?.call() ?? 127}',
                      Icons.shopping_cart,
                      AppTheme.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      _getText('views'),
                      '${productProvider.getTotalViews?.call() ?? 2845}',
                      Icons.visibility,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textLight,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingItem(
                _getText('change_language'),
                _getLanguageDisplayName(appProvider.selectedLanguage),
                Icons.language,
                () => _showLanguageSelector(),
              ),
              _buildSettingItem(
                _getText('theme'),
                appProvider.isDarkMode ? _getText('dark_mode') : _getText('light_mode'),
                Icons.brightness_6,
                () => appProvider.toggleTheme(),
              ),
              _buildSettingItem(
                _getText('notifications'),
                _getText('on'),
                Icons.notifications,
                () {
                  // TODO: Implement notification settings
                },
              ),
              _buildSettingItem(
                _getText('data_security'),
                '',
                Icons.security,
                () {
                  // TODO: Implement data security settings
                },
                showArrow: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHelpSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            _getText('help_center'),
            '',
            Icons.help_outline,
            () {
              // TODO: Implement help center
            },
            showArrow: true,
          ),
          _buildSettingItem(
            _getText('give_feedback'),
            '',
            Icons.feedback,
            () {
              // TODO: Implement feedback
            },
            showArrow: true,
          ),
          _buildSettingItem(
            _getText('about_app'),
            'v1.0.0',
            Icons.info_outline,
            () {
              // TODO: Implement about app
            },
          ),
          _buildSettingItem(
            _getText('logout'),
            '',
            Icons.logout,
            () => _showLogoutConfirmation(),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool showArrow = false,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? AppTheme.primaryBlue,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color ?? AppTheme.textDark,
          fontFamily: 'Poppins',
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
                fontFamily: 'Poppins',
              ),
            )
          : null,
      trailing: showArrow
          ? const Icon(
              Icons.chevron_right,
              color: AppTheme.textLight,
            )
          : null,
      onTap: onTap,
    );
  }

  String _getLanguageDisplayName(String languageCode) {
    final languageNames = {
      'hi': 'हिंदी',
      'en': 'English',
      'pa': 'ਪੰਜਾਬੀ',
      'bn': 'বাংলা',
      'mr': 'मराठी',
      'gu': 'ગુજરાતી',
    };
    return languageNames[languageCode] ?? 'English';
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getText('change_language'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              
              _buildLanguageOption('हिंदी', 'Hindi', 'hi'),
              _buildLanguageOption('English', 'English', 'en'),
              _buildLanguageOption('ਪੰਜਾਬੀ', 'Punjabi', 'pa'),
              _buildLanguageOption('বাংলা', 'Bengali', 'bn'),
              _buildLanguageOption('मराठी', 'Marathi', 'mr'),
              _buildLanguageOption('ગુજરાતી', 'Gujarati', 'gu'),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String native, String english, String code) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final isSelected = appProvider.selectedLanguage == code;
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            code.toUpperCase(),
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
      title: Text(
        native,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
        ),
      ),
      subtitle: Text(
        english,
        style: const TextStyle(
          fontFamily: 'Poppins',
          color: AppTheme.textLight,
        ),
      ),
      trailing: isSelected 
          ? const Icon(Icons.check_circle, color: AppTheme.primaryBlue)
          : null,
      onTap: () {
        appProvider.changeLanguage(code);
        Navigator.pop(context);
        _loadLocalizedTexts(); // Reload texts for new language
      },
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            _getText('logout'),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?', // This would need translation too
            style: const TextStyle(
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppTheme.textLight,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement actual logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                _getText('logout'),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}