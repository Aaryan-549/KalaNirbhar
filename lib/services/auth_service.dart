import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../config/google_cloud_config.dart';

class AuthService {
  static String? _cachedAccessToken;
  static DateTime? _tokenExpiry;
  
  // Get access token for Google Cloud APIs
  static Future<String> getAccessToken() async {
    // Check if we have a valid cached token
    if (_cachedAccessToken != null && 
        _tokenExpiry != null && 
        DateTime.now().isBefore(_tokenExpiry!.subtract(const Duration(minutes: 5)))) {
      return _cachedAccessToken!;
    }
    
    try {
      // Method 1: Try service account authentication (recommended)
      final token = await _getServiceAccountToken();
      if (token != null) {
        return token;
      }
      
      // Method 2: Fallback to API key authentication (limited functionality)
      return await _getApiKeyToken();
      
    } catch (e) {
      print('Authentication error: $e');
      throw Exception('Failed to authenticate with Google Cloud: $e');
    }
  }
  
  // Service Account Authentication (preferred for Imagen API)
  static Future<String?> _getServiceAccountToken() async {
    try {
      // Option A: From environment variable (most secure)
      String? serviceAccountPath = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
      
      // Option A.1: Try from .env file if not found in system environment
      if (serviceAccountPath == null) {
        try {
          serviceAccountPath = dotenv.env['GOOGLE_APPLICATION_CREDENTIALS'];
          if (serviceAccountPath != null) {
            print('Using service account path from .env file: $serviceAccountPath');
          }
        } catch (e) {
          print('Could not read from .env file: $e');
        }
      }
      
      if (serviceAccountPath != null) {
        final file = File(serviceAccountPath);
        if (await file.exists()) {
          print('Loading service account from: $serviceAccountPath');
          final credentials = ServiceAccountCredentials.fromJson(
            jsonDecode(await file.readAsString())
          );
          
          final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
            credentials, 
            [GoogleCloudConfig.authScope], 
            http.Client()
          );
          
          _cachedAccessToken = accessCredentials.accessToken.data;
          _tokenExpiry = accessCredentials.accessToken.expiry;
          
          print('Successfully authenticated with service account');
          return _cachedAccessToken;
        } else {
          print('Service account file not found at: $serviceAccountPath');
        }
      } else {
        print('GOOGLE_APPLICATION_CREDENTIALS not found in environment or .env file');
      }
      
      // Option B: Check for service account file in project root
      final projectRoot = Directory.current.path;
      final serviceAccountFile = File('$projectRoot/service-account-key.json');
      if (await serviceAccountFile.exists()) {
        print('Found service account file in project root');
        final credentials = ServiceAccountCredentials.fromJson(
          jsonDecode(await serviceAccountFile.readAsString())
        );
        
        final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
          credentials, 
          [GoogleCloudConfig.authScope], 
          http.Client()
        );
        
        _cachedAccessToken = accessCredentials.accessToken.data;
        _tokenExpiry = accessCredentials.accessToken.expiry;
        
        print('Successfully authenticated with project service account');
        return _cachedAccessToken;
      } else {
        print('No service account file found in project root: ${serviceAccountFile.path}');
      }
      
      // Option B: From assets (less secure, for development only)
      // Uncomment this if you have service account JSON in assets
      /*
      try {
        final jsonString = await rootBundle.loadString(GoogleCloudConfig.serviceAccountPath);
        final credentials = ServiceAccountCredentials.fromJson(jsonDecode(jsonString));
        
        final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
          credentials, 
          [GoogleCloudConfig.authScope], 
          http.Client()
        );
        
        _cachedAccessToken = accessCredentials.accessToken.data;
        _tokenExpiry = accessCredentials.accessToken.expiry;
        
        return _cachedAccessToken;
      } catch (e) {
        print('Service account from assets failed: $e');
      }
      */
      
      return null;
    } catch (e) {
      print('Service account authentication failed: $e');
      return null;
    }
  }
  
  // API Key Authentication (fallback, limited functionality)
  static Future<String> _getApiKeyToken() async {
    // For development/testing purposes, you can use a mock token
    // In production, this should implement proper OAuth2 flow
    
    // Provide detailed instructions for setting up authentication
    final instructions = '''
╔═══════════════════════════════════════════════════════════════════════════════╗
║                     Google Cloud Authentication Required                      ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║ The Imagen API requires OAuth 2.0 authentication with a service account.     ║
║                                                                               ║
║ To fix this issue:                                                            ║
║                                                                               ║
║ 1. Go to Google Cloud Console: https://console.cloud.google.com/             ║
║ 2. Select project: perfect-lantern-472316-i5                                 ║
║ 3. Navigate to IAM & Admin > Service Accounts                                ║
║ 4. Create a new service account with these roles:                            ║
║    • Vertex AI User                                                           ║
║    • Cloud Vision AI User                                                     ║
║    • Project Editor                                                           ║
║ 5. Download the JSON key file                                                 ║
║ 6. Either:                                                                    ║
║    a) Set GOOGLE_APPLICATION_CREDENTIALS environment variable, OR             ║
║    b) Place the file as 'service-account-key.json' in project root           ║
║                                                                               ║
║ Project root: ${Directory.current.path}
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
''';
    
    print(instructions);
    
    throw Exception(
      'Imagen API requires OAuth 2.0 authentication. Please set up service account credentials.\n'
      'See console output for detailed setup instructions.'
    );
  }
  
  // OAuth 2.0 flow for client applications (alternative method)
  static Future<String?> getOAuth2Token() async {
    try {
      // This would implement the OAuth2 flow for client applications
      // For now, returning null as it requires user interaction
      return null;
    } catch (e) {
      print('OAuth2 authentication failed: $e');
      return null;
    }
  }
  
  // Validate if token is still valid
  static bool isTokenValid() {
    return _cachedAccessToken != null && 
           _tokenExpiry != null && 
           DateTime.now().isBefore(_tokenExpiry!);
  }
  
  // Clear cached token
  static void clearToken() {
    _cachedAccessToken = null;
    _tokenExpiry = null;
  }
  
  // Get authentication headers for API requests
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
}