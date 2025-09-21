import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/feature_card.dart';
import '../services/dynamic_localization_service.dart';
import '../services/translation_service.dart';
import '../widgets/voice_ai_bubble.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _marketplaceController = PageController();
  Map<String, Map<String, String>> _localizedTexts = {};
  bool _isLoading = true;

  // Marketplace data
  final List<Map<String, dynamic>> _marketplaces = [
    {
      'name': 'Amazon',
      'nameKey': 'amazon_marketplace',
      'color': const Color(0xFF232F3E),
      'logo': 'assets/amazon-logo.png',
      'route': '/amazon-marketplace',
    },
    {
      'name': 'Etsy', 
      'nameKey': 'etsy_marketplace',
      'color': const Color(0xFFD56638),
      'logo': 'assets/etsy.png',
      'route': '/etsy-marketplace',
    },
    {
      'name': 'Flipkart',
      'nameKey': 'flipkart_marketplace', 
      'color': const Color(0xFF2874F0),
      'logo': 'assets/flipkart.png',
      'route': '/flipkart-marketplace',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLocalizedTexts();
  }

  @override
  void dispose() {
    _marketplaceController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalizedTexts() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentLang = appProvider.selectedLanguage;
    
    final texts = <String, String>{};
    
    // Fallback translations
    final fallbackTexts = {
      'hi': {
        'our_marketplace': 'हमारा मार्केटप्लेस',
        'select_to_enter': 'प्रवेश के लिए चुनें',
        'products': 'उत्पाद',
        'analytics': 'एनालिटिक्स',
        'add_product': 'उत्पाद जोड़ें',
        'recent_products': 'हाल के उत्पाद',
        'certificate': 'प्रमाणपत्र',
        'welcome_back': 'वापस स्वागत है',
        'amazon_marketplace': 'अमेज़न मार्केटप्लेस',
        'etsy_marketplace': 'एत्सी मार्केटप्लेस',
        'flipkart_marketplace': 'फ्लिपकार्ट मार्केटप्लेस',
      },
      'en': {
        'our_marketplace': 'Our Marketplace',
        'select_to_enter': 'Select to enter',
        'products': 'Products',
        'analytics': 'Analytics',
        'add_product': 'Add Product',
        'recent_products': 'Recent Products',
        'certificate': 'Certificate',
        'welcome_back': 'Welcome Back',
        'amazon_marketplace': 'Amazon Marketplace',
        'etsy_marketplace': 'Etsy Marketplace',
        'flipkart_marketplace': 'Flipkart Marketplace',
      },
    };
    
    texts.addAll(fallbackTexts[currentLang] ?? fallbackTexts['en']!);
    
    if (mounted) {
      setState(() {
        _localizedTexts[currentLang] = texts;
        _isLoading = false;
      });
    }
  }

  String _getText(String key) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentLang = appProvider.selectedLanguage;
    return _localizedTexts[currentLang]?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMarketplaceSection(),
                        const SizedBox(height: 30),
                        _buildQuickActions(),
                        const SizedBox(height: 30),
                        _buildRecentProducts(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Voice AI Assistant Bubble
          const VoiceAIBubble(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getText('welcome_back'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      appProvider.userName.isNotEmpty 
                          ? appProvider.userName 
                          : 'Artisan',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMarketplaceSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            _getText('our_marketplace'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: ListView.builder(
            controller: _marketplaceController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _marketplaces.length,
            itemBuilder: (context, index) {
              final marketplace = _marketplaces[index];
              return FadeInUp(
                duration: Duration(milliseconds: 600 + (index * 100)),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, marketplace['route'] as String);
                  },
                  child: Container(
                    width: 280,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 8,
                      right: index == _marketplaces.length - 1 ? 0 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: marketplace['color'] as Color,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x33000000),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            marketplace['logo'] as String,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  (marketplace['name'] as String).substring(0, 1),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: marketplace['color'] as Color,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getText(marketplace['nameKey'] as String),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getText('select_to_enter'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swipe_left,
              color: Colors.grey[400],
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Swipe to explore',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.swipe_right,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: FadeInLeft(
            duration: const Duration(milliseconds: 800),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/products');
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x1A000000),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.inventory,
                      color: AppTheme.primaryBlue,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getText('products'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FadeInRight(
            duration: const Duration(milliseconds: 800),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/analytics');
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x1A000000),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.analytics,
                      color: AppTheme.orange,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getText('analytics'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInUp(
          duration: const Duration(milliseconds: 900),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add-product');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
                elevation: 0,
              ),
              child: Text(
                _getText('add_product'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _getText('recent_products'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        FadeInUp(
          duration: const Duration(milliseconds: 1000),
          child: _buildProductCard(
            'Handwoven Scarf',
            '₹1,299',
            'Beautiful traditional scarf',
            Icons.favorite,
          ),
        ),
        FadeInUp(
          duration: const Duration(milliseconds: 1100),
          child: _buildProductCard(
            'Wooden Vase',
            '₹899',
            'Handcrafted wooden decoration',
            Icons.favorite_border,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(String name, String price, String description, IconData favoriteIcon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14000000),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.image,
              color: Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(
                favoriteIcon,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getText('certificate'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}