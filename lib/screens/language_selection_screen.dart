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
  Map<String, String> _translatedQuestions = {};
  bool _isLoadingTranslations = true;

  // Base question in English
  final String _baseQuestion = "Which language do you speak?";
  
  @override
  void initState() {
    super.initState();
    _initializeLanguageDetection();
  }

  Future<void> _initializeLanguageDetection() async {
    try {
      // Detect device language
      await _detectDeviceLanguage();
      
      // Get popular languages for the region
      await _getRegionalLanguages();
      
      // Translate the question to multiple languages
      await _translateQuestionToLanguages();
      
    } catch (e) {
      print('Language initialization error: $e');
      // Fallback to default languages
      _setFallbackLanguages();
    } finally {
      setState(() {
        _isLoadingTranslations = false;
      });
    }
  }

  Future<void> _detectDeviceLanguage() async {
    try {
      // Get device locale
      final locale = Platform.localeName; // e.g., 'en_US', 'hi_IN', 'pa_IN'
      final languageCode = locale.split('_')[0]; // Extract 'en', 'hi', 'pa'
      
      print('Detected device language: $languageCode');
      _detectedLanguage = languageCode;
    } catch (e) {
      print('Device language detection error: $e');
      _detectedLanguage = 'en'; // Default fallback
    }
  }

  Future<void> _getRegionalLanguages() async {
    try {
      // Based on detected language/region, get popular languages
      List<Map<String, String>> languages;
      
      if (_detectedLanguage == 'hi' || _detectedLanguage.startsWith('hi')) {
        // Indian region - popular languages
        languages = [
          {'code': 'hi', 'english': 'Hindi', 'native': 'हिंदी'},
          {'code': 'en', 'english': 'English', 'native': 'English'},
          {'code': 'pa', 'english': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
          {'code': 'bn', 'english': 'Bengali', 'native': 'বাংলা'},
          {'code': 'mr', 'english': 'Marathi', 'native': 'मराठी'},
        ];
      } else if (_detectedLanguage == 'pa') {
        // Punjabi region
        languages = [
          {'code': 'pa', 'english': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
          {'code': 'hi', 'english': 'Hindi', 'native': 'हिंदी'},
          {'code': 'en', 'english': 'English', 'native': 'English'},
        ];
      } else {
        // Default/International
        languages = [
          {'code': 'en', 'english': 'English', 'native': 'English'},
          {'code': 'hi', 'english': 'Hindi', 'native': 'हिंदी'},
          {'code': 'es', 'english': 'Spanish', 'native': 'Español'},
          {'code': 'fr', 'english': 'French', 'native': 'Français'},
          {'code': 'de', 'english': 'German', 'native': 'Deutsch'},
        ];
      }
      
      _availableLanguages = languages.take(3).toList(); // Show top 3
    } catch (e) {
      print('Regional languages error: $e');
      _setFallbackLanguages();
    }
  }

  Future<void> _translateQuestionToLanguages() async {
    try {
      _translatedQuestions.clear();
      
      for (final language in _availableLanguages) {
        final langCode = language['code']!;
        
        if (langCode == 'en') {
          _translatedQuestions[langCode] = _baseQuestion;
        } else {
          // Use Google Cloud Translation API
          final translated = await TranslationService.translateText(
            _baseQuestion, 
            langCode,
            sourceLanguage: 'en'
          );
          _translatedQuestions[langCode] = translated;
        }
        
        // Add small delay to respect API rate limits
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      print('Translated questions: $_translatedQuestions');
      
    } catch (e) {
      print('Translation error: $e');
      // Fallback translations
      _translatedQuestions = {
        'hi': 'आप कौन सी भाषा बोलते हैं?',
        'en': 'Which language do you speak?',
        'pa': 'ਤੁਸੀਂ ਕਿਹੜੀ ਭਾਸ਼ਾ ਬੋਲਦੇ ਹੋ?',
      };
    }
  }

  void _setFallbackLanguages() {
    _availableLanguages = [
      {'code': 'hi', 'english': 'Hindi', 'native': 'हिंदी'},
      {'code': 'en', 'english': 'English', 'native': 'English'},
      {'code': 'pa', 'english': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
    ];
    
    _translatedQuestions = {
      'hi': 'आप कौन सी भाषा बोलते हैं?',
      'en': 'Which language do you speak?',
      'pa': 'ਤੁਸੀਂ ਕਿਹੜੀ ਭਾਸ਼ਾ ਬੋਲਦੇ ਹੋ?',
    };
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
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
                
                // Dynamic Language Questions
                if (_isLoadingTranslations)
                  _buildLoadingQuestions()
                else
                  _buildTranslatedQuestions(),
                
                const SizedBox(height: 60),
                
                // Dynamic Language Options
                if (!_isLoadingTranslations)
                  FadeInUp(
                    duration: const Duration(milliseconds: 1200),
                    child: Column(
                      children: _availableLanguages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final language = entry.value;
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
                      }).toList(),
                    ),
                  ),
                
                const Spacer(flex: 3),
                
                // Skip Option (translated)
                if (!_isLoadingTranslations)
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingQuestions() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Column(
        children: [
          // Shimmer loading effect for questions
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
          Container(
            height: 22,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
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

  Widget _buildTranslatedQuestions() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Column(
        children: _availableLanguages.asMap().entries.map((entry) {
          final index = entry.key;
          final language = entry.value;
          final langCode = language['code']!;
          final question = _translatedQuestions[langCode] ?? _baseQuestion;
          
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
        onPressed: () => _selectLanguage(context, languageCode),
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
    ];
    return colors[index % colors.length];
  }

  String _getSkipText() {
    if (_availableLanguages.length >= 3) {
      final skip1 = _translatedQuestions[_availableLanguages[0]['code']] != null ? 'Skip' : 'छोड़ें';
      final skip2 = _translatedQuestions[_availableLanguages[1]['code']] != null ? 'Skip' : 'छोड़ें'; 
      final skip3 = _translatedQuestions[_availableLanguages[2]['code']] != null ? 'Skip' : 'ਛੱਡੋ';
      return '$skip1 / $skip2 / $skip3';
    }
    return 'Skip / छोड़ें / ਛੱਡੋ';
  }

  void _selectLanguage(BuildContext context, String languageCode) {
    // Set the language in the app provider
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.changeLanguage(languageCode);
    
    // Navigate to splash screen and then main app
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