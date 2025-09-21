import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/google_cloud_config.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  
  // Generate AI response for chat
  static Future<String> generateChatResponse(String message, String language) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/gemini-2.0-flash-exp:generateContent?key=${GoogleCloudConfig.geminiApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": _buildChatPrompt(message, language)
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.7,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 1024,
          },
          "safetySettings": [
            {
              "category": "HARM_CATEGORY_HARASSMENT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
              "category": "HARM_CATEGORY_HATE_SPEECH", 
              "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text ?? 'मुझे समझने में कुछ समस्या हुई है। कृपया दोबारा कोशिश करें।';
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        return _getFallbackResponse(message, language);
      }
    } catch (e) {
      print('Gemini Service Error: $e');
      return _getFallbackResponse(message, language);
    }
  }

  // Add this method to your GeminiService class

static Future<String> generateChatResponseWithContext(
  String message, 
  String language,
  String conversationContext,
) async {
  try {
    final prompt = '''
$conversationContext

Instructions for response:
- Keep responses concise (1-2 sentences for simple questions)
- Be helpful and direct
- Respond in $language language
- For handicraft/artisan questions, be specific and practical
- Avoid overly long explanations unless specifically asked

User question: $message

Response:''';

    final response = await http.post(
      Uri.parse('${GoogleCloudConfig.geminiEndpoint}?key=${GoogleCloudConfig.geminiApiKey}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [{
          "parts": [{
            "text": prompt
          }]
        }],
        "generationConfig": {
          "temperature": 0.7,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 150,  // Limited for concise responses
          "candidateCount": 1,
        },
        "safetySettings": [
          {
            "category": "HARM_CATEGORY_HARASSMENT",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE"
          },
          {
            "category": "HARM_CATEGORY_HATE_SPEECH", 
            "threshold": "BLOCK_MEDIUM_AND_ABOVE"
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        return content?.toString().trim() ?? 'I understand your question. How can I help you better?';
      }
    } else {
      print('Gemini API Error: ${response.statusCode} - ${response.body}');
    }
    
    return 'I understand your question. How can I help you better?';
  } catch (e) {
    print('Gemini Chat Error: $e');
    return 'I understand your question. How can I help you better?';
  }
}

  // Generate product description
  static Future<String> generateProductDescription(Map<String, dynamic> productInfo, String language) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/gemini-2.0-flash-exp:generateContent?key=${GoogleCloudConfig.geminiApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": _buildProductDescriptionPrompt(productInfo, language)
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.8,
            "maxOutputTokens": 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text ?? 'उत्पाद विवरण जेनरेट करने में समस्या हुई।';
      } else {
        return 'उत्पाد विवरण जेनरेट करने में समस्या हुई।';
      }
    } catch (e) {
      print('Product Description Error: $e');
      return 'उत्पाद विवरण जेनरेट करने में समस्या हुई।';
    }
  }

  // Generate marketing content
  static Future<Map<String, String>> generateMarketingContent(Map<String, dynamic> productInfo, String platform, String language) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/gemini-2.0-flash-exp:generateContent?key=${GoogleCloudConfig.geminiApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": _buildMarketingPrompt(productInfo, platform, language)
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return _parseMarketingContent(text ?? '');
      } else {
        return {
          'caption': 'यह खूबसूरत हस्तशिल्प उत्पाद देखें!',
          'hashtags': '#हस्तशिल्प #भारतीयकला #हैंडमेड',
          'description': 'पारंपरिक भारतीय शिल्प कौशल से बना यह अनुपम उत्पाد।'
        };
      }
    } catch (e) {
      print('Marketing Content Error: $e');
      return {
        'caption': 'यह खूबसूरत हस्तशिल्प उत्पाद देखें!',
        'hashtags': '#हस्तशिल्प #भारतीयकला #हैंडमेड',
        'description': 'पारंपरिक भारतीय शिल्प कौशल से बना यह अनुपम उत्पाद।'
      };
    }
  }

  static String _buildChatPrompt(String message, String language) {
    return '''
आप KalaNirbhar ऐप के AI असिस्टेंट हैं। आप भारतीय कलाकारों और शिल्पकारों की मदद करते हैं।

आपके मुख्य काम:
1. उत्पादों की फोटो बेहतर बनाना
2. उत्पादों की कहानी लिखना
3. डिजिटल प्रमाणपत्र बनाना
4. मार्केटिंग में मदद करना
5. बिक्री का विश्लेषण करना
6. अन्य कलाकारों से जोड़ना

User का संदेश: "$message"
Language: $language

कृपया $language भाषा में उत्तर दें। सहायक, मित्रवत और प्रेरणादायक जवाब दें।
''';
  }

  static String _buildProductDescriptionPrompt(Map<String, dynamic> productInfo, String language) {
    return '''
एक professional e-commerce product description लिखें:

उत्पाद जानकारी:
- नाम: ${productInfo['name'] ?? 'हस्तशिल्प उत्पाद'}
- श्रेणी: ${productInfo['category'] ?? 'हस्तशिल्प'}
- सामग्री: ${productInfo['material'] ?? 'प्राकृतिक सामग्री'}
- रंग: ${productInfo['color'] ?? 'पारंपरिक रंग'}
- आकार: ${productInfo['size'] ?? 'मध्यम'}
- कलाकार कहानी: ${productInfo['story'] ?? 'पारंपरिक शिल्प कौशल'}
- सांस्कृतिक महत्व: ${productInfo['cultural_significance'] ?? 'भारतीय विरासत'}

Requirements:
1. SEO-friendly title (60 characters)
2. Engaging description (150-200 words)
3. Cultural story और heritage highlight करें
4. Quality और craftsmanship emphasize करें  
5. $language भाषा में लिखें
6. Etsy/Amazon के लिए optimize करें

Format:
TITLE: [SEO Title]
DESCRIPTION: [Detailed Description]
TAGS: [Relevant Tags]
''';
  }

  static String _buildMarketingPrompt(Map<String, dynamic> productInfo, String platform, String language) {
    return '''
$platform के लिए marketing content बनाएं:

उत्पाद: ${productInfo['name'] ?? 'हस्तशिल्प'}
Platform: $platform
Language: $language

बनाएं:
1. CAPTION: Engaging social media caption (50-100 words)
2. HASHTAGS: Relevant hashtags (10-15)  
3. DESCRIPTION: Detailed product description
4. CALL_TO_ACTION: Action-oriented ending

Focus on:
- Traditional craftsmanship
- Cultural heritage
- Unique selling points
- Emotional connection
- Platform-specific optimization

Format में provide करें:
CAPTION: [caption text]
HASHTAGS: [hashtags]
DESCRIPTION: [description]
CTA: [call to action]
''';
  }

  static Map<String, String> _parseMarketingContent(String content) {
    final Map<String, String> result = {};
    
    final lines = content.split('\n');
    String currentKey = '';
    String currentValue = '';
    
    for (String line in lines) {
      if (line.startsWith('CAPTION:')) {
        if (currentKey.isNotEmpty) result[currentKey] = currentValue.trim();
        currentKey = 'caption';
        currentValue = line.substring(8).trim();
      } else if (line.startsWith('HASHTAGS:')) {
        if (currentKey.isNotEmpty) result[currentKey] = currentValue.trim();
        currentKey = 'hashtags';
        currentValue = line.substring(9).trim();
      } else if (line.startsWith('DESCRIPTION:')) {
        if (currentKey.isNotEmpty) result[currentKey] = currentValue.trim();
        currentKey = 'description';
        currentValue = line.substring(12).trim();
      } else if (line.startsWith('CTA:')) {
        if (currentKey.isNotEmpty) result[currentKey] = currentValue.trim();
        currentKey = 'cta';
        currentValue = line.substring(4).trim();
      } else if (currentKey.isNotEmpty) {
        currentValue += ' ' + line;
      }
    }
    
    if (currentKey.isNotEmpty) result[currentKey] = currentValue.trim();
    
    return result;
  }

  static String _getFallbackResponse(String message, String language) {
    final responses = {
      'hi': 'मुझे आपका सवाल समझ आया। मैं आपकी मदद करने के लिए यहाँ हूँ। कृपया अधिक विवरण दें।',
      'en': 'I understand your question. I\'m here to help you. Please provide more details.',
      'bn': 'আমি আপনার প্রশ্ন বুঝতে পেরেছি। আমি আপনাকে সাহায্য করতে এখানে আছি।',
    };
    
    return responses[language] ?? responses['hi']!;
  }
}