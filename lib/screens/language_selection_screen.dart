import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/app_provider.dart';
import '../services/translation_service.dart';
import '../utils/app_theme.dart';
import 'splash_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _detectedLanguage = 'en';
  List<Map<String, String>> _availableLanguages = [];
  Map<String, String> _translatedTexts = {};
  bool _isLoadingTranslations = true;
  String _selectedLanguage = '';
  bool _showNameInput = false;
  final TextEditingController _nameController = TextEditingController();

  // Base texts in English
  final Map<String, String> _baseTexts = {
    'question': "Which language do you speak?",
    'name_question': "What's your name?",
    'name_hint': "Enter your name",
    'continue': "Continue",
    'skip': "Skip",
  };
  
  @override
  void initState() {
    super.initState();
    _initializeLanguageDetection();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _initializeLanguageDetection() async {
    try {
      await _detectDeviceLanguage();
      await _getRegionalLanguages();
      await _translateTextsToLanguages();
    } catch (e) {
      print('Language initialization error: $e');
      _setFallbackLanguages();
    } finally {
      setState(() {
        _isLoadingTranslations = false;
      });
    }
  }

  Future<void> _detectDeviceLanguage() async {
    try {
      final locale = Platform.localeName;
      final languageCode = locale.split('_')[0];
      print('Detected device language: $languageCode');
      _detectedLanguage = languageCode;
    } catch (e) {
      print('Device language detection error: $e');
      _detectedLanguage = 'en';
    }
  }

  Future<void> _getRegionalLanguages() async {
    try {
      List<Map<String, String>> languages;
      
      if (_detectedLanguage == 'hi' || _detectedLanguage.startsWith('hi')) {
        languages = [
          {'code': 'hi', 'english': 'Hindi', 'native': 'हिंदी'},
          {'code': 'en', 'english': 'English', 'native': 'English'},
          {'code': 'pa', 'english': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
          {'code': 'bn', 'english': 'Bengali', 'native': 'বাংলা'},
          {'code': 'mr', 'english': 'Marathi', 'native': 'मराठी'},
          {'code': 'gu', 'english': 'Gujarati', 'native': 'ગુજરાતી'},
        ];
      } else if (_detectedLanguage == 'pa') {
        languages = [
          {'code': 'pa', 'english': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
          {'code': 'hi', 'english': 'Hindi', 'native': 'हिंदी'},
          {'code': 'en', 'english': 'English', 'native': 'English'},
          {'code': 'ur', 'english': 'Urdu', 'native': 'اردو'},
        ];
      } else {
        languages = [
          {'code': 'en', 'english': 'English', 'native': 'English'},
          {'code': 'hi', 'english': 'Hindi', 'native': 'हिंदी'},
          {'code': 'es', 'english': 'Spanish', 'native': 'Español'},
          {'code': 'fr', 'english': 'French', 'native': 'Français'},
          {'code': 'de', 'english': 'German', 'native': 'Deutsch'},
          {'code': 'zh', 'english': 'Chinese', 'native': '中文'},
        ];
      }
      
      _availableLanguages = languages;
    } catch (e) {
      print('Regional languages error: $e');
      _setFallbackLanguages();
    }
  }

  Future<void> _translateTextsToLanguages() async {
    try {
      _translatedTexts.clear();
      
      for (final language in _availableLanguages) {
        final langCode = language['code']!;
        
        for (final textKey in _baseTexts.keys) {
          final baseText = _baseTexts[textKey]!;
          final translationKey = '${langCode}_$textKey';
          
          if (langCode == 'en') {
            _translatedTexts[translationKey] = baseText;
          } else {
            try {
              final translated = await TranslationService.translateText(
                baseText, 
                langCode,
                sourceLanguage: 'en'
              );
              _translatedTexts[translationKey] = translated;
            } catch (e) {
              _translatedTexts[translationKey] = baseText; // Fallback to English
            }
          }
        }
        
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      print('Translated texts: $_translatedTexts');
      
    } catch (e) {
      print('Translation error: $e');
      _setFallbackTranslations();
    }
  }

  void _setFallbackLanguages() {
    _availableLanguages = [
      {'code': 'hi', 'english': 'Hindi', 'native': 'हिंदी'},
      {'code': 'en', 'english': 'English', 'native': 'English'},
      {'code': 'pa', 'english': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
      {'code': 'bn', 'english': 'Bengali', 'native': 'বাংলা'},
      {'code': 'mr', 'english': 'Marathi', 'native': 'मराठी'},
    ];
    
    _setFallbackTranslations();
  }

  void _setFallbackTranslations() {
    _translatedTexts = {
      // Hindi translations
      'hi_question': 'आप कौन सी भाषा बोलते हैं?',
      'hi_name_question': 'आपका नाम क्या है?',
      'hi_name_hint': 'अपना नाम लिखें',
      'hi_continue': 'जारी रखें',
      'hi_skip': 'छोड़ें',
      
      // English translations
      'en_question': 'Which language do you speak?',
      'en_name_question': 'What\'s your name?',
      'en_name_hint': 'Enter your name',
      'en_continue': 'Continue',
      'en_skip': 'Skip',
      
      // Punjabi translations
      'pa_question': 'ਤੁਸੀਂ ਕਿਹੜੀ ਭਾਸ਼ਾ ਬੋਲਦੇ ਹੋ?',
      'pa_name_question': 'ਤੁਹਾਡਾ ਨਾਮ ਕੀ ਹੈ?',
      'pa_name_hint': 'ਆਪਣਾ ਨਾਮ ਲਿਖੋ',
      'pa_continue': 'ਜਾਰੀ ਰੱਖੋ',
      'pa_skip': 'ਛੱਡੋ',
      
      // Bengali translations
      'bn_question': 'আপনি কোন ভাষা বলেন?',
      'bn_name_question': 'আপনার নাম কী?',
      'bn_name_hint': 'আপনার নাম লিখুন',
      'bn_continue': 'চালিয়ে যান',
      'bn_skip': 'এড়িয়ে যান',
      
      // Marathi translations
      'mr_question': 'तुम्ही कोणती भाषा बोलता?',
      'mr_name_question': 'तुमचे नाव काय?',
      'mr_name_hint': 'तुमचे नाव लिहा',
      'mr_continue': 'सुरू ठेवा',
      'mr_skip': 'वगळा',
    };
  }

  String _getTranslatedText(String langCode, String textKey) {
    return _translatedTexts['${langCode}_$textKey'] ?? _baseTexts[textKey] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // App Logo
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.palette,
                      size: 60,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // App Name
                FadeInUp(
                  duration: const Duration(milliseconds: 900),
                  child: const Text(
                    'KalaNirbhar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Content based on current step
                if (_isLoadingTranslations)
                  _buildLoadingScreen()
                else if (!_showNameInput)
                  _buildLanguageSelection()
                else
                  _buildNameInput(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Column(
        children: [
          Container(
            height: 30,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Container(
            height: 25,
            width: MediaQuery.of(context).size.width * 0.8,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            'Detecting your language...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelection() {
    return Column(
      children: [
        // Dynamic Language Questions
        FadeInUp(
          duration: const Duration(milliseconds: 1000),
          child: Column(
            children: _availableLanguages.take(3).map((language) {
              final langCode = language['code']!;
              final question = _getTranslatedText(langCode, 'question');
              final index = _availableLanguages.indexOf(language);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  question,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95 - (index * 0.1)),
                    fontSize: (24 - (index * 2)).toDouble(),
                    fontWeight: index == 0 ? FontWeight.w600 : FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Language Options - Scrollable
        FadeInUp(
          duration: const Duration(milliseconds: 1200),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView.builder(
              itemCount: _availableLanguages.length,
              itemBuilder: (context, index) {
                final language = _availableLanguages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildLanguageOption(
                    context,
                    language['code']!,
                    language['native']!,
                    language['english']!,
                    _getLanguageColor(index),
                  ),
                );
              },
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Skip Option
        FadeInUp(
          duration: const Duration(milliseconds: 1400),
          child: TextButton(
            onPressed: () => _selectLanguage(context, _detectedLanguage),
            child: Text(
              _getSkipText(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameInput() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Column(
        children: [
          // Name question in selected language
          Text(
            _getTranslatedText(_selectedLanguage, 'name_question'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Name input field
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: AppTheme.textDark,
              ),
              decoration: InputDecoration(
                hintText: _getTranslatedText(_selectedLanguage, 'name_hint'),
                hintStyle: const TextStyle(
                  color: AppTheme.textLight,
                  fontFamily: 'Poppins',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Continue and Skip buttons
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () => _proceedToApp(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryBlue,
                      elevation: 8,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _getTranslatedText(_selectedLanguage, 'continue'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Skip name input
          TextButton(
            onPressed: () => _proceedToApp(context),
            child: Text(
              _getTranslatedText(_selectedLanguage, 'skip'),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageCode,
    String nativeText,
    String englishText,
    Color accentColor,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () => _onLanguageSelected(languageCode),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.textDark,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor, width: 2),
              ),
              child: Icon(
                Icons.language,
                color: accentColor,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    englishText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textLight,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios,
              color: accentColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Color _getLanguageColor(int index) {
    const colors = [
      Color(0xFFFF9933), // Saffron/Orange
      Color(0xFF0F4C75), // Blue
      Color(0xFF228B22), // Green
      Color(0xFF800080), // Purple
      Color(0xFFDC143C), // Crimson
      Color(0xFFFF6B35), // Orange Red
    ];
    return colors[index % colors.length];
  }

  String _getSkipText() {
    final skipTexts = _availableLanguages.take(3).map((lang) {
      return _getTranslatedText(lang['code']!, 'skip');
    }).toList();
    
    return skipTexts.join(' / ');
  }

  void _onLanguageSelected(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
      _showNameInput = true;
    });
  }

  void _selectLanguage(BuildContext context, String languageCode) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.changeLanguage(languageCode);
    
    _proceedToApp(context);
  }

  void _proceedToApp(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.changeLanguage(_selectedLanguage);
    
    if (_nameController.text.trim().isNotEmpty) {
      appProvider.setUserName(_nameController.text.trim());
    }
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SplashScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}