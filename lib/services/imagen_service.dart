import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/google_cloud_config.dart';

class ImagenService {
  
  // Generate professional product photos with different backgrounds
  static Future<List<Uint8List>> enhanceProductPhoto(
    Uint8List originalImage, 
    List<String> backgroundStyles,
    String productDescription
  ) async {
    List<Uint8List> enhancedImages = [];
    
    for (String style in backgroundStyles) {
      try {
        final enhanced = await _generateEnhancedImage(originalImage, style, productDescription);
        if (enhanced != null) {
          enhancedImages.add(enhanced);
        }
      } catch (e) {
        print('Image enhancement error for style $style: $e');
      }
    }
    
    return enhancedImages;
  }

  // Generate single enhanced image
  static Future<Uint8List?> _generateEnhancedImage(
    Uint8List originalImage,
    String backgroundStyle,
    String productDescription
  ) async {
    try {
      final base64Image = base64Encode(originalImage);
      
      final prompt = _buildEnhancementPrompt(backgroundStyle, productDescription);
      
      final response = await http.post(
        Uri.parse('${GoogleCloudConfig.imagenEndpoint}'),
        headers: {
          'Authorization': 'Bearer ${await _getAccessToken()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "instances": [
            {
              "prompt": prompt,
              "image": {
                "bytesBase64Encoded": base64Image
              },
              "parameters": {
                "sampleCount": 1,
                "mode": "upscale", // or "generate"
                "aspectRatio": "1:1", // Square for e-commerce
                "negativePrompt": "blurry, low quality, distorted, watermark, text",
                "guidanceScale": 15,
                "seed": DateTime.now().millisecondsSinceEpoch % 1000000,
              }
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictions = data['predictions'] as List;
        if (predictions.isNotEmpty) {
          final imageData = predictions[0]['bytesBase64Encoded'];
          return base64Decode(imageData);
        }
      } else {
        print('Imagen API Error: ${response.statusCode} - ${response.body}');
      }
      
      return null;
    } catch (e) {
      print('Image Enhancement Error: $e');
      return null;
    }
  }

  // Remove background and create clean product image
  static Future<Uint8List?> removeBackground(Uint8List originalImage) async {
    try {
      final base64Image = base64Encode(originalImage);
      
      final response = await http.post(
        Uri.parse('${GoogleCloudConfig.imagenEndpoint}'),
        headers: {
          'Authorization': 'Bearer ${await _getAccessToken()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "instances": [
            {
              "prompt": "Product on pure white background, professional photography, clean, no shadows",
              "image": {
                "bytesBase64Encoded": base64Image
              },
              "parameters": {
                "mode": "edit",
                "maskMode": "background",
                "guidanceScale": 20,
              }
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictions = data['predictions'] as List;
        if (predictions.isNotEmpty) {
          final imageData = predictions[0]['bytesBase64Encoded'];
          return base64Decode(imageData);
        }
      }
      
      return null;
    } catch (e) {
      print('Background Removal Error: $e');
      return null;
    }
  }

  // Create lifestyle mockups showing product in use
  static Future<List<Uint8List>> createLifestyleMockups(
    Uint8List productImage, 
    String productType,
    List<String> lifestyleScenes
  ) async {
    List<Uint8List> mockups = [];
    
    for (String scene in lifestyleScenes) {
      try {
        final mockup = await _generateLifestyleMockup(productImage, productType, scene);
        if (mockup != null) {
          mockups.add(mockup);
        }
      } catch (e) {
        print('Lifestyle mockup error for scene $scene: $e');
      }
    }
    
    return mockups;
  }

  static Future<Uint8List?> _generateLifestyleMockup(
    Uint8List productImage,
    String productType,
    String scene
  ) async {
    try {
      final base64Image = base64Encode(productImage);
      
      final prompt = _buildLifestylePrompt(productType, scene);
      
      final response = await http.post(
        Uri.parse('${GoogleCloudConfig.imagenEndpoint}'),
        headers: {
          'Authorization': 'Bearer ${await _getAccessToken()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "instances": [
            {
              "prompt": prompt,
              "image": {
                "bytesBase64Encoded": base64Image
              },
              "parameters": {
                "mode": "generate",
                "guidanceScale": 12,
                "aspectRatio": "4:3",
              }
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictions = data['predictions'] as List;
        if (predictions.isNotEmpty) {
          final imageData = predictions[0]['bytesBase64Encoded'];
          return base64Decode(imageData);
        }
      }
      
      return null;
    } catch (e) {
      print('Lifestyle Mockup Error: $e');
      return null;
    }
  }

  // Upscale image for better quality
  static Future<Uint8List?> upscaleImage(Uint8List originalImage, {int scaleFactor = 2}) async {
    try {
      final base64Image = base64Encode(originalImage);
      
      final response = await http.post(
        Uri.parse('${GoogleCloudConfig.imagenEndpoint}'),
        headers: {
          'Authorization': 'Bearer ${await _getAccessToken()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "instances": [
            {
              "prompt": "High resolution, sharp details, professional quality, enhanced clarity",
              "image": {
                "bytesBase64Encoded": base64Image
              },
              "parameters": {
                "mode": "upscale",
                "upscaleFactor": scaleFactor,
                "guidanceScale": 10,
              }
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictions = data['predictions'] as List;
        if (predictions.isNotEmpty) {
          final imageData = predictions[0]['bytesBase64Encoded'];
          return base64Decode(imageData);
        }
      }
      
      return null;
    } catch (e) {
      print('Image Upscaling Error: $e');
      return null;
    }
  }

  // Generate product variations (different colors, angles)
  static Future<List<Uint8List>> generateProductVariations(
    Uint8List originalImage,
    String productDescription,
    List<String> variations
  ) async {
    List<Uint8List> variationImages = [];
    
    for (String variation in variations) {
      try {
        final varied = await _generateVariation(originalImage, productDescription, variation);
        if (varied != null) {
          variationImages.add(varied);
        }
      } catch (e) {
        print('Product variation error for $variation: $e');
      }
    }
    
    return variationImages;
  }

  static Future<Uint8List?> _generateVariation(
    Uint8List originalImage,
    String productDescription,
    String variation
  ) async {
    try {
      final base64Image = base64Encode(originalImage);
      
      final prompt = '$productDescription, $variation, professional photography, high quality';
      
      final response = await http.post(
        Uri.parse('${GoogleCloudConfig.imagenEndpoint}'),
        headers: {
          'Authorization': 'Bearer ${await _getAccessToken()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "instances": [
            {
              "prompt": prompt,
              "image": {
                "bytesBase64Encoded": base64Image
              },
              "parameters": {
                "mode": "edit",
                "guidanceScale": 12,
              }
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictions = data['predictions'] as List;
        if (predictions.isNotEmpty) {
          final imageData = predictions[0]['bytesBase64Encoded'];
          return base64Decode(imageData);
        }
      }
      
      return null;
    } catch (e) {
      print('Generate Variation Error: $e');
      return null;
    }
  }

  // Helper methods
  static String _buildEnhancementPrompt(String backgroundStyle, String productDescription) {
    final stylePrompts = {
      'white_background': 'Product on pure white background, professional studio lighting, clean, minimal shadows',
      'lifestyle_modern': 'Product in modern, minimalist interior setting, natural lighting, contemporary style',
      'lifestyle_traditional': 'Product in traditional Indian home setting, warm lighting, cultural elements',
      'outdoor_natural': 'Product in natural outdoor setting, soft natural lighting, organic background',
      'luxury_elegant': 'Product on elegant marble surface, premium lighting, luxurious atmosphere',
      'colorful_vibrant': 'Product with vibrant colorful background, artistic lighting, creative composition',
    };
    
    final basePrompt = stylePrompts[backgroundStyle] ?? stylePrompts['white_background']!;
    return '$productDescription, $basePrompt, high resolution, professional photography, sharp details';
  }

  static String _buildLifestylePrompt(String productType, String scene) {
    final scenePrompts = {
      'living_room': 'Beautiful modern living room, cozy atmosphere, natural lighting, home decor',
      'bedroom': 'Elegant bedroom interior, soft lighting, comfortable setting, home decoration',
      'kitchen': 'Clean modern kitchen, bright lighting, functional space, home environment',
      'office': 'Professional office space, clean lighting, work environment, modern interior',
      'garden': 'Beautiful garden setting, natural outdoor lighting, plants and flowers',
      'traditional_home': 'Traditional Indian home interior, cultural elements, warm atmosphere',
    };
    
    final scenePrompt = scenePrompts[scene] ?? scenePrompts['living_room']!;
    return '$productType placed in $scenePrompt, realistic placement, natural integration, professional photography';
  }

  // Get access token for Google Cloud APIs
  static Future<String> _getAccessToken() async {
    // TODO: Implement proper OAuth2 flow or service account authentication
    // For now, return placeholder - you'll need to implement this based on your auth method
    
    // Option 1: Service Account (recommended for server-side)
    // Use google_auth_library package to get access token from service account JSON
    
    // Option 2: OAuth2 (for client-side applications)
    // Implement OAuth2 flow to get user access token
    
    return 'YOUR_ACCESS_TOKEN_HERE'; // Placeholder
  }

  // Predefined background styles for product photography
  static List<Map<String, String>> getBackgroundStyles() {
    return [
      {
        'id': 'white_background',
        'name': 'White Background',
        'description': 'Clean white background for e-commerce',
        'hindi': 'सफेद बैकग्राउंड'
      },
      {
        'id': 'lifestyle_modern',
        'name': 'Modern Lifestyle',
        'description': 'Modern home setting',
        'hindi': 'आधुनिक घर'
      },
      {
        'id': 'lifestyle_traditional',
        'name': 'Traditional Setting',
        'description': 'Traditional Indian home',
        'hindi': 'पारंपरिक घर'
      },
      {
        'id': 'outdoor_natural',
        'name': 'Natural Outdoor',
        'description': 'Natural outdoor environment',
        'hindi': 'प्राकृतिक वातावरण'
      },
      {
        'id': 'luxury_elegant',
        'name': 'Luxury Setting',
        'description': 'Premium elegant background',
        'hindi': 'लक्जरी सेटिंग'
      },
    ];
  }

  // Get lifestyle scene options
  static List<Map<String, String>> getLifestyleScenes() {
    return [
      {
        'id': 'living_room',
        'name': 'Living Room',
        'hindi': 'बैठक'
      },
      {
        'id': 'bedroom',
        'name': 'Bedroom', 
        'hindi': 'शयन कक्ष'
      },
      {
        'id': 'kitchen',
        'name': 'Kitchen',
        'hindi': 'रसोई'
      },
      {
        'id': 'traditional_home',
        'name': 'Traditional Home',
        'hindi': 'पारंपरिक घर'
      },
      {
        'id': 'garden',
        'name': 'Garden',
        'hindi': 'बगीचा'
      },
    ];
  }

  // Get product variation options
  static List<Map<String, String>> getVariationOptions() {
    return [
      {
        'id': 'different_angle',
        'name': 'Different Angle',
        'description': 'Same product from different viewing angle',
        'hindi': 'अलग कोण'
      },
      {
        'id': 'close_up',
        'name': 'Close-up Detail',
        'description': 'Close-up shot showing intricate details',
        'hindi': 'नजदीकी दृश्य'
      },
      {
        'id': 'group_shot',
        'name': 'Group with Similar Items',
        'description': 'Product grouped with complementary items',
        'hindi': 'समूह फोटो'
      },
      {
        'id': 'size_comparison',
        'name': 'Size Reference',
        'description': 'Product with size reference object',
        'hindi': 'आकार तुलना'
      },
    ];
  }
}