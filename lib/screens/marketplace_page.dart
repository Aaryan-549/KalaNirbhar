import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/ai_assistant_provider.dart';
import '../utils/app_theme.dart';
import '../services/dynamic_localization_service.dart';

class MarketplacePage extends StatefulWidget {
  final String marketplaceName;
  final Color marketplaceColor;
  final String logoAsset;

  const MarketplacePage({
    super.key,
    required this.marketplaceName,
    required this.marketplaceColor,
    required this.logoAsset,
  });

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  Map<String, Map<String, String>> _localizedTexts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalizedTexts();
  }

  Future<void> _loadLocalizedTexts() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentLang = appProvider.selectedLanguage;
    
    final texts = <String, String>{};
    
    // Define text keys for marketplace page
    final textKeys = [
      'marketplace_dashboard', 'add_new_product', 'my_products', 'sales_analytics',
      'ai_photo_enhancement', 'ai_story_generation', 'digital_certificate',
      'marketing_content', 'product_title', 'product_description', 'product_price',
      'product_category', 'enhance_with_ai', 'generate_story', 'create_certificate',
      'upload_photos', 'generate_marketing', 'save_draft', 'publish_product',
      'recent_products', 'total_sales', 'active_listings', 'pending_orders'
    ];
    
    // Fallback translations
    final fallbackTexts = {
      'hi': {
        'marketplace_dashboard': '${widget.marketplaceName} डैशबोर्ड',
        'add_new_product': 'नया उत्पाद जोड़ें',
        'my_products': 'मेरे उत्पाद',
        'sales_analytics': 'बिक्री विश्लेषण',
        'ai_photo_enhancement': 'AI फोटो सुधार',
        'ai_story_generation': 'AI कहानी निर्माण',
        'digital_certificate': 'डिजिटल प्रमाणपत्र',
        'marketing_content': 'मार्केटिंग सामग्री',
        'product_title': 'उत्पाद शीर्षक',
        'product_description': 'उत्पाद विवरण',
        'product_price': 'उत्पाद मूल्य',
        'product_category': 'उत्पाद श्रेणी',
        'enhance_with_ai': 'AI से सुधारें',
        'generate_story': 'कहानी बनाएं',
        'create_certificate': 'प्रमाणपत्र बनाएं',
        'upload_photos': 'फोटो अपलोड करें',
        'generate_marketing': 'मार्केटिंग बनाएं',
        'save_draft': 'ड्राफ्ट सेव करें',
        'publish_product': 'उत्पाद प्रकाशित करें',
        'recent_products': 'हाल के उत्पाद',
        'total_sales': 'कुल बिक्री',
        'active_listings': 'सक्रिय सूची',
        'pending_orders': 'लंबित ऑर्डर',
      },
      'en': {
        'marketplace_dashboard': '${widget.marketplaceName} Dashboard',
        'add_new_product': 'Add New Product',
        'my_products': 'My Products',
        'sales_analytics': 'Sales Analytics',
        'ai_photo_enhancement': 'AI Photo Enhancement',
        'ai_story_generation': 'AI Story Generation',
        'digital_certificate': 'Digital Certificate',
        'marketing_content': 'Marketing Content',
        'product_title': 'Product Title',
        'product_description': 'Product Description',
        'product_price': 'Product Price',
        'product_category': 'Product Category',
        'enhance_with_ai': 'Enhance with AI',
        'generate_story': 'Generate Story',
        'create_certificate': 'Create Certificate',
        'upload_photos': 'Upload Photos',
        'generate_marketing': 'Generate Marketing',
        'save_draft': 'Save Draft',
        'publish_product': 'Publish Product',
        'recent_products': 'Recent Products',
        'total_sales': 'Total Sales',
        'active_listings': 'Active Listings',
        'pending_orders': 'Pending Orders',
      },
    };
    
    texts.addAll(fallbackTexts[currentLang] ?? fallbackTexts['en']!);
    
    // Live translation for all text keys
    try {
      for (final key in textKeys) {
        if (currentLang != 'en') {
          try {
            final englishText = fallbackTexts['en']?[key] ?? key;
            final translatedText = await DynamicLocalizationService.translateText(
              englishText,
              currentLang
            );
            texts[key] = translatedText;
          } catch (e) {
            print('Translation error for $key: $e');
          }
        }
      }
    } catch (e) {
      print('Translation service error: $e');
    }
    
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.marketplaceColor, widget.marketplaceColor.withOpacity(0.7)],
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
      body: SafeArea(
        child: Column(
          children: [
            _buildMarketplaceHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCards(),
                    const SizedBox(height: 24),
                    _buildAIPoweredProductCreation(),
                    const SizedBox(height: 24),
                    _buildRecentProducts(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketplaceHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.marketplaceColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          
          // Marketplace logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              widget.logoAsset,
              fit: BoxFit.contain,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Text(
              _getText('marketplace_dashboard'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        _buildStatCard(_getText('total_sales'), '₹15,430', Icons.trending_up, Colors.green),
        const SizedBox(width: 12),
        _buildStatCard(_getText('active_listings'), '12', Icons.inventory, widget.marketplaceColor),
        const SizedBox(width: 12),
        _buildStatCard(_getText('pending_orders'), '3', Icons.pending_actions, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textLight,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIPoweredProductCreation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getText('add_new_product'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        
        // AI-powered features grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildAIFeatureCard(
              _getText('ai_photo_enhancement'),
              Icons.photo_camera,
              Colors.purple,
              () => _navigateToImageEnhancement(),
            ),
            _buildAIFeatureCard(
              _getText('ai_story_generation'),
              Icons.auto_stories,
              Colors.blue,
              () => _navigateToStoryGeneration(),
            ),
            _buildAIFeatureCard(
              _getText('digital_certificate'),
              Icons.verified,
              Colors.green,
              () => _navigateToDigitalCertificate(),
            ),
            _buildAIFeatureCard(
              _getText('marketing_content'),
              Icons.campaign,
              Colors.orange,
              () => _navigateToMarketingContent(),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Quick product form
        _buildQuickProductForm(),
      ],
    );
  }

  Widget _buildAIFeatureCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickProductForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFormField(_getText('product_title'), 'Enter product name'),
          const SizedBox(height: 16),
          _buildFormField(_getText('product_description'), 'Describe your product'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildFormField(_getText('product_price'), '₹ 0')),
              const SizedBox(width: 16),
              Expanded(child: _buildFormField(_getText('product_category'), 'Category')),
            ],
          ),
          const SizedBox(height: 20),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _saveDraft(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(_getText('save_draft')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _publishProduct(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.marketplaceColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(_getText('publish_product')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textLight),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: widget.marketplaceColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getText('recent_products'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return _buildProductTile(
              'Sample Product ${index + 1}',
              '₹${(index + 1) * 500}',
              'On ${widget.marketplaceName}',
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductTile(String name, String price, String platform) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  platform,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.marketplaceColor,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods for AI features
  void _navigateToImageEnhancement() {
    Navigator.pushNamed(context, '/ai-assistant');
  }

  void _navigateToStoryGeneration() {
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    Navigator.pushNamed(context, '/ai-assistant');
    // Auto-send story generation request
    Future.delayed(Duration(milliseconds: 500), () {
      aiProvider.sendMessage(_getText('generate_story'));
    });
  }

  void _navigateToDigitalCertificate() {
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    Navigator.pushNamed(context, '/ai-assistant');
    Future.delayed(Duration(milliseconds: 500), () {
      aiProvider.sendMessage(_getText('create_certificate'));
    });
  }

  void _navigateToMarketingContent() {
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    Navigator.pushNamed(context, '/ai-assistant');
    Future.delayed(Duration(milliseconds: 500), () {
      aiProvider.sendMessage(_getText('generate_marketing'));
    });
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_getText('save_draft'))),
    );
  }

  void _publishProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_getText('publish_product'))),
    );
  }
}