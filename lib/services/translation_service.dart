import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/google_cloud_config.dart';

class TranslationService {
  
  // Translate text between languages
  static Future<String> translateText(String text, String targetLanguage, {String sourceLanguage = 'auto'}) async {
    try {
      final response = await http.post(
        Uri.parse('${GoogleCloudConfig.translationEndpoint}?key=${GoogleCloudConfig.translationApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': text,
          'target': targetLanguage,
          'source': sourceLanguage == 'auto' ? null : sourceLanguage,
          'format': 'text',
          'model': 'base' // or 'nmt' for neural machine translation
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translations = data['data']['translations'] as List;
        if (translations.isNotEmpty) {
          return translations[0]['translatedText'] ?? text;
        }
      } else {
        print('Translation Error: ${response.statusCode} - ${response.body}');
      }
      return text; // Return original text if translation fails
    } catch (e) {
      print('Translation Service Error: $e');
      return text;
    }
  }

  // Batch translate multiple texts
  static Future<List<String>> batchTranslateTexts(List<String> texts, String targetLanguage, {String sourceLanguage = 'auto'}) async {
    try {
      final response = await http.post(
        Uri.parse('${GoogleCloudConfig.translationEndpoint}?key=${GoogleCloudConfig.translationApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': texts,
          'target': targetLanguage,
          'source': sourceLanguage == 'auto' ? null : sourceLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translations = data['data']['translations'] as List;
        return translations.map((t) => t['translatedText'] as String).toList();
      } else {
        print('Batch Translation Error: ${response.statusCode} - ${response.body}');
      }
      return texts; // Return original texts if translation fails
    } catch (e) {
      print('Batch Translation Error: $e');
      return texts;
    }
  }

  // Detect language of text
  static Future<String> detectLanguage(String text) async {
    try {
      final response = await http.post(
        Uri.parse('https://translation.googleapis.com/language/translate/v2/detect?key=${GoogleCloudConfig.translationApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final detections = data['data']['detections'] as List;
        if (detections.isNotEmpty && detections[0] is List && detections[0].isNotEmpty) {
          return detections[0][0]['language'] ?? 'unknown';
        }
      }
      return 'unknown';
    } catch (e) {
      print('Language Detection Error: $e');
      return 'unknown';
    }
  }

  // Get supported languages
  static Future<List<Map<String, String>>> getSupportedLanguages() async {
    try {
      final response = await http.get(
        Uri.parse('https://translation.googleapis.com/language/translate/v2/languages?key=${GoogleCloudConfig.translationApiKey}&target=en'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final languages = data['data']['languages'] as List;
        return languages.map((lang) => {
          'code': lang['language'] as String,
          'name': lang['name'] as String,
        }).toList();
      }
    } catch (e) {
      print('Get Supported Languages Error: $e');
    }
    
    // Fallback to hardcoded list
    return GoogleCloudConfig.supportedLanguages.entries.map((entry) => {
      'code': entry.key,
      'name': entry.value,
    }).toList();
  }

  // Translate UI elements for app localization
  static Future<Map<String, String>> translateUIElements(Map<String, String> uiTexts, String targetLanguage) async {
    final List<String> textsToTranslate = uiTexts.values.toList();
    final List<String> keys = uiTexts.keys.toList();
    
    final translatedTexts = await batchTranslateTexts(textsToTranslate, targetLanguage);
    
    final Map<String, String> result = {};
    for (int i = 0; i < keys.length; i++) {
      result[keys[i]] = translatedTexts[i];
    }
    
    return result;
  }

  // Smart translation with context awareness
  static Future<String> contextAwareTranslation(String text, String targetLanguage, String context) async {
    // Add context to improve translation quality
    final contextualText = 'Context: $context. Text: $text';
    
    final translation = await translateText(contextualText, targetLanguage);
    
    // Remove context prefix from translation
    if (translation.contains('Text: ')) {
      return translation.split('Text: ').last;
    }
    
    return translation;
  }

  // Validate translation quality
  static Future<double> getTranslationConfidence(String originalText, String translatedText, String targetLanguage) async {
    // Back-translate to check quality
    final backTranslation = await translateText(translatedText, 'en', sourceLanguage: targetLanguage);
    
    // Simple similarity check (in production, you'd use more sophisticated methods)
    final similarity = _calculateStringSimilarity(originalText.toLowerCase(), backTranslation.toLowerCase());
    
    return similarity;
  }

  static double _calculateStringSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    
    final longer = s1.length > s2.length ? s1 : s2;
    final shorter = s1.length > s2.length ? s2 : s1;
    
    final editDistance = _levenshteinDistance(longer, shorter);
    return (longer.length - editDistance) / longer.length;
  }

  static int _levenshteinDistance(String s1, String s2) {
    final matrix = List.generate(s1.length + 1, (i) => List.filled(s2.length + 1, 0));
    
    for (int i = 0; i <= s1.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= s2.length; j++) matrix[0][j] = j;
    
    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    
    return matrix[s1.length][s2.length];
  }
}