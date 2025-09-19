import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart';

class SpeechRecognitionService {
  static stt.SpeechToText? _speech;
  static bool _isInitialized = false;
  static bool _isListening = false;
  
  static bool get isListening => _isListening;
  static bool get isInitialized => _isInitialized;
  
  static Future<bool> initialize() async {
    try {
      _speech = stt.SpeechToText();
      _isInitialized = await _speech!.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          _isListening = false;
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
          if (status == 'notListening' || status == 'done') {
            _isListening = false;
          }
        },
      );
      
      if (_isInitialized) {
        print('Speech recognition initialized successfully');
      } else {
        print('Speech recognition initialization failed');
      }
      
      return _isInitialized;
    } catch (e) {
      print('Speech recognition initialization error: $e');
      _isInitialized = false;
      return false;
    }
  }
  
  static Future<void> startListening({
    required Function(String) onResult,
    required String languageCode,
    Function(String)? onError,
  }) async {
    try {
      if (!_isInitialized) {
        final initialized = await initialize();
        if (!initialized) {
          onError?.call('Speech recognition not available');
          return;
        }
      }
      
      if (_speech!.isAvailable && !_isListening) {
        _isListening = true;
        
        await _speech!.listen(
          onResult: (result) {
            print('Speech result: ${result.recognizedWords}, final: ${result.finalResult}');
            
            if (result.finalResult && result.recognizedWords.isNotEmpty) {
              onResult(result.recognizedWords);
              _isListening = false;
            }
          },
          localeId: _getLocaleId(languageCode),
          partialResults: false,
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: true,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
        );
        
        print('Started listening in ${_getLocaleId(languageCode)}');
      } else {
        onError?.call('Speech recognition not available or already listening');
      }
    } catch (e) {
      print('Start listening error: $e');
      _isListening = false;
      onError?.call('Failed to start speech recognition: $e');
    }
  }
  
  static Future<void> stopListening() async {
    try {
      if (_speech != null && _isListening) {
        await _speech!.stop();
        _isListening = false;
        print('Stopped listening');
      }
    } catch (e) {
      print('Stop listening error: $e');
      _isListening = false;
    }
  }
  
  static Future<void> cancelListening() async {
    try {
      if (_speech != null && _isListening) {
        await _speech!.cancel();
        _isListening = false;
        print('Cancelled listening');
      }
    } catch (e) {
      print('Cancel listening error: $e');
      _isListening = false;
    }
  }
  
  static String _getLocaleId(String languageCode) {
    final localeMap = {
      'hi': 'hi_IN',
      'en': 'en_US',
      'pa': 'pa_IN',
      'bn': 'bn_IN',
      'mr': 'mr_IN',
      'gu': 'gu_IN',
      'ta': 'ta_IN',
      'te': 'te_IN',
      'kn': 'kn_IN',
      'ml': 'ml_IN',
      'ur': 'ur_IN',
    };
    return localeMap[languageCode] ?? 'en_US';
  }
  
  static Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_speech != null && _isInitialized) {
      return await _speech!.locales();
    }
    
    return [];
  }
  
  static Future<void> dispose() async {
    try {
      if (_speech != null) {
        await _speech!.cancel();
        _speech = null;
        _isInitialized = false;
        _isListening = false;
      }
    } catch (e) {
      print('Speech recognition dispose error: $e');
    }
  }
}