import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:math';
import '../providers/app_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_theme.dart';
import '../services/dynamic_localization_service.dart';
import '../services/gemini_service.dart';
import '../services/imagen_service.dart';
import '../services/vision_service.dart';
import '../services/image_picker_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _storyController = TextEditingController();
  final _materialController = TextEditingController();
  final _sizeController = TextEditingController();
  final _colorController = TextEditingController();
  
  // State variables
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isGeneratingDescription = false;
  bool _isEnhancingImage = false;
  bool _isPosted = false;
  
  // Product data
  String _selectedCategory = 'handicraft';
  Set<String> _selectedPlatforms = {};
  List<Uint8List> _productImages = [];
  List<Uint8List> _enhancedImages = [];
  Map<String, String> _generatedContent = {};
  
  // Localized texts cache
  Map<String, String> _localizedTexts = {};
  
  // Platform configurations
  final List<Map<String, dynamic>> _platforms = [
    {
      'id': 'amazon',
      'name': 'Amazon',
      'nameKey': 'amazon_marketplace',
      'color': const Color(0xFF232F3E),
      'icon': Icons.shopping_cart,
      'commission': 15.0,
    },
    {
      'id': 'etsy',
      'name': 'Etsy',
      'nameKey': 'etsy_marketplace', 
      'color': const Color(0xFFD56638),
      'icon': Icons.handyman,
      'commission': 6.5,
    },
    {
      'id': 'flipkart',
      'name': 'Flipkart',
      'nameKey': 'flipkart_marketplace',
      'color': const Color(0xFF2874F0),
      'icon': Icons.local_mall,
      'commission': 10.0,
    },
    {
      'id': 'instagram',
      'name': 'Instagram',
      'nameKey': 'instagram_social',
      'color': const Color(0xFFE4405F),
      'icon': Icons.camera_alt,
      'commission': 0.0,
    },
  ];
  
  final List<Map<String, String>> _categories = [
    {'id': 'handicraft', 'nameKey': 'handicraft_category'},
    {'id': 'textile', 'nameKey': 'textile_category'},
    {'id': 'jewelry', 'nameKey': 'jewelry_category'},
    {'id': 'painting', 'nameKey': 'painting_category'},
    {'id': 'sculpture', 'nameKey': 'sculpture_category'},
    {'id': 'home-decor', 'nameKey': 'home_decor_category'},
  ];

  @override
  void initState() {
    super.initState();
    _loadLocalizedTexts();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _storyController.dispose();
    _materialController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalizedTexts() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentLang = appProvider.selectedLanguage;
    
    // Extended localization texts for the Add Product screen
    final fallbackTexts = {
      'hi': {
        'add_product': 'उत्पाद जोड़ें',
        'product_details': 'उत्पाद विवरण',
        'platform_selection': 'प्लेटफॉर्म चुनें',
        'image_enhancement': 'फोटो बेहतर बनाएं',
        'final_review': 'अंतिम समीक्षा',
        'product_title': 'उत्पाद का नाम',
        'enter_title': 'उत्पाद का नाम दर्ज करें',
        'price': 'कीमत',
        'enter_price': 'कीमत दर्ज करें (₹)',
        'category': 'श्रेणी',
        'select_category': 'श्रेणी चुनें',
        'description': 'विवरण',
        'story': 'कहानी',
        'material': 'सामग्री',
        'size': 'आकार',
        'color': 'रंग',
        'generate_description': 'AI से विवरण बनाएं',
        'generating': 'तैयार कर रहे हैं...',
        'select_platforms': 'प्लेटफॉर्म चुनें जहां आप बेचना चाहते हैं',
        'commission': 'कमीशन',
        'add_images': 'फोटो जोड़ें',
        'camera': 'कैमरा',
        'gallery': 'गैलरी',
        'enhance_images': 'फोटो बेहतर बनाएं',
        'enhancing': 'बेहतर बना रहे हैं...',
        'preview': 'पूर्वावलोकन',
        'put_online': 'ऑनलाइन डालें',
        'posting': 'पोस्ट कर रहे हैं...',
        'product_posted': 'उत्पाद सफलतापूर्वक पोस्ट हो गया!',
        'live_on': 'अब लाइव है',
        'next': 'आगे',
        'back': 'पीछे',
        'skip': 'छोड़ें',
        'done': 'पूर्ण',
        'handicraft_category': 'हस्तशिल्प',
        'textile_category': 'वस्त्र',
        'jewelry_category': 'आभूषण',
        'painting_category': 'पेंटिंग',
        'sculpture_category': 'मूर्तिकला',
        'home_decor_category': 'घर की सजावट',
        'amazon_marketplace': 'अमेज़न मार्केटप्लेस',
        'etsy_marketplace': 'एत्सी मार्केटप्लेस',
        'flipkart_marketplace': 'फ्लिपकार्ट मार्केटप्लेस',
        'instagram_social': 'इंस्टाग्राम सोशल',
        'enter_description': 'उत्पाद का विवरण दर्ज करें',
        'enter_story': 'उत्पाद की कहानी दर्ज करें',
        'enter_material': 'सामग्री दर्ज करें',
        'enter_size': 'आकार दर्ज करें',
        'enter_color': 'रंग दर्ज करें',
        'ai_generating': 'AI विवरण तैयार कर रहा है...',
        'view_product': 'उत्पाद देखें',
        'success': 'सफलता',
      },
      'en': {
        'add_product': 'Add Product',
        'product_details': 'Product Details',
        'platform_selection': 'Platform Selection',
        'image_enhancement': 'Image Enhancement',
        'final_review': 'Final Review',
        'product_title': 'Product Title',
        'enter_title': 'Enter product title',
        'price': 'Price',
        'enter_price': 'Enter price (₹)',
        'category': 'Category',
        'select_category': 'Select category',
        'description': 'Description',
        'story': 'Story',
        'material': 'Material',
        'size': 'Size',
        'color': 'Color',
        'generate_description': 'Generate with AI',
        'generating': 'Generating...',
        'select_platforms': 'Select platforms where you want to sell',
        'commission': 'Commission',
        'add_images': 'Add Images',
        'camera': 'Camera',
        'gallery': 'Gallery',
        'enhance_images': 'Enhance Images',
        'enhancing': 'Enhancing...',
        'preview': 'Preview',
        'put_online': 'Put Online',
        'posting': 'Posting...',
        'product_posted': 'Product posted successfully!',
        'live_on': 'Now live on',
        'next': 'Next',
        'back': 'Back',
        'skip': 'Skip',
        'done': 'Done',
        'handicraft_category': 'Handicraft',
        'textile_category': 'Textile',
        'jewelry_category': 'Jewelry',
        'painting_category': 'Painting',
        'sculpture_category': 'Sculpture',
        'home_decor_category': 'Home Decor',
        'amazon_marketplace': 'Amazon Marketplace',
        'etsy_marketplace': 'Etsy Marketplace',
        'flipkart_marketplace': 'Flipkart Marketplace',
        'instagram_social': 'Instagram Social',
        'enter_description': 'Enter product description',
        'enter_story': 'Enter product story',
        'enter_material': 'Enter material',
        'enter_size': 'Enter size',
        'enter_color': 'Enter color',
        'ai_generating': 'AI is generating description...',
        'view_product': 'View Product',
        'success': 'Success',
      },
    };
    
    final texts = fallbackTexts[currentLang] ?? fallbackTexts['en']!;
    
    setState(() {
      _localizedTexts = texts;
    });
  }

  String _getText(String key) {
    return _localizedTexts[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        title: Text(
          _getText('add_product'),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildProductDetailsStep(),
                _buildPlatformSelectionStep(),
                _buildImageEnhancementStep(),
                _buildFinalReviewStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          for (int i = 0; i < 4; i++)
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: i <= _currentStep ? AppTheme.primaryBlue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Text(
                _getText('product_details'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Product Title
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: _buildTextField(
                controller: _titleController,
                label: _getText('product_title'),
                hint: _getText('enter_title'),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 16),
            
            // Price and Category Row
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: _getText('price'),
                      hint: _getText('enter_price'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCategoryDropdown(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // AI-Generated Content Section
            FadeInUp(
              duration: const Duration(milliseconds: 900),
              child: _buildAIContentSection(),
            ),
            const SizedBox(height: 16),
            
            // Manual fields for additional details
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _materialController,
                      label: _getText('material'),
                      hint: _getText('enter_material'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _sizeController,
                      label: _getText('size'),
                      hint: _getText('enter_size'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            FadeInUp(
              duration: const Duration(milliseconds: 1100),
              child: _buildTextField(
                controller: _colorController,
                label: _getText('color'),
                hint: _getText('enter_color'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Text(
              _getText('platform_selection'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getText('select_platforms'),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 24),
          
          // Platform Cards
          for (int i = 0; i < _platforms.length; i++)
            FadeInUp(
              duration: Duration(milliseconds: 700 + (i * 100)),
              child: _buildPlatformCard(_platforms[i]),
            ),
        ],
      ),
    );
  }

  Widget _buildImageEnhancementStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Text(
              _getText('image_enhancement'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Add Images Section
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            child: _buildImagePickerSection(),
          ),
          const SizedBox(height: 24),
          
          // Image Enhancement Section
          if (_productImages.isNotEmpty)
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: _buildImageEnhancementSection(),
            ),
          
          // Display Enhanced Images
          if (_enhancedImages.isNotEmpty)
            FadeInUp(
              duration: const Duration(milliseconds: 900),
              child: _buildEnhancedImagesDisplay(),
            ),
        ],
      ),
    );
  }

  Widget _buildFinalReviewStep() {
    if (_isPosted) {
      return _buildSuccessView();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Text(
              _getText('final_review'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Product Preview Card
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            child: _buildProductPreview(),
          ),
          const SizedBox(height: 24),
          
          // Platform Summary
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            child: _buildPlatformSummary(),
          ),
          const SizedBox(height: 32),
          
          // Post Button
          FadeInUp(
            duration: const Duration(milliseconds: 900),
            child: _buildPostButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontFamily: 'Poppins',
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryBlue),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getText('category'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category['id'],
                child: Text(
                  _getText(category['nameKey']!),
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAIContentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getText('generate_description'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              if (!_isGeneratingDescription)
                ElevatedButton(
                  onPressed: _generateAIContent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _getText('generate_description'),
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
            ],
          ),
          if (_isGeneratingDescription) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getText('ai_generating'),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
          if (_generatedContent.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: _getText('description'),
              hint: _getText('enter_description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _storyController,
              label: _getText('story'),
              hint: _getText('enter_story'),
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlatformCard(Map<String, dynamic> platform) {
    final isSelected = _selectedPlatforms.contains(platform['id']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? platform['color'] : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: platform['color'],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            platform['icon'],
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          _getText(platform['nameKey']),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        subtitle: Text(
          '${_getText('commission')}: ${platform['commission']}%',
          style: TextStyle(
            color: Colors.grey[600],
            fontFamily: 'Poppins',
          ),
        ),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedPlatforms.add(platform['id']);
              } else {
                _selectedPlatforms.remove(platform['id']);
              }
            });
          },
          activeColor: platform['color'],
        ),
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedPlatforms.remove(platform['id']);
            } else {
              _selectedPlatforms.add(platform['id']);
            }
          });
        },
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getText('add_images'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickImageFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(
                    _getText('camera'),
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: Text(
                    _getText('gallery'),
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.all(16),
                    side: const BorderSide(color: AppTheme.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_productImages.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _productImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(right: index < _productImages.length - 1 ? 12 : 0),
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _productImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageEnhancementSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_fix_high,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getText('enhance_images'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              if (!_isEnhancingImage)
                ElevatedButton(
                  onPressed: _enhanceImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _getText('enhance_images'),
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
            ],
          ),
          if (_isEnhancingImage) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getText('enhancing'),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedImagesDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Enhanced Images',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _enhancedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: index < _enhancedImages.length - 1 ? 12 : 0),
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _enhancedImages[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPreview() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getText('preview'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          
          // Product Image
          if (_enhancedImages.isNotEmpty || _productImages.isNotEmpty)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _enhancedImages.isNotEmpty ? _enhancedImages[0] : _productImages[0],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 16),
          
          // Product Details
          Text(
            _titleController.text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${_priceController.text}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          if (_descriptionController.text.isNotEmpty)
            Text(
              _descriptionController.text,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildPlatformSummary() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Platforms',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: _selectedPlatforms.map((platformId) {
              final platform = _platforms.firstWhere((p) => p['id'] == platformId);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: platform['color'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getText(platform['nameKey']),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _postProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getText('posting'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              )
            : Text(
                _getText('put_online'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Text(
                _getText('success'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Text(
                _getText('product_posted'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Live Platform Indicators
            FadeInUp(
              duration: const Duration(milliseconds: 900),
              child: Column(
                children: [
                  Text(
                    _getText('live_on'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: _selectedPlatforms.map((platformId) {
                      final platform = _platforms.firstWhere((p) => p['id'] == platformId);
                      return _buildLivePlatformCard(platform);
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Action Buttons
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.all(16),
                        side: const BorderSide(color: AppTheme.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _getText('done'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/products');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _getText('view_product'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePlatformCard(Map<String, dynamic> platform) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: platform['color'], width: 2),
        boxShadow: [
          BoxShadow(
            color: platform['color'].withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: platform['color'],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              platform['icon'],
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getText(platform['nameKey']),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _goToPreviousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: AppTheme.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _getText('back'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _currentStep < 3 && !_isPosted ? _goToNextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep < 3 ? _getText('next') : _getText('done'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Action Methods
  void _goToNextStep() {
    if (_currentStep < 3) {
      if (_currentStep == 0 && !_formKey.currentState!.validate()) {
        return;
      }
      if (_currentStep == 1 && _selectedPlatforms.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one platform')),
        );
        return;
      }
      
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _generateAIContent() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a product title first')),
      );
      return;
    }

    setState(() {
      _isGeneratingDescription = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final productInfo = {
        'name': _titleController.text,
        'category': _selectedCategory,
        'material': _materialController.text,
        'color': _colorController.text,
        'size': _sizeController.text,
      };

      final generatedContent = await GeminiService.generateProductDescription(
        productInfo,
        appProvider.selectedLanguage,
      );

      // Parse the generated content (assuming it comes in structured format)
      final lines = generatedContent.split('\n');
      String description = '';
      String story = '';
      bool isDescription = false;
      bool isStory = false;

      for (final line in lines) {
        if (line.toUpperCase().contains('DESCRIPTION:')) {
          isDescription = true;
          isStory = false;
          description = line.substring(line.indexOf(':') + 1).trim();
        } else if (line.toUpperCase().contains('STORY:')) {
          isStory = true;
          isDescription = false;
          story = line.substring(line.indexOf(':') + 1).trim();
        } else if (isDescription) {
          description += ' $line';
        } else if (isStory) {
          story += ' $line';
        }
      }

      setState(() {
        _generatedContent = {
          'description': description.trim(),
          'story': story.trim(),
        };
        _descriptionController.text = description.trim();
        _storyController.text = story.trim();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate content: $e')),
      );
    } finally {
      setState(() {
        _isGeneratingDescription = false;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final imageBytes = await ImagePickerService.pickImageFromCamera();
    if (imageBytes != null) {
      setState(() {
        _productImages.add(imageBytes);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final imageBytes = await ImagePickerService.pickImageFromGallery();
    if (imageBytes != null) {
      setState(() {
        _productImages.add(imageBytes);
      });
    }
  }

  Future<void> _enhanceImages() async {
    if (_productImages.isEmpty) return;

    setState(() {
      _isEnhancingImage = true;
    });

    try {
      final enhancedImages = <Uint8List>[];
      
      for (final image in _productImages) {
        // Simulate image enhancement (in production, use ImagenService)
        await Future.delayed(const Duration(seconds: 2));
        
        // For demo purposes, just add the original image as "enhanced"
        enhancedImages.add(image);
      }

      setState(() {
        _enhancedImages = enhancedImages;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to enhance images: $e')),
      );
    } finally {
      setState(() {
        _isEnhancingImage = false;
      });
    }
  }

  Future<void> _postProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate posting to platforms
      await Future.delayed(const Duration(seconds: 3));

      // Create product data
      final productData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text,
        'description': _descriptionController.text,
        'story': _storyController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'category': _selectedCategory,
        'material': _materialController.text,
        'size': _sizeController.text,
        'color': _colorController.text,
        'platforms': _selectedPlatforms.toList(),
        'images': _enhancedImages.isNotEmpty ? _enhancedImages : _productImages,
        'hasCertificate': true,
        'views': 0,
        'sales': 0,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Add to product provider
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.addProduct(productData);

      setState(() {
        _isPosted = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post product: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}