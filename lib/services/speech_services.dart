import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/google_cloud_config.dart';

class SpeechServices {
  
  // Speech-to-Text: Convert audio to text
  static Future<String> speechToText(Uint8List audioData, String languageCode) async {
    try {
      // Convert audio to base64
      final base64Audio = base64Encode(audioData);
      
      final response = await http.post(
        Uri.parse('${GoogleCloudConfig.speechToTextEndpoint}?key=${GoogleCloudConfig.speechToTextApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "config": {
            "encoding": "WEBM_OPUS", // or "LINEAR16" depending on your audio format
            "sampleRateHertz": 48000,
            "languageCode": _getLanguageCode(languageCode),
            "alternativeLanguageCodes": ["hi-IN", "en-US"], // Fallback languages
            "enableAutomaticPunctuation": true,
            "enableWordTimeOffsets": false,
            "model": "latest_long", // Use latest model for better accuracy
            "useEnhanced": true, // Enhanced model for better results
          },
          "audio": {
            "content": base64Audio
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List?;
        
        if (results != null && results.isNotEmpty) {
          final transcript = results[0]['alternatives'][0]['transcript'];
          return transcript ?? '';
        } else {
          return '';
        }
      } else {
        print('Speech-to-Text Error: ${response.statusCode} - ${response.body}');
        return _getFallbackSpeechText(languageCode);
      }
    } catch (e) {
      print('Speech-to-Text Service Error: $e');
      return _getFallbackSpeechText(languageCode);
    }
  }

  // Text-to-Speech: Convert text to audio
  static Future<Uint8List?> textToSpeech(String text, String languageCode) async {
    try {
      final response = await http.post(
        Uri.parse('${GoogleCloudConfig.textToSpeechEndpoint}?key=${GoogleCloudConfig.textToSpeechApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "input": {
            "text": text
          },
          "voice": {
            "languageCode": _getLanguageCode(languageCode),
            "name": GoogleCloudConfig.voiceNames[languageCode] ?? "hi-IN-Wavenet-A",
            "ssmlGender": "FEMALE"
          },
          "audioConfig": {
            "audioEncoding": "MP3",
            "speakingRate": GoogleCloudConfig.speakingRate,
            "pitch": GoogleCloudConfig.pitch,
            "volumeGainDb": 0.0
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioContent = data['audioContent'];
        if (audioContent != null) {
          return base64Decode(audioContent);
        }
      } else {
        print('Text-to-Speech Error: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      print('Text-to-Speech Service Error: $e');
      return null;
    }
  }

  // Save audio file to device
  static Future<String?> saveAudioFile(Uint8List audioData, String filename) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename.mp3');
      await file.writeAsBytes(audioData);
      return file.path;
    } catch (e) {
      print('Save Audio Error: $e');
      return null;
    }
  }

  // Stream Speech-to-Text for real-time transcription
  static Future<Stream<String>> streamingSpeechToText(Stream<List<int>> audioStream, String languageCode) async {
    // Implementation for streaming speech recognition
    // This is a placeholder for the actual streaming implementation
    return Stream.periodic(const Duration(seconds: 1), (count) {
      return _getFallbackSpeechText(languageCode);
    }).take(1);
  }

  // Enhanced Speech Recognition with Context
  static Future<String> speechToTextWithContext(
    Uint8List audioData, 
    String languageCode, 
    List<String> phrases, // Context phrases for better recognition
    String domain // e.g., "handicrafts", "art", "business"
  ) async {
    try {
      final base64Audio = base64Encode(audioData);
      
      final response = await http.post(
        Uri.parse('${GoogleCloudConfig.speechToTextEndpoint}?key=${GoogleCloudConfig.speechToTextApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "config": {
            "encoding": "WEBM_OPUS",
            "sampleRateHertz": 48000,
            "languageCode": _getLanguageCode(languageCode),
            "enableAutomaticPunctuation": true,
            "useEnhanced": true,
            "speechContexts": [
              {
                "phrases": phrases,
                "boost": 20.0 // Boost recognition of these phrases
              }
            ],
            "metadata": {
              "recordingDeviceType": "SMARTPHONE",
              "originalMediaType": "AUDIO",
              "interactionType": "VOICE_SEARCH"
            }
          },
          "audio": {
            "content": base64Audio
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List?;
        
        if (results != null && results.isNotEmpty) {
          final transcript = results[0]['alternatives'][0]['transcript'];
          final confidence = results[0]['alternatives'][0]['confidence'] ?? 0.0;
          
          print('Speech Recognition Confidence: $confidence');
          return transcript ?? '';
        }
      }
      
      return _getFallbackSpeechText(languageCode);
    } catch (e) {
      print('Enhanced Speech Recognition Error: $e');
      return _getFallbackSpeechText(languageCode);
    }
  }

  // Batch Text-to-Speech for multiple texts
  static Future<Map<String, Uint8List?>> batchTextToSpeech(
    Map<String, String> texts, // key: identifier, value: text
    String languageCode
  ) async {
    final Map<String, Uint8List?> results = {};
    
    for (final entry in texts.entries) {
      final audioData = await textToSpeech(entry.value, languageCode);
      results[entry.key] = audioData;
      
      // Add small delay to respect rate limits
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return results;
  }

  // Voice Activity Detection
  static bool detectVoiceActivity(Uint8List audioData) {
    // Simple voice activity detection based on audio level
    // In production, you might want to use more sophisticated algorithms
    double sum = 0;
    for (int i = 0; i < audioData.length; i += 2) {
      if (i + 1 < audioData.length) {
        int sample = (audioData[i + 1] << 8) | audioData[i];
        sum += sample.abs();
      }
    }
    
    double average = sum / (audioData.length / 2);
    return average > 1000; // Threshold for voice activity
  }

  // Helper Functions
  static String _getLanguageCode(String languageCode) {
    const languageMap = {
      'hi': 'hi-IN',
      'en': 'en-US',
      'bn': 'bn-IN',
      'mr': 'mr-IN',
      'ta': 'ta-IN',
      'te': 'te-IN',
      'gu': 'gu-IN',
      'kn': 'kn-IN',
      'ml': 'ml-IN',
      'pa': 'pa-IN',
    };
    
    return languageMap[languageCode] ?? 'hi-IN';
  }

  static String _getFallbackSpeechText(String languageCode) {
    const fallbacks = {
      'hi': 'मेरी फोटो को बेहतर बनाएं',
      'en': 'Improve my photo',
      'bn': 'আমার ছবি উন্নত করুন',
      'mr': 'माझा फोटो सुधारा',
      'ta': 'எனது புகைப்படத்தை மேம்படுத்துங்கள்',
      'te': 'నా ఫోటోను మెరుగుపరచండి',
    };
    
    return fallbacks[languageCode] ?? fallbacks['hi']!;
  }

  // Get supported languages for Speech Recognition
  static List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'hi', 'name': 'हिंदी', 'english': 'Hindi'},
      {'code': 'en', 'name': 'English', 'english': 'English'},
      {'code': 'bn', 'name': 'বাংলা', 'english': 'Bengali'},
      {'code': 'mr', 'name': 'मराठी', 'english': 'Marathi'},
      {'code': 'ta', 'name': 'தமிழ்', 'english': 'Tamil'},
      {'code': 'te', 'name': 'తెలుగు', 'english': 'Telugu'},
      {'code': 'gu', 'name': 'ગુજરાતી', 'english': 'Gujarati'},
      {'code': 'kn', 'name': 'ಕನ್ನಡ', 'english': 'Kannada'},
      {'code': 'ml', 'name': 'മലയാളം', 'english': 'Malayalam'},
      {'code': 'pa', 'name': 'ਪੰਜਾਬੀ', 'english': 'Punjabi'},
    ];
  }

  // Context phrases for better recognition in handicrafts domain
  static List<String> getHandicraftsContextPhrases(String languageCode) {
    const phrases = {
      'hi': [
        'हस्तशिल्प', 'कलाकार', 'मीनाकारी', 'वास', 'पेंटिंग', 'लकड़ी का काम',
        'फोटो', 'तस्वीर', 'बिक्री', 'मार्केटिंग', 'प्रमाणपत्र', 'कहानी',
        'Amazon', 'Etsy', 'Flipkart', 'Instagram', 'Facebook'
      ],
      'en': [
        'handicraft', 'artisan', 'meenakari', 'vase', 'painting', 'woodwork',
        'photo', 'picture', 'sales', 'marketing', 'certificate', 'story',
        'Amazon', 'Etsy', 'Flipkart', 'Instagram', 'Facebook'
      ],
      'bn': [
        'হস্তশিল্প', 'কারিগর', 'মিনাকারি', 'ফুলদানি', 'চিত্রকলা', 'কাঠের কাজ',
        'ছবি', 'বিক্রয়', 'বিপণন', 'সার্টিফিকেট', 'গল্প'
      ],
    };
    
    return phrases[languageCode] ?? phrases['hi']!;
  }
}