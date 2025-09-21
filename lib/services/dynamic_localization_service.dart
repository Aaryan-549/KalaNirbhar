import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'translation_service.dart';

class DynamicLocalizationService {
  static final Map<String, Map<String, String>> _translationCache = {};
  static String _currentLanguage = 'en';
  static const String _cachePrefix = 'translation_cache_';

  // Base English text that will be translated dynamically
  static const Map<String, String> _baseTexts = {
    // Navigation
    'home': 'Home',
    'marketplace': 'Marketplace', 
    'assistant': 'Assistant',
    'profile': 'Profile',

    // Home Screen
    'welcome_message': 'Hello, Priya ji',
    'business_question': 'How is your business doing today?',
    'daily_summary': 'Today\'s Summary',
    'today_sales': 'Today\'s Sales',
    'new_orders': 'New Orders',
    'main_services': 'Main Services',
    'recent_activity': 'Recent Activity',

    // Features
    'image_enhancement': 'Image Enhancement',
    'improve_photos': 'Make photos better',
    'storyteller': 'Storyteller',
    'write_descriptions': 'Write product descriptions',
    'security_shield': 'Security Shield',
    'digital_certificates': 'Digital Certificates',
    'marketing_assistant': 'Marketing Assistant',
    'marketing_help': 'Marketing Help',

    // AI Assistant
    'saral_baatcheet': 'Simple Conversation',
    'thinking': 'Thinking...',
    'ready_to_help': 'Ready to help you',
    'ask_question': 'Ask your question...',
    'listening': 'Listening...',
    'continue_speaking': 'Continue speaking',
    'stop': 'Stop',

    // Actions
    'ok': 'OK',
    'cancel': 'Cancel',
    'close': 'Close',
    'save': 'Save',
    'share': 'Share',
    'edit': 'Edit',
    'delete': 'Delete',
    'view': 'View',

    // Product Management
    'add_product': 'Add Product',
    'products': 'Products',
    'analytics': 'Analytics',
    'certificate': 'Certificate',

    // Profile
    'achievements': 'Your Achievements',
    'total_products': 'Total Products',
    'total_sales': 'Total Sales',
    'orders': 'Orders',
    'views': 'Views',
    'change_language': 'Change Language',
    'theme': 'Theme',
    'light_mode': 'Light Mode',
    'notifications': 'Notifications',
    'on': 'On',
    'data_security': 'Data Security',
    'help_center': 'Help Center',
    'give_feedback': 'Give Feedback',
    'about_app': 'About App',
    'logout': 'Log Out',

    // Activity
    'certificate_received': 'Meenakari vase received new certificate',
    'new_order_amazon': 'New order received on Amazon',
    'collaboration_proposal': 'Ramesh ji sent collaboration proposal',
    'hours_ago': 'hours ago',
    'day_ago': 'day ago',

    // Certificate
    'digital_certificate': 'Digital Certificate',
    'certificate_description': 'This product has a verified digital certificate stored on blockchain.',
    'view_certificate': 'View Certificate',

    // Messages
    'feature_coming_soon': 'This feature is coming soon! For now, talk to the AI assistant.',
    'ai_assistant': 'AI Assistant',

    // Location/Artist Info
    'meenakari_artist': 'Meenakari Artist',
    'jaipur_rajasthan': 'Jaipur, Rajasthan',

    // App
    'app_tagline': 'KalaNirbhar',
    'preparing_for_you': 'Preparing for you...',
    'artisan_marketplace': 'AI-Powered Marketplace for Artisans',
  };

  // Initialize localization service
  static Future<void> initialize(String languageCode) async {
    _currentLanguage = languageCode;
    await _loadCachedTranslations();
    
    // If not English, translate all texts
    if (languageCode != 'en') {
      await _translateAllTexts(languageCode);
    }
  }

  // Get text with automatic translation
  static Future<String> getText(String key) async {
    // If English, return base text
    if (_currentLanguage == 'en') {
      return _baseTexts[key] ?? key;
    }

    // Check cache first
    if (_translationCache[_currentLanguage]?.containsKey(key) == true) {
      return _translationCache[_currentLanguage]![key]!;
    }

    // Translate on-demand
    final baseText = _baseTexts[key];
    if (baseText != null) {
      try {
        final translated = await TranslationService.translateText(
          baseText, 
          _currentLanguage,
          sourceLanguage: 'en'
        );
        
        // Cache the translation
        _cacheTranslation(key, translated);
        return translated;
      } catch (e) {
        print('Translation error for key $key: $e');
        return baseText; // Fallback to English
      }
    }

    return key; // Return key if no base text found
  }

  // Get text synchronously (returns cached or English)
  static String getTextSync(String key) {
    if (_currentLanguage == 'en') {
      return _baseTexts[key] ?? key;
    }

    // Return cached translation or English fallback
    return _translationCache[_currentLanguage]?[key] ?? 
           _baseTexts[key] ?? 
           key;
  }

  // Change language and retranslate
  static Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;
    
    _currentLanguage = languageCode;
    await _loadCachedTranslations();
    
    if (languageCode != 'en') {
      await _translateAllTexts(languageCode);
    }
  }

  static Future<String> translateText(String text, String targetLanguage) async {
  try {
    return await TranslationService.translateText(
      text,
      targetLanguage,
      sourceLanguage: 'en'
    );
  } catch (e) {
    print('DynamicLocalizationService translation error: $e');
    return text; // Return original text if translation fails
  }
}

  // Translate all texts at once (for better performance)
  static Future<void> _translateAllTexts(String languageCode) async {
    try {
      final textsToTranslate = _baseTexts.values.toList();
      final keys = _baseTexts.keys.toList();
      
      // Batch translate for efficiency
      final translations = await TranslationService.batchTranslateTexts(
        textsToTranslate, 
        languageCode,
        sourceLanguage: 'en'
      );
      
      // Cache all translations
      _translationCache[languageCode] = {};
      for (int i = 0; i < keys.length && i < translations.length; i++) {
        _translationCache[languageCode]![keys[i]] = translations[i];
      }
      
      // Save to persistent storage
      await _saveCachedTranslations();
      
    } catch (e) {
      print('Batch translation error: $e');
    }
  }

  // Cache translation
  static void _cacheTranslation(String key, String translation) {
    _translationCache[_currentLanguage] ??= {};
    _translationCache[_currentLanguage]![key] = translation;
    _saveCachedTranslations(); // Save to persistent storage
  }

  // Load cached translations from storage
  static Future<void> _loadCachedTranslations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$_currentLanguage';
      final cachedJson = prefs.getString(cacheKey);
      
      if (cachedJson != null) {
        final Map<String, dynamic> cached = jsonDecode(cachedJson);
        _translationCache[_currentLanguage] = cached.cast<String, String>();
      }
    } catch (e) {
      print('Load cache error: $e');
    }
  }

  // Save cached translations to storage
  static Future<void> _saveCachedTranslations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$_currentLanguage';
      
      if (_translationCache[_currentLanguage] != null) {
        final jsonString = jsonEncode(_translationCache[_currentLanguage]);
        await prefs.setString(cacheKey, jsonString);
      }
    } catch (e) {
      print('Save cache error: $e');
    }
  }

  // Get supported languages from Google Cloud
  static Future<List<Map<String, String>>> getSupportedLanguages() async {
    try {
      return await TranslationService.getSupportedLanguages();
    } catch (e) {
      // Fallback to common languages
      return [
        {'code': 'en', 'name': 'English'},
        {'code': 'hi', 'name': 'Hindi'},
        {'code': 'pa', 'name': 'Punjabi'},
        {'code': 'bn', 'name': 'Bengali'},
        {'code': 'mr', 'name': 'Marathi'},
        {'code': 'ta', 'name': 'Tamil'},
        {'code': 'te', 'name': 'Telugu'},
        {'code': 'gu', 'name': 'Gujarati'},
        {'code': 'kn', 'name': 'Kannada'},
        {'code': 'ml', 'name': 'Malayalam'},
        {'code': 'es', 'name': 'Spanish'},
        {'code': 'fr', 'name': 'French'},
        {'code': 'de', 'name': 'German'},
        {'code': 'zh', 'name': 'Chinese'},
        {'code': 'ja', 'name': 'Japanese'},
        {'code': 'ko', 'name': 'Korean'},
        {'code': 'ar', 'name': 'Arabic'},
        {'code': 'ru', 'name': 'Russian'},
        {'code': 'pt', 'name': 'Portuguese'},
        {'code': 'it', 'name': 'Italian'},
      ];
    }
  }

  // Get current language
  static String getCurrentLanguage() => _currentLanguage;

  // Check if translation is available offline
  static bool hasOfflineTranslation(String key) {
    return _translationCache[_currentLanguage]?.containsKey(key) == true;
  }

  // Get translation progress
  static double getTranslationProgress() {
    if (_currentLanguage == 'en') return 1.0;
    
    final totalKeys = _baseTexts.length;
    final translatedKeys = _translationCache[_currentLanguage]?.length ?? 0;
    
    return translatedKeys / totalKeys;
  }

  // Preload translations for better UX
  static Future<void> preloadTranslations(List<String> keys) async {
    final untranslatedKeys = keys.where((key) => 
      !hasOfflineTranslation(key) && _baseTexts.containsKey(key)
    ).toList();
    
    if (untranslatedKeys.isEmpty) return;
    
    try {
      final textsToTranslate = untranslatedKeys
          .map((key) => _baseTexts[key]!)
          .toList();
      
      final translations = await TranslationService.batchTranslateTexts(
        textsToTranslate, 
        _currentLanguage,
        sourceLanguage: 'en'
      );
      
      for (int i = 0; i < untranslatedKeys.length && i < translations.length; i++) {
        _cacheTranslation(untranslatedKeys[i], translations[i]);
      }
      
    } catch (e) {
      print('Preload translations error: $e');
    }
  }

  // Clear cache for a specific language
  static Future<void> clearLanguageCache(String languageCode) async {
    _translationCache.remove(languageCode);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$languageCode';
      await prefs.remove(cacheKey);
    } catch (e) {
      print('Clear cache error: $e');
    }
  }

  // Get cache size info
  static Map<String, int> getCacheInfo() {
    return _translationCache.map((lang, translations) => 
      MapEntry(lang, translations.length)
    );
  }
}