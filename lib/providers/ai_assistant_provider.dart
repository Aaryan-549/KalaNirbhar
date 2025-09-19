import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import '../services/gemini_service.dart';
import '../services/speech_services.dart';
import '../services/translation_service.dart';
import '../services/vision_service.dart';
import '../services/imagen_service.dart';
import '../services/blockchain_service.dart';

class AIAssistantProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _messages = [];
  bool _isProcessing = false;
  bool _isListening = false;
  String _currentLanguage = 'hi'; // Default to Hindi
  
  // Image processing states
  bool _isProcessingImage = false;
  List<Uint8List> _enhancedImages = [];
  
  // Certificate creation state
  bool _isCreatingCertificate = false;
  Map<String, dynamic>? _lastCertificate;
  
  List<Map<String, dynamic>> get messages => _messages;
  bool get isProcessing => _isProcessing;
  bool get isListening => _isListening;
  bool get isProcessingImage => _isProcessingImage;
  bool get isCreatingCertificate => _isCreatingCertificate;
  String get currentLanguage => _currentLanguage;
  List<Uint8List> get enhancedImages => _enhancedImages;
  Map<String, dynamic>? get lastCertificate => _lastCertificate;

  // Welcome messages in different languages
  final Map<String, String> _welcomeMessages = {
    'hi': 'नमस्ते! मैं आपका सरल बातचीत सहायक हूं। मैं Google Cloud AI की शक्ति से आपकी मदद कर सकता हूं:\n\n📸 Imagen AI से फोटो को पेशेवर बनाना\n📝 Gemini AI से उत्पाद की कहानी लिखना\n🛡️ Blockchain पर डिजिटल प्रमाणपत्र\n🗣️ Voice में बात करना (Speech AI)\n🌐 सभी भाषाओं में अनुवाद\n📱 मार्केटिंग कंटेंट जेनरेशन\n\nआप मुझसे आवाज़ में या टाइप करके बात कर सकते हैं। कैसे मदद कर सकता हूं?',
    'en': 'Hello! I\'m your Saral Baatcheet assistant powered by Google Cloud AI. I can help you with:\n\n📸 Professional photo enhancement with Imagen AI\n📝 Product storytelling with Gemini AI\n🛡️ Digital certificates on blockchain\n🗣️ Voice conversations with Speech AI\n🌐 Translation in all languages\n📱 Marketing content generation\n\nYou can talk to me using voice or text. How can I help you today?',
    'bn': 'হ্যালো! আমি Google Cloud AI দ্বারা চালিত আপনার সরল বাতচীত সহায়ক। আমি সাহায্য করতে পারি:\n\n📸 Imagen AI দিয়ে ছবি উন্নত করা\n📝 Gemini AI দিয়ে পণ্যের গল্প লেখা\n🛡️ Blockchain এ ডিজিটাল সার্টিফিকেট\n🗣️ Speech AI দিয়ে কথা বলা\n🌐 সব ভাষায় অনুবাদ\n📱 মার্কেটিং কন্টেন্ট তৈরি\n\nআপনি আমার সাথে কণ্ঠস্বর বা টেক্সট দিয়ে কথা বলতে পারেন।',
  };

  // Feature suggestions in different languages
  final Map<String, List<String>> _featureSuggestions = {
    'hi': [
      '📸 AI से फोটो सुधारें',
      '📝 कহानी लिखवाएं', 
      '🛡️ प्रमाणपत्र बनाएं',
      '📊 बिक्री देखें',
      '📱 मार्केटिंग करें'
    ],
    'en': [
      '📸 AI Photo Enhancement',
      '📝 Generate Story',
      '🛡️ Create Certificate', 
      '📊 View Analytics',
      '📱 Marketing Content'
    ],
    'bn': [
      '📸 AI ছবি উন্নত করুন',
      '📝 গল্প তৈরি করুন',
      '🛡️ সার্টিফিকেট বানান',
      '📊 বিক্রয় দেখুন',
      '📱 মার্কেটিং সামগ্রী'
    ],
  };

  void addWelcomeMessage() {
    _messages.clear();
    _messages.add({
      'text': _welcomeMessages[_currentLanguage] ?? _welcomeMessages['hi']!,
      'isUser': false,
      'timestamp': DateTime.now(),
      'type': 'welcome'
    });
    notifyListeners();
  }

  void changeLanguage(String languageCode) {
    _currentLanguage = languageCode;
    addWelcomeMessage();
  }

  List<String> getFeatureSuggestions() {
    return _featureSuggestions[_currentLanguage] ?? _featureSuggestions['hi']!;
  }

  // Send message with Google Cloud AI integration
  Future<void> sendMessage(String message) async {
    // Add user message
    _messages.add({
      'text': message,
      'isUser': true,
      'timestamp': DateTime.now(),
    });
    
    _isProcessing = true;
    notifyListeners();

    try {
      // Use Gemini AI for response generation
      String response = await GeminiService.generateChatResponse(message, _currentLanguage);
      
      // Translate response if needed
      if (_currentLanguage != 'en') {
        response = await TranslationService.translateText(response, _currentLanguage);
      }
      
      // Add AI response
      _messages.add({
        'text': response,
        'isUser': false,
        'timestamp': DateTime.now(),
        'aiGenerated': true,
      });

      // Generate audio response
      _generateAudioResponse(response);
      
    } catch (e) {
      print('AI Chat Error: $e');
      _messages.add({
        'text': _getFallbackResponse(message, _currentLanguage),
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Voice input with Google Speech-to-Text
  Future<void> processVoiceInput(Uint8List audioData) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // Convert speech to text
      final contextPhrases = SpeechServices.getHandicraftsContextPhrases(_currentLanguage);
      String transcript = await SpeechServices.speechToTextWithContext(
        audioData, 
        _currentLanguage, 
        contextPhrases,
        'handicrafts'
      );
      
      if (transcript.isNotEmpty) {
        await sendMessage(transcript);
      } else {
        _addSystemMessage('आवाज़ समझने में समस्या हुई। कृपया दोबारा बोलें।');
      }
    } catch (e) {
      print('Voice Processing Error: $e');
      _addSystemMessage('आवाज़ प्रोसेसिंग में त्रुटि हुई।');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Image enhancement with Imagen AI
  Future<void> enhanceProductImage(Uint8List imageData, String productDescription) async {
    _isProcessingImage = true;
    _enhancedImages.clear();
    notifyListeners();

    try {
      // Analyze image first with Vision AI
      _addSystemMessage('Vision AI से छवि का विश्लेषण कर रहे हैं...');
      final analysis = await VisionService.analyzeProductImage(imageData);
      
      // Get enhancement suggestions
      final suggestions = await VisionService.getEnhancementSuggestions(imageData);
      
      _addSystemMessage('Imagen AI से फोटो को पेशेवर बना रहे हैं...');
      
      // Get background styles
      final backgroundStyles = ['white_background', 'lifestyle_modern', 'luxury_elegant'];
      
      // Generate enhanced images
      final enhancedImages = await ImagenService.enhanceProductPhoto(
        imageData, 
        backgroundStyles, 
        productDescription
      );
      
      _enhancedImages = enhancedImages;
      
      if (enhancedImages.isNotEmpty) {
        _addSystemMessage('🎉 ${enhancedImages.length} enhanced फोटो तैयार हैं! Professional backgrounds के साथ आपकी फोटो e-commerce के लिए ready है।');
      } else {
        _addSystemMessage('फोटो enhancement में समस्या हुई। कृपया दोबारा कोशिश करें।');
      }
      
    } catch (e) {
      print('Image Enhancement Error: $e');
      _addSystemMessage('फोटो प्रोसेसिंग में त्रुटि हुई। बेहतर फोटो के लिए अच्छी रोशनी में तस्वीर लें।');
    } finally {
      _isProcessingImage = false;
      notifyListeners();
    }
  }

  // Generate product story with Gemini AI
  Future<void> generateProductStory(Map<String, dynamic> productInfo) async {
    _isProcessing = true;
    notifyListeners();

    try {
      _addSystemMessage('Gemini AI से आपके उत्पाद की कहानी लिख रहे हैं...');
      
      final description = await GeminiService.generateProductDescription(
        productInfo, 
        _currentLanguage
      );
      
      // Translate to multiple languages for global reach
      final englishDescription = await TranslationService.translateText(
        description, 
        'en'
      );
      
      _addSystemMessage('📝 उत्पाद की कहानी तैयार:\n\n$description\n\n🌍 English Translation:\n$englishDescription');
      
    } catch (e) {
      print('Story Generation Error: $e');
      _addSystemMessage('कहानी लिखने में समस्या हुई। कृपया उत्पाद की अधिक जानकारी दें।');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Create digital certificate with blockchain
  Future<void> createDigitalCertificate(Map<String, dynamic> productData) async {
    _isCreatingCertificate = true;
    notifyListeners();

    try {
      _addSystemMessage('🛡️ Blockchain पर डिजिटल प्रमाणपत्र बना रहे हैं...');
      
      final result = await BlockchainService.createCertificate(
        artisanName: productData['artisanName'] ?? 'Anonymous Artisan',
        productName: productData['productName'] ?? 'Handicraft Product',
        productDescription: productData['description'] ?? '',
        craftType: productData['craftType'] ?? 'Traditional Craft',
        location: productData['location'] ?? 'India',
        imageHash: productData['imageHash'] ?? 'demo_hash',
        userWalletAddress: productData['walletAddress'] ?? '0x742d35Cc67dF5C3d6C4fA4D4cD6d8f6a3dE5d2F4',
      );
      
      if (result['success']) {
        _lastCertificate = result['certificate'];
        _addSystemMessage('✅ डिजिटल प्रमाणपत्र सफलतापूर्वक बना! \n\n🔗 Certificate ID: ${result['certificate']['tokenId']}\n🌐 View on Blockchain: ${result['certificate']['explorerUrl']}\n\n यह प्रमाणपत्र आपके उत्पाद की प्रामाणिकता को सिद्ध करता है।');
      } else {
        _addSystemMessage('प्रमाणपत्र बनाने में समस्या: ${result['message']}');
      }
      
    } catch (e) {
      print('Certificate Creation Error: $e');
      _addSystemMessage('डिजिटल प्रमाणपत्र बनाने में त्रुटि हुई।');
    } finally {
      _isCreatingCertificate = false;
      notifyListeners();
    }
  }

  // Generate marketing content with AI
  Future<void> generateMarketingContent(Map<String, dynamic> productInfo, String platform) async {
    _isProcessing = true;
    notifyListeners();

    try {
      _addSystemMessage('📱 $platform के लिए marketing content बना रहे हैं...');
      
      final marketingContent = await GeminiService.generateMarketingContent(
        productInfo, 
        platform, 
        _currentLanguage
      );
      
      String contentText = '🎯 $platform Marketing Content:\n\n';
      
      if (marketingContent.containsKey('caption')) {
        contentText += '📝 Caption:\n${marketingContent['caption']}\n\n';
      }
      
      if (marketingContent.containsKey('hashtags')) {
        contentText += '#️⃣ Hashtags:\n${marketingContent['hashtags']}\n\n';
      }
      
      if (marketingContent.containsKey('description')) {
        contentText += '📄 Description:\n${marketingContent['description']}\n\n';
      }

      _addSystemMessage(contentText);
      
    } catch (e) {
      print('Marketing Content Error: $e');
      _addSystemMessage('Marketing content बनाने में समस्या हुई।');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Generate audio response with Text-to-Speech
  Future<void> _generateAudioResponse(String text) async {
    try {
      final audioData = await SpeechServices.textToSpeech(text, _currentLanguage);
      if (audioData != null) {
        // In a real app, you would play this audio
        print('Audio response generated: ${audioData.length} bytes');
      }
    } catch (e) {
      print('Audio Generation Error: $e');
    }
  }

  void startListening() {
    _isListening = true;
    notifyListeners();
    
    // Simulate voice listening
    Timer(const Duration(seconds: 3), () {
      _isListening = false;
      notifyListeners();
    });
  }

  void stopListening() {
    _isListening = false;
    notifyListeners();
  }

  // Handle feature suggestions tap with AI integration
  void handleFeatureSuggestion(String suggestion) {
    String message = '';
    
    if (suggestion.contains('फोटो') || suggestion.contains('Photo') || suggestion.contains('AI')) {
      message = _currentLanguage == 'hi' ? 'AI से मेरी फोटो को professional बनाएं' : 'Make my photo professional with AI';
    } else if (suggestion.contains('कहानी') || suggestion.contains('Story') || suggestion.contains('Generate')) {
      message = _currentLanguage == 'hi' ? 'Gemini AI से मेरे उत्पाद की कहानी लिखें' : 'Write my product story with Gemini AI';
    } else if (suggestion.contains('प्रमाणपत्र') || suggestion.contains('Certificate')) {
      message = _currentLanguage == 'hi' ? 'Blockchain पर डिजिटल प्रमाणपत्र बनाएं' : 'Create digital certificate on blockchain';
    } else if (suggestion.contains('बिक्री') || suggestion.contains('Analytics')) {
      message = _currentLanguage == 'hi' ? 'मेरी बिक्री का विश्लेषण दिखाएं' : 'Show my sales analytics';
    } else if (suggestion.contains('मार्केटिंग') || suggestion.contains('Marketing')) {
      message = _currentLanguage == 'hi' ? 'AI से मार्केटिंग content बनाएं' : 'Create marketing content with AI';
    }
    
    if (message.isNotEmpty) {
      sendMessage(message);
    }
  }

  void toggleListening() {
    if (_isListening) {
      stopListening();
    } else {
      startListening();
    }
  }

  void clearMessages() {
    _messages.clear();
    _enhancedImages.clear();
    _lastCertificate = null;
    addWelcomeMessage();
  }

  // Helper methods
  void _addSystemMessage(String message) {
    _messages.add({
      'text': message,
      'isUser': false,
      'timestamp': DateTime.now(),
      'isSystem': true,
    });
    notifyListeners();
  }

  String _getFallbackResponse(String message, String language) {
    final responses = {
      'hi': 'मुझे आपका सवाल समझ आया। Google Cloud AI की मदद से मैं आपकी बेहतर सेवा करने की कोशिश कर रहा हूं। कृपया अधिक विवरण दें।',
      'en': 'I understand your question. I\'m trying to serve you better with Google Cloud AI. Please provide more details.',
      'bn': 'আমি আপনার প্রশ্ন বুঝতে পেরেছি। Google Cloud AI দিয়ে আমি আপনাকে আরও ভাল সেবা দেওয়ার চেষ্টা করছি।',
    };
    
    return responses[language] ?? responses['hi']!;
  }

  // Get AI service status
  Map<String, bool> getServiceStatus() {
    return {
      'gemini': true, // Replace with actual service checks
      'speech': true,
      'translation': true,
      'vision': true,
      'imagen': true,
      'blockchain': true,
    };
  }

  // Get usage statistics
  Map<String, int> getUsageStats() {
    return {
      'messagesProcessed': _messages.length,
      'imagesEnhanced': _enhancedImages.length,
      'certificatesCreated': _lastCertificate != null ? 1 : 0,
      'languagesUsed': 1,
    };
  }
}