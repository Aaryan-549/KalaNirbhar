import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/feature_card.dart';
import '../services/dynamic_localization_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, Map<String, String>> _localizedTexts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalizedTexts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appProvider = Provider.of<AppProvider>(context);
    if (_localizedTexts[appProvider.selectedLanguage] == null) {
      _loadLocalizedTexts();
    }
  }

  Future<void> _loadLocalizedTexts() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentLang = appProvider.selectedLanguage;
    
    if (_localizedTexts[currentLang] != null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final texts = <String, String>{};
    
    // Define all text keys used in this screen
    final textKeys = [
      'business_question', 'daily_summary', 'today_sales',
      'new_orders', 'main_services', 'recent_activity', 
      'image_enhancement', 'improve_photos', 'storyteller', 
      'write_descriptions', 'security_shield', 'digital_certificates', 
      'marketing_assistant', 'marketing_help', 'certificate_received',
      'hours_ago', 'new_order_amazon', 'collaboration_proposal', 'day_ago'
    ];
    
    // Fallback translations for all supported languages
    final fallbackTexts = {
      'hi': {
        'business_question': 'आज आपका व्यापार कैसा चल रहा है?',
        'daily_summary': 'आज का सारांश',
        'today_sales': 'आज की बिक्री',
        'new_orders': 'नए ऑर्डर',
        'main_services': 'मुख्य सेवाएं',
        'recent_activity': 'हाल की गतिविधि',
        'image_enhancement': 'फोटो सुधार',
        'improve_photos': 'फोटो बेहतर बनाएं',
        'storyteller': 'कहानीकार',
        'write_descriptions': 'उत्पाद विवरण लिखें',
        'security_shield': 'सुरक्षा ढाल',
        'digital_certificates': 'डिजिटल प्रमाणपत्र',
        'marketing_assistant': 'मार्केटिंग सहायक',
        'marketing_help': 'मार्केटिंग सहायता',
        'certificate_received': 'प्रमाणपत्र प्राप्त हुआ',
        'hours_ago': 'घंटे पहले',
        'new_order_amazon': 'Amazon से नया ऑर्डर',
        'collaboration_proposal': 'सहयोग प्रस्ताव',
        'day_ago': 'दिन पहले',
      },
      'en': {
        'business_question': 'How is your business doing today?',
        'daily_summary': 'Today\'s Summary',
        'today_sales': 'Today\'s Sales',
        'new_orders': 'New Orders',
        'main_services': 'Main Services',
        'recent_activity': 'Recent Activity',
        'image_enhancement': 'Image Enhancement',
        'improve_photos': 'Make photos better',
        'storyteller': 'Storyteller',
        'write_descriptions': 'Write product descriptions',
        'security_shield': 'Security Shield',
        'digital_certificates': 'Digital Certificates',
        'marketing_assistant': 'Marketing Assistant',
        'marketing_help': 'Marketing Help',
        'certificate_received': 'Certificate received',
        'hours_ago': 'hours ago',
        'new_order_amazon': 'New order from Amazon',
        'collaboration_proposal': 'Collaboration proposal',
        'day_ago': 'day ago',
      },
      'pa': {
        'business_question': 'ਅੱਜ ਤੁਹਾਡਾ ਕਾਰੋਬਾਰ ਕਿਵੇਂ ਚੱਲ ਰਿਹਾ ਹੈ?',
        'daily_summary': 'ਅੱਜ ਦਾ ਸਾਰਾਂਸ਼',
        'today_sales': 'ਅੱਜ ਦੀ ਵਿਕਰੀ',
        'new_orders': 'ਨਵੇ ਆਰਡਰ',
        'main_services': 'ਮੁੱਖ ਸੇਵਾਵਾਂ',
        'recent_activity': 'ਤਾਜ਼ਾ ਗਤਿਵਿਧੀ',
        'image_enhancement': 'ਫੋਟੋ ਸੁਧਾਰ',
        'improve_photos': 'ਫੋਟੋ ਬਿਹਤਰ ਬਣਾਓ',
        'storyteller': 'ਕਹਾਣੀਕਾਰ',
        'write_descriptions': 'ਉਤਪਾਦ ਵਿਵਰਣ ਲਿਖੋ',
        'security_shield': 'ਸੁਰੱਖਿਆ ਢਾਲ',
        'digital_certificates': 'ਡਿਜੀਟਲ ਪ੍ਰਮਾਣ ਪੱਤਰ',
        'marketing_assistant': 'ਮਾਰਕੀਟਿੰਗ ਸਹਾਇਕ',
        'marketing_help': 'ਮਾਰਕੀਟਿੰਗ ਸਹਾਇਤਾ',
        'certificate_received': 'ਪ੍ਰਮਾਣ ਪੱਤਰ ਮਿਲਿਆ',
        'hours_ago': 'ਘੰਟੇ ਪਹਿਲਾਂ',
        'new_order_amazon': 'Amazon ਤੋਂ ਨਵਾਂ ਆਰਡਰ',
        'collaboration_proposal': 'ਸਹਿਯੋਗ ਪ੍ਰਸਤਾਵ',
        'day_ago': 'ਦਿਨ ਪਹਿਲਾਂ',
      },
      'bn': {
        'business_question': 'আজ আপনার ব্যবসা কেমন চলছে?',
        'daily_summary': 'আজকের সারসংক্ষেপ',
        'today_sales': 'আজকের বিক্রয়',
        'new_orders': 'নতুন অর্ডার',
        'main_services': 'প্রধান সেবা',
        'recent_activity': 'সাম্প্রতিক কার্যকলাপ',
        'image_enhancement': 'ছবি উন্নতি',
        'improve_photos': 'ছবি ভালো করুন',
        'storyteller': 'গল্পকার',
        'write_descriptions': 'পণ্য বিবরণ লিখুন',
        'security_shield': 'নিরাপত্তা ঢাল',
        'digital_certificates': 'ডিজিটাল সার্টিফিকেট',
        'marketing_assistant': 'মার্কেটিং সহায়ক',
        'marketing_help': 'মার্কেটিং সাহায্য',
        'certificate_received': 'সার্টিফিকেট পেয়েছেন',
        'hours_ago': 'ঘন্টা আগে',
        'new_order_amazon': 'Amazon থেকে নতুন অর্ডার',
        'collaboration_proposal': 'সহযোগিতার প্রস্তাব',
        'day_ago': 'দিন আগে',
      },
      'mr': {
        'business_question': 'आज तुमचा व्यवसाय कसा चालला आहे?',
        'daily_summary': 'आजचा सारांश',
        'today_sales': 'आजची विक्री',
        'new_orders': 'नवीन ऑर्डर',
        'main_services': 'मुख्य सेवा',
        'recent_activity': 'अलीकडील क्रियाकलाप',
        'image_enhancement': 'प्रतिमा सुधारणा',
        'improve_photos': 'फोटो सुधारा',
        'storyteller': 'कथाकार',
        'write_descriptions': 'उत्पादन वर्णन लिहा',
        'security_shield': 'सुरक्षा ढाल',
        'digital_certificates': 'डिजिटल प्रमाणपत्र',
        'marketing_assistant': 'मार्केटिंग सहाय्यक',
        'marketing_help': 'मार्केटिंग मदत',
        'certificate_received': 'प्रमाणपत्र मिळाले',
        'hours_ago': 'तासांपूर्वी',
        'new_order_amazon': 'Amazon कडून नवीन ऑर्डर',
        'collaboration_proposal': 'सहकार्य प्रस्ताव',
        'day_ago': 'दिवसापूर्वी',
      },
    };
    
    // Use fallback translations first, then try to get from service
    texts.addAll(fallbackTexts[currentLang] ?? fallbackTexts['en']!);
    
    try {
      // Try to get translations from service (if available)
      for (final key in textKeys) {
        try {
          final translatedText = await DynamicLocalizationService.getText(key);
          if (translatedText.isNotEmpty && translatedText != key) {
            texts[key] = translatedText;
          }
        } catch (e) {
          // Keep fallback translation
          print('Translation service error for $key: $e');
        }
      }
    } catch (e) {
      print('Localization service error: $e');
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildQuickStats(),
                        const SizedBox(height: 30),
                        _buildFeaturesSection(),
                        const SizedBox(height: 30),
                        _buildRecentActivity(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appProvider.getGreeting(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      _getText('business_question'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getText('daily_summary'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FadeInLeft(
                duration: const Duration(milliseconds: 600),
                child: _buildQuickStatsCard(
                  title: _getText('today_sales'),
                  value: '₹2,430',
                  icon: Icons.trending_up,
                  color: Colors.green,
                  change: '+12%',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FadeInRight(
                duration: const Duration(milliseconds: 600),
                child: _buildQuickStatsCard(
                  title: _getText('new_orders'),
                  value: '5',
                  icon: Icons.shopping_bag,
                  color: AppTheme.primaryBlue,
                  change: '+2',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String change,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textLight,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getText('main_services'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: FeatureCard(
                title: _getText('image_enhancement'),
                subtitle: _getText('improve_photos'),
                icon: Icons.photo_camera,
                color: Colors.purple,
              ),
            ),
            FadeInUp(
              duration: const Duration(milliseconds: 900),
              child: FeatureCard(
                title: _getText('storyteller'),
                subtitle: _getText('write_descriptions'),
                icon: Icons.auto_stories,
                color: Colors.orange,
              ),
            ),
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: FeatureCard(
                title: _getText('security_shield'),
                subtitle: _getText('digital_certificates'),
                icon: Icons.security,
                color: Colors.teal,
              ),
            ),
            FadeInUp(
              duration: const Duration(milliseconds: 1100),
              child: FeatureCard(
                title: _getText('marketing_assistant'),
                subtitle: _getText('marketing_help'),
                icon: Icons.campaign,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getText('recent_activity'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        FadeInUp(
          duration: const Duration(milliseconds: 1200),
          child: _buildActivityItem(
            _getText('certificate_received'),
            '2 ${_getText('hours_ago')}',
            Icons.verified,
            Colors.green,
          ),
        ),
        FadeInUp(
          duration: const Duration(milliseconds: 1300),
          child: _buildActivityItem(
            _getText('new_order_amazon'),
            '5 ${_getText('hours_ago')}',
            Icons.shopping_cart,
            AppTheme.orange,
          ),
        ),
        FadeInUp(
          duration: const Duration(milliseconds: 1400),
          child: _buildActivityItem(
            _getText('collaboration_proposal'),
            '1 ${_getText('day_ago')}',
            Icons.handshake,
            AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textDark,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppTheme.textLight,
            size: 20,
          ),
        ],
      ),
    );
  }
}