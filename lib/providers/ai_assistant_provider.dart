import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import '../services/gemini_service.dart';
import '../services/speech_services.dart';
import '../services/translation_service.dart';
import '../services/vision_service.dart';
import '../services/imagen_service.dart';
import '../services/blockchain_service.dart';
import '../services/audio_service.dart';

class AIAssistantProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _messages = [];
  bool _isProcessing = false;
  bool _isListening = false;
  String _currentLanguage = 'hi';
  String _userName = '';
  
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

  // Complete welcome messages in all supported languages
  final Map<String, String> _welcomeMessages = {
    'hi': 'नमस्ते! मैं आपका KalaNirbhar AI सहायक हूं। मैं Google Cloud AI की शक्ति से आपकी मदद कर सकता हूं:\n\n📸 Imagen AI से फोटो को पेशेवर बनाना\n📝 Gemini AI से उत्पाद की कहानी लिखना\n🛡️ Blockchain पर डिजिटल प्रमाणपत्र\n🗣️ Voice में बात करना (Speech AI)\n🌐 सभी भाषाओं में अनुवाद\n📱 मार्केटिंग कंटेंट जेनरेशन\n\nआप मुझसे आवाज़ में या टाइप करके बात कर सकते हैं। कैसे मदद कर सकता हूं?',
    
    'en': 'Hello! I\'m your KalaNirbhar AI assistant powered by Google Cloud AI. I can help you with:\n\n📸 Professional photo enhancement with Imagen AI\n📝 Product storytelling with Gemini AI\n🛡️ Digital certificates on blockchain\n🗣️ Voice conversations with Speech AI\n🌐 Translation in all languages\n📱 Marketing content generation\n\nYou can talk to me using voice or text. How can I help you today?',
    
    'pa': 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ! ਮੈਂ ਤੁਹਾਡਾ KalaNirbhar AI ਸਹਾਇਕ ਹਾਂ। Google Cloud AI ਨਾਲ ਮੈਂ ਤੁਹਾਡੀ ਮਦਦ ਕਰ ਸਕਦਾ ਹਾਂ:\n\n📸 Imagen AI ਨਾਲ ਪ੍ਰੋਫੈਸ਼ਨਲ ਫੋਟੋ ਸੁਧਾਰ\n📝 Gemini AI ਨਾਲ ਉਤਪਾਦ ਦੀ ਕਹਾਣੀ\n🛡️ Blockchain ਤੇ ਡਿਜੀਟਲ ਸਰਟੀਫਿਕੇਟ\n🗣️ ਆਵਾਜ਼ ਵਿੱਚ ਗੱਲਬਾਤ\n🌐 ਸਾਰੀਆਂ ਭਾਸ਼ਾਵਾਂ ਵਿੱਚ ਅਨੁਵਾਦ\n📱 ਮਾਰਕੀਟਿੰਗ ਸਮੱਗਰੀ\n\nਤੁਸੀਂ ਮੇਰੇ ਨਾਲ ਆਵਾਜ਼ ਜਾਂ ਲਿਖ ਕੇ ਗੱਲ ਕਰ ਸਕਦੇ ਹੋ। ਕਿਵੇਂ ਮਦਦ ਕਰਾਂ?',
    
    'bn': 'নমস্কার! আমি আপনার KalaNirbhar AI সহায়ক। Google Cloud AI দিয়ে আমি সাহায্য করতে পারি:\n\n📸 Imagen AI দিয়ে পেশাদার ফটো উন্নতি\n📝 Gemini AI দিয়ে পণ্যের গল্প\n🛡️ Blockchain এ ডিজিটাল সার্টিফিকেট\n🗣️ কণ্ঠস্বরে কথোপকথন\n🌐 সব ভাষায় অনুবাদ\n📱 মার্কেটিং সামগ্রী\n\nআপনি আমার সাথে কণ্ঠস্বর বা টেক্সট দিয়ে কথা বলতে পারেন। কিভাবে সাহায্য করব?',
    
    'mr': 'नमस्कार! मी तुमचा KalaNirbhar AI सहाय्यक आहे। Google Cloud AI ने मी मदत करू शकतो:\n\n📸 Imagen AI ने व्यावसायिक फोटो सुधारणा\n📝 Gemini AI ने उत्पादनाची कहाणी\n🛡️ Blockchain वर डिजिटल प्रमाणपत्र\n🗣️ आवाजात संवाद\n🌐 सर्व भाषांमध्ये भाषांतर\n📱 मार्केटिंग सामग्री\n\nतुम्ही माझ्याशी आवाज किंवा मजकूर वापरून बोलू शकता। कशी मदत करू?',
    
    'gu': 'નમસ્તે! હું તમારો KalaNirbhar AI સહાયક છું। Google Cloud AI થી હું મદદ કરી શકું છું:\n\n📸 Imagen AI થી વ્યાવસાયિક ફોટો સુધારણા\n📝 Gemini AI થી ઉત્પાદનની વાર્તા\n🛡️ Blockchain પર ડિજિટલ પ્રમાણપત્ર\n🗣️ અવાજમાં વાતચીત\n🌐 બધી ભાષાઓમાં અનુવાદ\n📱 માર્કેટિંગ સામગ્રી\n\nતમે મારી સાથે અવાજ અથવા ટેક્સ્ટ વાપરીને વાત કરી શકો છો। કેવી રીતે મદદ કરું?',
  };

  // Base feature suggestions in English - will be translated dynamically
  final List<String> _baseSuggestions = [
    'AI Photo Enhancement',
    'Generate Product Story',
    'Create Digital Certificate',
    'View Sales Analytics',
    'Marketing Content Creation'
  ];

  // Cache for translated suggestions
  Map<String, List<String>> _translatedSuggestions = {};

  void initialize(String language, String userName) {
    _currentLanguage = language;
    _userName = userName;
    _loadWelcomeMessage();
  }

  Future<void> _loadWelcomeMessage() async {
    String welcomeMessage = '';
    
    // Try to get pre-defined message first
    if (_welcomeMessages.containsKey(_currentLanguage)) {
      welcomeMessage = _welcomeMessages[_currentLanguage]!;
      
      // Personalize with user name if available
      if (_userName.isNotEmpty) {
        final greeting = _getPersonalizedGreeting();
        welcomeMessage = '$greeting\n\n$welcomeMessage';
      }
    } else {
      // Fallback: translate base English message
      try {
        welcomeMessage = await TranslationService.translateText(
          _welcomeMessages['en']!,
          _currentLanguage,
          sourceLanguage: 'en'
        );
        
        if (_userName.isNotEmpty) {
          final greeting = _getPersonalizedGreeting();
          welcomeMessage = '$greeting\n\n$welcomeMessage';
        }
      } catch (e) {
        print('Translation error for welcome message: $e');
        welcomeMessage = _welcomeMessages['en']!; // Ultimate fallback
      }
    }
    
    _messages.clear();
    _messages.add({
      'text': welcomeMessage,
      'isUser': false,
      'timestamp': DateTime.now(),
      'type': 'welcome'
    });
    notifyListeners();
  }

  String _getPersonalizedGreeting() {
    if (_userName.isEmpty) return '';
    
    final hour = DateTime.now().hour;
    String greeting = '';
    
    if (hour < 12) {
      switch (_currentLanguage) {
        case 'hi':
          greeting = 'सुप्रभात, ${_userName} जी!';
          break;
        case 'pa':
          greeting = 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ, ${_userName} ਜੀ!';
          break;
        case 'bn':
          greeting = 'সুপ্রভাত, ${_userName} জি!';
          break;
        case 'mr':
          greeting = 'सुप्रभात, ${_userName} जी!';
          break;
        default:
          greeting = 'Good morning, $_userName!';
      }
    } else if (hour < 17) {
      switch (_currentLanguage) {
        case 'hi':
          greeting = 'नमस्ते, ${_userName} जी!';
          break;
        case 'pa':
          greeting = 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ, ${_userName} ਜੀ!';
          break;
        case 'bn':
          greeting = 'নমস্কার, ${_userName} জি!';
          break;
        case 'mr':
          greeting = 'नमस्कार, ${_userName} जी!';
          break;
        default:
          greeting = 'Good afternoon, $_userName!';
      }
    } else {
      switch (_currentLanguage) {
        case 'hi':
          greeting = 'शुभ संध्या, ${_userName} जी!';
          break;
        case 'pa':
          greeting = 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ, ${_userName} ਜੀ!';
          break;
        case 'bn':
          greeting = 'শুভ সন্ধ্যা, ${_userName} জি!';
          break;
        case 'mr':
          greeting = 'शुभ संध्या, ${_userName} जी!';
          break;
        default:
          greeting = 'Good evening, $_userName!';
      }
    }
    
    return greeting;
  }

  void changeLanguage(String languageCode, String userName) {
    _currentLanguage = languageCode;
    _userName = userName;
    _loadWelcomeMessage();
    _translateSuggestions(); // Re-translate suggestions
  }

  Future<void> _translateSuggestions() async {
    if (_translatedSuggestions[_currentLanguage] != null) return;
    
    try {
      final translatedList = <String>[];
      
      for (final suggestion in _baseSuggestions) {
        if (_currentLanguage == 'en') {
          translatedList.add(suggestion);
        } else {
          final translated = await TranslationService.translateText(
            suggestion,
            _currentLanguage,
            sourceLanguage: 'en'
          );
          translatedList.add(translated);
        }
      }
      
      _translatedSuggestions[_currentLanguage] = translatedList;
      notifyListeners();
    } catch (e) {
      print('Translation error for suggestions: $e');
      // Use fallback suggestions
      _translatedSuggestions[_currentLanguage] = _baseSuggestions;
    }
  }

  Future<List<String>> getFeatureSuggestions() async {
    if (_translatedSuggestions[_currentLanguage] == null) {
      await _translateSuggestions();
    }
    return _translatedSuggestions[_currentLanguage] ?? _baseSuggestions;
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
      String response = await GeminiService.generateChatResponse(
        message, 
        _currentLanguage,
      );
      
      // Ensure response is in correct language
      if (_currentLanguage != 'en') {
        try {
          // Verify language and translate if needed
          response = await TranslationService.translateText(
            response, 
            _currentLanguage,
            sourceLanguage: 'en'
          );
        } catch (translateError) {
          print('Translation error: $translateError');
          // Keep original response if translation fails
        }
      }
      
      // Add AI response
      _messages.add({
        'text': response,
        'isUser': false,
        'timestamp': DateTime.now(),
        'aiGenerated': true,
        'language': _currentLanguage,
      });

      // Generate audio response if TTS is available
      _generateAudioResponse(response);
      
    } catch (e) {
      print('AI Chat Error: $e');
      final fallbackMessage = await _getFallbackResponse(message);
      _messages.add({
        'text': fallbackMessage,
        'isUser': false,
        'timestamp': DateTime.now(),
        'isError': true,
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
      // Convert speech to text in user's language
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
        final errorMessage = await _getLocalizedSystemMessage('voice_error');
        _addSystemMessage(errorMessage);
      }
    } catch (e) {
      print('Voice Processing Error: $e');
      final errorMessage = await _getLocalizedSystemMessage('voice_processing_error');
      _addSystemMessage(errorMessage);
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
      // Localized status messages
      final analyzingMessage = await _getLocalizedSystemMessage('analyzing_image');
      _addSystemMessage(analyzingMessage);
      
      final analysis = await VisionService.analyzeProductImage(imageData);
      final suggestions = await VisionService.getEnhancementSuggestions(imageData);
      
      final enhancingMessage = await _getLocalizedSystemMessage('enhancing_image');
      _addSystemMessage(enhancingMessage);
      
      // Get background styles
      final backgroundStyles = ['white_background', 'lifestyle_modern', 'luxury_elegant'];
      
      // Generate enhanced images
      final enhancedImages = await ImagenService.enhanceProductPhoto(
        imageData, 
        backgroundStyles, 
        productDescription
      );
      
      _enhancedImages = enhancedImages;
      
      final successMessage = await _getLocalizedSystemMessage(
        enhancedImages.isNotEmpty ? 'enhancement_success' : 'enhancement_failed'
      );
      _addSystemMessage(successMessage);
      
    } catch (e) {
      print('Image Enhancement Error: $e');
      final errorMessage = await _getLocalizedSystemMessage('image_processing_error');
      _addSystemMessage(errorMessage);
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
      final generatingMessage = await _getLocalizedSystemMessage('generating_story');
      _addSystemMessage(generatingMessage);
      
      final description = await GeminiService.generateProductDescription(
        productInfo, 
        _currentLanguage
      );
      
      // For global reach, also generate in English if current language is not English
      String englishDescription = '';
      if (_currentLanguage != 'en') {
        try {
          englishDescription = await TranslationService.translateText(
            description, 
            'en',
            sourceLanguage: _currentLanguage
          );
        } catch (e) {
          print('English translation error: $e');
        }
      }
      
      String storyMessage = description;
      if (englishDescription.isNotEmpty) {
        final englishLabel = await _getLocalizedSystemMessage('english_translation');
        storyMessage += '\n\n$englishLabel:\n$englishDescription';
      }
      
      _addSystemMessage('📝 $storyMessage');
      
    } catch (e) {
      print('Story Generation Error: $e');
      final errorMessage = await _getLocalizedSystemMessage('story_generation_error');
      _addSystemMessage(errorMessage);
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
      final creatingMessage = await _getLocalizedSystemMessage('creating_certificate');
      _addSystemMessage(creatingMessage);
      
      final result = await BlockchainService.createCertificate(
        artisanName: productData['artisanName'] ?? (_userName.isNotEmpty ? _userName : 'Anonymous Artisan'),
        productName: productData['productName'] ?? 'Handicraft Product',
        productDescription: productData['description'] ?? '',
        craftType: productData['craftType'] ?? 'Traditional Craft',
        location: productData['location'] ?? 'India',
        imageHash: productData['imageHash'] ?? 'demo_hash',
        userWalletAddress: productData['walletAddress'] ?? '0x742d35Cc67dF5C3d6C4fA4D4cD6d8f6a3dE5d2F4',
      );
      
      if (result['success']) {
        _lastCertificate = result['certificate'];
        final successMessage = await _getLocalizedSystemMessage('certificate_success');
        final certificateInfo = '🔗 Certificate ID: ${result['certificate']['tokenId']}\n🌐 View on Blockchain: ${result['certificate']['explorerUrl']}';
        _addSystemMessage('$successMessage\n\n$certificateInfo');
      } else {
        final errorMessage = await _getLocalizedSystemMessage('certificate_error');
        _addSystemMessage('$errorMessage: ${result['message']}');
      }
      
    } catch (e) {
      print('Certificate Creation Error: $e');
      final errorMessage = await _getLocalizedSystemMessage('certificate_creation_error');
      _addSystemMessage(errorMessage);
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
      final generatingMessage = await _getLocalizedSystemMessage('generating_marketing');
      _addSystemMessage(generatingMessage.replaceAll('{platform}', platform));
      
      final marketingContent = await GeminiService.generateMarketingContent(
        productInfo, 
        platform, 
        _currentLanguage
      );
      
      final contentLabel = await _getLocalizedSystemMessage('marketing_content');
      String contentText = '🎯 ${contentLabel.replaceAll('{platform}', platform)}:\n\n';
      
      if (marketingContent.containsKey('caption')) {
        final captionLabel = await _getLocalizedSystemMessage('caption');
        contentText += '📝 $captionLabel:\n${marketingContent['caption']}\n\n';
      }
      
      if (marketingContent.containsKey('hashtags')) {
        final hashtagsLabel = await _getLocalizedSystemMessage('hashtags');
        contentText += '#️⃣ $hashtagsLabel:\n${marketingContent['hashtags']}\n\n';
      }
      
      if (marketingContent.containsKey('description')) {
        final descriptionLabel = await _getLocalizedSystemMessage('description');
        contentText += '📄 $descriptionLabel:\n${marketingContent['description']}\n\n';
      }

      _addSystemMessage(contentText);
      
    } catch (e) {
      print('Marketing Content Error: $e');
      final errorMessage = await _getLocalizedSystemMessage('marketing_content_error');
      _addSystemMessage(errorMessage);
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
        // Play the audio using AudioService
        await AudioService.playAudioFromBytes(audioData);
        print('Audio response playing: ${audioData.length} bytes');
      }
    } catch (e) {
      print('Audio Generation Error: $e');
    }
  }

  // Get localized system messages
  Future<String> _getLocalizedSystemMessage(String messageKey) async {
    final systemMessages = {
      'voice_error': {
        'en': 'Could not understand voice. Please try again.',
        'hi': 'आवाज़ समझने में समस्या हुई। कृपया दोबारा बोलें।',
        'pa': 'ਆਵਾਜ਼ ਸਮਝਣ ਵਿੱਚ ਸਮੱਸਿਆ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਬੋਲੋ।',
        'bn': 'কণ্ঠস্বর বুঝতে সমস্যা। অনুগ্রহ করে আবার বলুন।',
      },
      'analyzing_image': {
        'en': 'Analyzing image with Vision AI...',
        'hi': 'Vision AI से छवि का विश्লেषण कर रहे हैं...',
        'pa': 'Vision AI ਨਾਲ ਤਸਵੀਰ ਦਾ ਵਿਸ਼ਲੇਸ਼ਣ...',
        'bn': 'Vision AI দিয়ে ছবি বিশ্লেষণ করছি...',
      },
      'enhancing_image': {
        'en': 'Enhancing photo professionally with Imagen AI...',
        'hi': 'Imagen AI से फोटो को पेशेवर बना रहे हैं...',
        'pa': 'Imagen AI ਨਾਲ ਫੋਟੋ ਨੂੰ ਪ੍ਰੋਫੈਸ਼ਨਲ ਬਣਾ ਰਹੇ ਹਾਂ...',
        'bn': 'Imagen AI দিয়ে ছবি পেশাদারভাবে উন্নত করছি...',
      },
      'enhancement_success': {
        'en': '🎉 Enhanced photos are ready! Professional backgrounds make your photo e-commerce ready.',
        'hi': '🎉 Enhanced फोटो तैयार हैं! Professional backgrounds के साथ आपकी फोटो e-commerce के लिए ready है।',
        'pa': '🎉 Enhanced ਫੋਟੋ ਤਿਆਰ ਹਨ! Professional backgrounds ਨਾਲ ਤੁਹਾਡੀ ਫੋਟੋ e-commerce ਲਈ ਤਿਆਰ ਹੈ।',
        'bn': '🎉 Enhanced ফটো প্রস্তুত! Professional backgrounds দিয়ে আপনার ফটো e-commerce এর জন্য প্রস্তুত।',
      }
    };

    final messageMap = systemMessages[messageKey];
    if (messageMap != null && messageMap[_currentLanguage] != null) {
      return messageMap[_currentLanguage]!;
    }

    // Fallback: translate from English
    final englishMessage = messageMap?['en'] ?? messageKey;
    if (_currentLanguage == 'en') {
      return englishMessage;
    }

    try {
      return await TranslationService.translateText(
        englishMessage,
        _currentLanguage,
        sourceLanguage: 'en'
      );
    } catch (e) {
      print('System message translation error: $e');
      return englishMessage; // Ultimate fallback
    }
  }

  Future<String> _getFallbackResponse(String message) async {
    final fallbackResponses = {
      'en': 'I understand your question. I\'m trying to serve you better with Google Cloud AI. Please provide more details.',
      'hi': 'मुझे आपका सवाल समझ आया। Google Cloud AI की मदद से मैं आपकी बेहतर सेवा करने की कोशिश कर रहा हूं। कृपया अधिक विवरण दें।',
      'pa': 'ਮੈਂ ਤੁਹਾਡਾ ਸਵਾਲ ਸਮਝ ਗਿਆ। Google Cloud AI ਨਾਲ ਮੈਂ ਤੁਹਾਡੀ ਬਿਹਤਰ ਸੇਵਾ ਦੀ ਕੋਸ਼ਿਸ਼ ਕਰ ਰਿਹਾ ਹਾਂ।',
      'bn': 'আমি আপনার প্রশ্ন বুঝতে পেরেছি। Google Cloud AI দিয়ে আমি আপনাকে আরও ভাল সেবা দেওয়ার চেষ্টা করছি।',
    };

    final response = fallbackResponses[_currentLanguage] ?? fallbackResponses['en']!;
    
    if (_currentLanguage == 'en') {
      return response;
    }

    try {
      return await TranslationService.translateText(
        fallbackResponses['en']!,
        _currentLanguage,
        sourceLanguage: 'en'
      );
    } catch (e) {
      return response;
    }
  }

  void startListening() {
    _isListening = true;
    notifyListeners();
  }

  void stopListening() {
    _isListening = false;
    notifyListeners();
  }

  // Handle feature suggestions tap with AI integration
  Future<void> handleFeatureSuggestion(String suggestion) async {
    String message = '';
    
    // Translate suggestion back to English for processing
    String englishSuggestion = suggestion;
    if (_currentLanguage != 'en') {
      try {
        englishSuggestion = await TranslationService.translateText(
          suggestion,
          'en',
          sourceLanguage: _currentLanguage
        );
      } catch (e) {
        print('Suggestion translation error: $e');
      }
    }
    
    // Map suggestions to actions
    if (englishSuggestion.toLowerCase().contains('photo') || 
        englishSuggestion.toLowerCase().contains('image') ||
        suggestion.contains('फोटो') || suggestion.contains('ਫੋਟੋ')) {
      message = await _getLocalizedSystemMessage('request_photo_enhancement');
    } else if (englishSuggestion.toLowerCase().contains('story') || 
               englishSuggestion.toLowerCase().contains('generate') ||
               suggestion.contains('कहानी') || suggestion.contains('ਕਹਾਣੀ')) {
      message = await _getLocalizedSystemMessage('request_story_generation');
    } else if (englishSuggestion.toLowerCase().contains('certificate') ||
               suggestion.contains('प्रमाणपत्र') || suggestion.contains('ਪ੍ਰਮਾਣ')) {
      message = await _getLocalizedSystemMessage('request_certificate');
    } else if (englishSuggestion.toLowerCase().contains('analytics') || 
               englishSuggestion.toLowerCase().contains('sales') ||
               suggestion.contains('बिक्री') || suggestion.contains('ਵਿਕਰੀ')) {
      message = await _getLocalizedSystemMessage('request_analytics');
    } else if (englishSuggestion.toLowerCase().contains('marketing') ||
               suggestion.contains('मार्केटिंग') || suggestion.contains('ਮਾਰਕੀਟਿੰਗ')) {
      message = await _getLocalizedSystemMessage('request_marketing');
    }
    
    if (message.isNotEmpty) {
      await sendMessage(message);
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
    _loadWelcomeMessage();
  }

  // Helper methods
  void _addSystemMessage(String message) {
    _messages.add({
      'text': message,
      'isUser': false,
      'timestamp': DateTime.now(),
      'isSystem': true,
      'language': _currentLanguage,
    });
    notifyListeners();
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

  // Dispose method to clean up resources
  void dispose() {
    AudioService.dispose();
    super.dispose();
  }
}