import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/google_cloud_config.dart';

class VisionService {
  
  // Analyze product image for enhancement recommendations
  static Future<Map<String, dynamic>> analyzeProductImage(Uint8List imageData) async {
    try {
      final base64Image = base64Encode(imageData);
      
      final response = await http.post(
        Uri.parse('${GoogleCloudConfig.visionEndpoint}?key=${GoogleCloudConfig.visionApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "requests": [
            {
              "image": {
                "content": base64Image
              },
              "features": [
                {"type": "OBJECT_LOCALIZATION", "maxResults": 10},
                {"type": "LABEL_DETECTION", "maxResults": 20},
                {"type": "IMAGE_PROPERTIES"},
                {"type": "CROP_HINTS", "maxResults": 5},
                {"type": "SAFE_SEARCH_DETECTION"},
                {"type": "TEXT_DETECTION"}
              ],
              "imageContext": {
                "cropHintsParams": {
                  "aspectRatios": [1.0, 1.33, 0.75] // Square, 4:3, 3:4 ratios
                }
              }
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['responses'][0];
        
        return {
          'objects': _parseObjects(result['localizedObjectAnnotations'] ?? []),
          'labels': _parseLabels(result['labelAnnotations'] ?? []),
          'colors': _parseColors(result['imagePropertiesAnnotation'] ?? {}),
          'cropHints': _parseCropHints(result['cropHintsAnnotation'] ?? {}),
          'textDetections': _parseText(result['textAnnotations'] ?? []),
          'safeSearch': _parseSafeSearch(result['safeSearchAnnotation'] ?? {}),
          'recommendations': _generateRecommendations(result),
          'quality': _assessImageQuality(result),
        };
      } else {
        print('Vision API Error: ${response.statusCode} - ${response.body}');
        return _getFallbackAnalysis();
      }
    } catch (e) {
      print('Vision Service Error: $e');
      return _getFallbackAnalysis();
    }
  }

  // Extract text from product images (OCR)
  static Future<String> extractTextFromImage(Uint8List imageData) async {
    try {
      final base64Image = base64Encode(imageData);
      
      final response = await http.post(
        Uri.parse('${GoogleCloudConfig.visionEndpoint}?key=${GoogleCloudConfig.visionApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "requests": [
            {
              "image": {
                "content": base64Image
              },
              "features": [
                {"type": "TEXT_DETECTION"}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['responses'][0];
        final textAnnotations = result['textAnnotations'] as List? ?? [];
        
        if (textAnnotations.isNotEmpty) {
          return textAnnotations[0]['description'] ?? '';
        }
      }
      return '';
    } catch (e) {
      print('Text Extraction Error: $e');
      return '';
    }
  }

  // Detect product category automatically
  static Future<String> detectProductCategory(Uint8List imageData) async {
    try {
      final analysis = await analyzeProductImage(imageData);
      final labels = analysis['labels'] as List<Map<String, dynamic>>? ?? [];
      
      // Category mapping based on detected labels
      const categoryKeywords = {
        'handicraft': ['handicraft', 'craft', 'handmade', 'pottery', 'ceramic', 'wood', 'carving'],
        'textile': ['fabric', 'cloth', 'textile', 'embroidery', 'weaving', 'silk', 'cotton'],
        'jewelry': ['jewelry', 'ornament', 'accessory', 'gold', 'silver', 'necklace', 'bracelet'],
        'painting': ['painting', 'art', 'canvas', 'artwork', 'miniature', 'portrait'],
        'sculpture': ['sculpture', 'statue', 'carving', 'figurine', 'bronze', 'marble'],
        'home-decor': ['vase', 'lamp', 'decoration', 'ornament', 'furniture', 'decorative']
      };
      
      for (final label in labels) {
        final labelText = label['description'].toString().toLowerCase();
        for (final entry in categoryKeywords.entries) {
          if (entry.value.any((keyword) => labelText.contains(keyword))) {
            return entry.key;
          }
        }
      }
      
      return 'handicraft'; // Default category
    } catch (e) {
      print('Category Detection Error: $e');
      return 'handicraft';
    }
  }

  // Generate image enhancement suggestions
  static Future<Map<String, dynamic>> getEnhancementSuggestions(Uint8List imageData) async {
    final analysis = await analyzeProductImage(imageData);
    final quality = analysis['quality'] as Map<String, dynamic>;
    final colors = analysis['colors'] as Map<String, dynamic>;
    final objects = analysis['objects'] as List<Map<String, dynamic>>;
    
    List<String> suggestions = [];
    Map<String, dynamic> parameters = {};
    
    // Lighting analysis
    final brightness = colors['avgBrightness'] ?? 0.5;
    if (brightness < 0.3) {
      suggestions.add('Increase brightness - image appears too dark');
      parameters['brightness'] = 0.3 - brightness;
    } else if (brightness > 0.8) {
      suggestions.add('Reduce brightness - image appears overexposed');
      parameters['brightness'] = brightness - 0.8;
    }
    
    // Background suggestions
    if (objects.length > 1) {
      suggestions.add('Consider using a plain background to highlight the product');
      parameters['backgroundRemoval'] = true;
    }
    
    // Composition suggestions
    final cropHints = analysis['cropHints'] as List<Map<String, dynamic>>? ?? [];
    if (cropHints.isNotEmpty) {
      suggestions.add('Crop image for better composition');
      parameters['cropHint'] = cropHints[0];
    }
    
    // Quality improvements
    if (quality['sharpness'] < 0.6) {
      suggestions.add('Apply sharpening filter to improve clarity');
      parameters['sharpen'] = true;
    }
    
    if (quality['contrast'] < 0.5) {
      suggestions.add('Increase contrast to make product stand out');
      parameters['contrast'] = 0.2;
    }
    
    return {
      'suggestions': suggestions,
      'parameters': parameters,
      'autoFix': suggestions.length <= 2, // Auto-apply if few issues
    };
  }

  // Helper methods for parsing Vision API responses
  static List<Map<String, dynamic>> _parseObjects(List objects) {
    return objects.map((obj) => {
      'name': obj['name'],
      'score': obj['score'],
      'boundingBox': obj['boundingPoly'],
    }).toList();
  }

  static List<Map<String, dynamic>> _parseLabels(List labels) {
    return labels.map((label) => {
      'description': label['description'],
      'score': label['score'],
      'confidence': label['score'] * 100,
    }).toList();
  }

  static Map<String, dynamic> _parseColors(Map imageProps) {
    final colors = imageProps['dominantColors']?['colors'] as List? ?? [];
    double avgBrightness = 0.5;
    
    if (colors.isNotEmpty) {
      double totalBrightness = 0;
      for (final color in colors) {
        final rgb = color['color'];
        final r = (rgb['red'] ?? 0) / 255.0;
        final g = (rgb['green'] ?? 0) / 255.0;
        final b = (rgb['blue'] ?? 0) / 255.0;
        totalBrightness += (r + g + b) / 3;
      }
      avgBrightness = totalBrightness / colors.length;
    }
    
    return {
      'dominantColors': colors,
      'avgBrightness': avgBrightness,
    };
  }

  static List<Map<String, dynamic>> _parseCropHints(Map cropHints) {
    final hints = cropHints['cropHints'] as List? ?? [];
    return hints.map((hint) => {
      'boundingPoly': hint['boundingPoly'],
      'confidence': hint['confidence'],
      'importance': hint['importanceFraction'],
    }).toList();
  }

  static List<Map<String, dynamic>> _parseText(List textAnnotations) {
    return textAnnotations.map((text) => {
      'description': text['description'],
      'boundingPoly': text['boundingPoly'],
      'confidence': text['confidence'] ?? 1.0,
    }).toList();
  }

  static Map<String, dynamic> _parseSafeSearch(Map safeSearch) {
    return {
      'adult': safeSearch['adult'] ?? 'UNKNOWN',
      'violence': safeSearch['violence'] ?? 'UNKNOWN',
      'racy': safeSearch['racy'] ?? 'UNKNOWN',
      'safe': safeSearch['adult'] == 'VERY_UNLIKELY' && 
             safeSearch['violence'] == 'VERY_UNLIKELY' &&
             safeSearch['racy'] == 'VERY_UNLIKELY',
    };
  }

  static Map<String, dynamic> _assessImageQuality(Map result) {
    // Simple quality assessment based on available data
    final labels = result['labelAnnotations'] as List? ?? [];
    final objects = result['localizedObjectAnnotations'] as List? ?? [];
    
    double sharpness = 0.7; // Default assumption
    double contrast = 0.6;  // Default assumption
    double composition = objects.isNotEmpty ? 0.8 : 0.5;
    
    // More objects/labels typically indicate clearer images
    if (labels.length > 10) sharpness += 0.2;
    if (objects.length > 0) contrast += 0.2;
    
    return {
      'sharpness': sharpness.clamp(0.0, 1.0),
      'contrast': contrast.clamp(0.0, 1.0),
      'composition': composition,
      'overall': (sharpness + contrast + composition) / 3,
    };
  }

  static List<String> _generateRecommendations(Map result) {
    List<String> recommendations = [];
    
    final objects = result['localizedObjectAnnotations'] as List? ?? [];
    final labels = result['labelAnnotations'] as List? ?? [];
    
    if (objects.isEmpty) {
      recommendations.add('Consider taking a clearer photo with the product more visible');
    }
    
    if (labels.length < 5) {
      recommendations.add('Use better lighting to help detect product features');
    }
    
    // Check for background complexity
    bool hasComplexBackground = labels.any((label) => 
      ['furniture', 'room', 'wall', 'floor'].contains(label['description'].toString().toLowerCase())
    );
    
    if (hasComplexBackground) {
      recommendations.add('Use a plain background to make the product stand out');
    }
    
    return recommendations;
  }

  static Map<String, dynamic> _getFallbackAnalysis() {
    return {
      'objects': [],
      'labels': [
        {'description': 'handicraft', 'score': 0.8, 'confidence': 80.0},
        {'description': 'product', 'score': 0.7, 'confidence': 70.0},
      ],
      'colors': {'dominantColors': [], 'avgBrightness': 0.5},
      'cropHints': [],
      'textDetections': [],
      'safeSearch': {'safe': true},
      'recommendations': ['Take a clearer photo in better lighting'],
      'quality': {'sharpness': 0.6, 'contrast': 0.5, 'composition': 0.5, 'overall': 0.53},
    };
  }
}