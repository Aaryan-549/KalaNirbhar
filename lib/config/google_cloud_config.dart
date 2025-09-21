class GoogleCloudConfig {
  // TODO: Replace with your actual Google Cloud project details
  
  // Your Google Cloud Project ID
  static const String projectId = 'perfect-lantern-472316-i5'; // Replace with your actual project ID
  
  // Google Cloud Region (typically us-central1 or asia-south1)
  static const String location = 'us-central1';
  
  // API Keys - Get from Google Cloud Console (for APIs that support API keys)
  static const String geminiApiKey = 'AIzaSyBlMbjAWdhkN0iRLrW1NZPQg-TNJah4udA';
  static const String speechToTextApiKey = 'AIzaSyClVB2dCgnNOyyfacLIAbZpMvHTgnocJ0I';
  static const String textToSpeechApiKey = 'AIzaSyClVB2dCgnNOyyfacLIAbZpMvHTgnocJ0I';
  static const String translationApiKey = 'AIzaSyClVB2dCgnNOyyfacLIAbZpMvHTgnocJ0I';
  static const String visionApiKey = 'AIzaSyClVB2dCgnNOyyfacLIAbZpMvHTgnocJ0I';
  
  // Imagen API uses OAuth 2.0, not API keys - requires service account
  // This will be handled through service account authentication
  
  // Service Account JSON Path (for server-side operations)
  static const String serviceAccountPath = 'assets/service-account.json';
  
  // OAuth 2.0 Configuration for Imagen API
  static const String authScope = 'https://www.googleapis.com/auth/cloud-platform';
  static const String tokenEndpoint = 'https://oauth2.googleapis.com/token';
  
  // API Endpoints
  static const String geminiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent';
  static const String speechToTextEndpoint = 'https://speech.googleapis.com/v1/speech:recognize';
  static const String textToSpeechEndpoint = 'https://texttospeech.googleapis.com/v1/text:synthesize';
  static const String translationEndpoint = 'https://translation.googleapis.com/language/translate/v2';
  static const String visionEndpoint = 'https://vision.googleapis.com/v1/images:annotate';
  static const String imagenEndpoint = 'https://us-central1-aiplatform.googleapis.com/v1/projects/$projectId/locations/$location/publishers/google/models/imagegeneration@006:predict';
  
  // Language Codes for Translation
  static const Map<String, String> supportedLanguages = {
    'hi': 'Hindi',
    'en': 'English', 
    'bn': 'Bengali',
    'mr': 'Marathi',
    'ta': 'Tamil',
    'te': 'Telugu',
    'gu': 'Gujarati',
    'kn': 'Kannada',
    'ml': 'Malayalam',
    'pa': 'Punjabi',
  };
  
  // Voice Configuration for Text-to-Speech
  static const Map<String, String> voiceNames = {
    'hi': 'hi-IN-Wavenet-A',
    'en': 'en-US-Wavenet-F',
    'bn': 'bn-IN-Wavenet-A',
    'mr': 'mr-IN-Wavenet-A',
    'ta': 'ta-IN-Wavenet-A',
    'te': 'te-IN-Wavenet-A',
  };
  
  // Audio Configuration
  static const String audioFormat = 'MP3';
  static const double speakingRate = 1.0;
  static const double pitch = 0.0;
  
  // Image Processing Configuration
  static const int maxImageSize = 4 * 1024 * 1024; // 4MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Rate Limiting (requests per minute)
  static const int maxRequestsPerMinute = 60;
  static const int retryAttempts = 3;
  static const Duration requestTimeout = Duration(seconds: 30);
}