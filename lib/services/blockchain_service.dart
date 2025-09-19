import 'dart:convert';
import 'dart:math';
import '../config/google_cloud_config.dart';

class BlockchainService {
  // Mock Polygon configuration for demo
  static const String polygonRpcUrl = 'https://rpc-mumbai.maticvigil.com/';
  static const String polygonChainId = '80001';
  static const String contractAddress = '0x742d35Cc67dF5C3d6C4fA4D4cD6d8f6a3dE5d2F4';
  
  // Mock certificate storage
  static final Map<String, Map<String, dynamic>> _mockCertificates = {};
  static int _nextTokenId = 1670000000000;

  // Initialize blockchain service (mock)
  static Future<void> initialize() async {
    // Mock initialization
    print('Blockchain service initialized (Demo Mode)');
  }

  // Create digital certificate (mock implementation)
  static Future<Map<String, dynamic>> createCertificate({
    required String artisanName,
    required String productName,
    required String productDescription,
    required String craftType,
    required String location,
    required String imageHash,
    required String userWalletAddress,
  }) async {
    try {
      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Generate unique token ID
      final tokenId = _nextTokenId++;
      final creationTime = DateTime.now();
      
      // Create metadata for the NFT
      final metadata = {
        "name": "Certificate of Authenticity - $productName",
        "description": "Digital certificate verifying the authenticity of $productName created by $artisanName",
        "image": "ipfs://$imageHash",
        "attributes": [
          {"trait_type": "Artisan", "value": artisanName},
          {"trait_type": "Product", "value": productName},
          {"trait_type": "Craft Type", "value": craftType},
          {"trait_type": "Location", "value": location},
          {"trait_type": "Creation Date", "value": creationTime.toIso8601String()},
          {"trait_type": "Platform", "value": "KalaNirbhar"},
          {"trait_type": "Verified", "value": "True"},
        ],
        "external_url": "https://kalanirbhar.com/certificate/$imageHash",
        "background_color": "4285F4",
      };

      // Generate mock IPFS hash
      final metadataHash = _generateMockIPFSHash(jsonEncode(metadata));
      
      // Generate mock transaction hash
      final transactionHash = _generateMockTransactionHash();
      
      // Create certificate record
      final certificate = {
        'tokenId': tokenId.toString(),
        'contractAddress': contractAddress,
        'network': 'Polygon Mumbai',
        'chainId': polygonChainId,
        'artisanName': artisanName,
        'productName': productName,
        'productDescription': productDescription,
        'craftType': craftType,
        'location': location,
        'imageHash': imageHash,
        'metadataHash': metadataHash,
        'walletAddress': userWalletAddress,
        'transactionHash': transactionHash,
        'explorerUrl': 'https://mumbai.polygonscan.com/tx/$transactionHash',
        'certificateUrl': 'https://kalanirbhar.com/certificate/${tokenId.toString()}',
        'createdAt': creationTime.toIso8601String(),
        'verified': true,
        'status': 'minted',
        'gasUsed': '0.0001 MATIC',
        'blockNumber': _generateMockBlockNumber(),
      };

      // Store mock certificate
      _mockCertificates[tokenId.toString()] = certificate;

      return {
        'success': true,
        'certificate': certificate,
        'message': 'Digital certificate created successfully on Polygon blockchain!',
        'estimatedValue': 'Authenticity: Verified ✓',
      };
    } catch (e) {
      print('Certificate creation error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Certificate creation temporarily unavailable. Your product details have been saved.',
      };
    }
  }

  // Verify certificate authenticity (mock)
  static Future<Map<String, dynamic>> verifyCertificate(String tokenId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      final certificate = _mockCertificates[tokenId];
      
      if (certificate != null) {
        return {
          'verified': true,
          'certificate': certificate,
          'owner': certificate['walletAddress'],
          'contractAddress': contractAddress,
          'network': 'Polygon Mumbai',
          'explorerUrl': certificate['explorerUrl'],
          'authenticity': 'VERIFIED',
          'trustScore': 98.5,
        };
      } else {
        // Generate demo certificate for verification
        return {
          'verified': true,
          'certificate': _generateDemoCertificate(tokenId),
          'authenticity': 'VERIFIED',
          'trustScore': 96.8,
        };
      }
    } catch (e) {
      return {
        'verified': false,
        'error': 'Certificate not found',
        'trustScore': 0.0,
      };
    }
  }

  // Get certificate history for an artisan (mock)
  static Future<List<Map<String, dynamic>>> getCertificateHistory(String walletAddress) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Return stored certificates for this wallet
      final userCertificates = _mockCertificates.values
          .where((cert) => cert['walletAddress'] == walletAddress)
          .toList();
      
      // If no certificates, return demo data
      if (userCertificates.isEmpty) {
        return _generateDemoCertificateHistory();
      }
      
      return userCertificates;
    } catch (e) {
      return _generateDemoCertificateHistory();
    }
  }

  // Create wallet for new artisan (mock)
  static Future<Map<String, String>> createWallet() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Generate mock wallet address
      final address = _generateMockWalletAddress();
      final privateKey = _generateMockPrivateKey();
      
      return {
        'address': address,
        'privateKey': privateKey,
        'publicKey': address,
        'network': 'Polygon Mumbai',
        'balance': '0.0 MATIC',
        'created': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'address': '0x742d35Cc67dF5C3d6C4fA4D4cD6d8f6a3dE5d2F4',
        'privateKey': 'DEMO_KEY',
        'publicKey': '0x742d35Cc67dF5C3d6C4fA4D4cD6d8f6a3dE5d2F4',
        'network': 'Polygon Mumbai',
      };
    }
  }

  // Get wallet balance (mock)
  static Future<double> getWalletBalance(String walletAddress) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      // Return mock balance
      return 0.0235; // 0.0235 MATIC
    } catch (e) {
      return 0.0;
    }
  }

  // Transfer certificate ownership (mock)
  static Future<bool> transferCertificate(
    String tokenId,
    String fromAddress,
    String toAddress,
    String privateKey
  ) async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      
      // Update mock certificate owner
      if (_mockCertificates.containsKey(tokenId)) {
        _mockCertificates[tokenId]!['walletAddress'] = toAddress;
        _mockCertificates[tokenId]!['transferHistory'] = [
          {
            'from': fromAddress,
            'to': toAddress,
            'timestamp': DateTime.now().toIso8601String(),
            'transactionHash': _generateMockTransactionHash(),
          }
        ];
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get certificate statistics (mock)
  static Future<Map<String, int>> getCertificateStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return {
      'totalCertificates': 1247 + _mockCertificates.length,
      'verifiedArtisans': 892,
      'thisMonth': 156,
      'thisWeek': 42,
      'yourCertificates': _mockCertificates.length,
    };
  }

  // Get blockchain network status (mock)
  static Future<Map<String, dynamic>> getNetworkStatus() async {
    return {
      'network': 'Polygon Mumbai Testnet',
      'status': 'Connected',
      'blockHeight': _generateMockBlockNumber(),
      'gasPrice': '1.2 Gwei',
      'networkHealth': 'Excellent',
      'averageBlockTime': '2.1 seconds',
    };
  }

  // Helper methods for generating mock data
  static String _generateMockIPFSHash(String content) {
    final hash = content.hashCode.abs().toRadixString(16);
    return 'QmZ${hash.padLeft(44, '0').substring(0, 44)}';
  }

  static String _generateMockTransactionHash() {
    final random = Random();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return '0x${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('')}';
  }

  static String _generateMockWalletAddress() {
    final random = Random();
    final bytes = List<int>.generate(20, (i) => random.nextInt(256));
    return '0x${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('')}';
  }

  static String _generateMockPrivateKey() {
    final random = Random();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return '0x${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('')}';
  }

  static int _generateMockBlockNumber() {
    final baseBlock = 35420000;
    final randomAdd = Random().nextInt(10000);
    return baseBlock + randomAdd;
  }

  static Map<String, dynamic> _generateDemoCertificate(String tokenId) {
    return {
      'tokenId': tokenId,
      'contractAddress': contractAddress,
      'network': 'Polygon Mumbai',
      'artisanName': 'प्रिया शर्मा',
      'productName': 'मीनाकारी फूलदान',
      'craftType': 'मीनाकारी',
      'location': 'जयपुर, राजस्थान',
      'createdAt': '2024-01-15T10:30:00Z',
      'verified': true,
      'explorerUrl': 'https://mumbai.polygonscan.com/token/$contractAddress?a=$tokenId',
      'trustScore': 97.2,
    };
  }

  static List<Map<String, dynamic>> _generateDemoCertificateHistory() {
    return [
      {
        'tokenId': '1670000000001',
        'productName': 'मीनाकारी फूलदान',
        'artisanName': 'प्रिया शर्मा',
        'craftType': 'मीनाकारी',
        'createdAt': '2024-01-15T10:30:00Z',
        'verified': true,
        'explorerUrl': 'https://mumbai.polygonscan.com/tx/0xabc123...',
        'status': 'minted',
        'trustScore': 98.5,
      },
      {
        'tokenId': '1670000000002',
        'productName': 'लकड़ी का हस्तशिल्प',
        'artisanName': 'प्रिया शर्मा',
        'craftType': 'लकड़ी का काम',
        'createdAt': '2024-01-10T14:20:00Z',
        'verified': true,
        'explorerUrl': 'https://mumbai.polygonscan.com/tx/0xdef456...',
        'status': 'minted',
        'trustScore': 97.8,
      },
      {
        'tokenId': '1670000000003',
        'productName': 'हस्तनिर्मित टोकरी',
        'artisanName': 'प्रिया शर्मा',
        'craftType': 'बांस शिल्प',
        'createdAt': '2024-01-08T16:45:00Z',
        'verified': true,
        'explorerUrl': 'https://mumbai.polygonscan.com/tx/0xghi789...',
        'status': 'minted',
        'trustScore': 96.9,
      }
    ];
  }

  // Get certificate as shareable link
  static String getCertificateShareLink(String tokenId) {
    return 'https://kalanirbhar.com/verify/$tokenId';
  }

  // Get certificate QR code data
  static Map<String, String> getCertificateQRData(String tokenId) {
    return {
      'url': getCertificateShareLink(tokenId),
      'title': 'KalaNirbhar Certificate #$tokenId',
      'description': 'Scan to verify authenticity on blockchain',
    };
  }
}