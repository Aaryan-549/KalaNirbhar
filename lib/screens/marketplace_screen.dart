import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/app_provider.dart';
import '../providers/ai_assistant_provider.dart';
import '../utils/app_theme.dart';
import '../services/translation_service.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
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
    
    // Fallback translations for all analytics texts
    final fallbackTexts = {
      'hi': {
        'analytics_dashboard': 'विश्लेषण डैशबोर्ड',
        'sales_overview': 'बिक्री अवलोकन',
        'total_revenue': 'कुल आय',
        'total_orders': 'कुल ऑर्डर',
        'average_order': 'औसत ऑर्डर',
        'conversion_rate': 'रूपांतरण दर',
        'top_products': 'शीर्ष उत्पाद',
        'sales_channels': 'बिक्री चैनल',
        'customer_analytics': 'ग्राहक विश्लेषण',
        'market_performance': 'बाजार प्रदर्शन',
        'monthly_growth': 'मासिक वृद्धि',
        'product_views': 'उत्पाद दृश्य',
        'cart_additions': 'कार्ट में जोड़े गए',
        'checkout_rate': 'चेकआउट दर',
        'return_customers': 'वापसी ग्राहक',
        'new_customers': 'नए ग्राहक',
        'customer_satisfaction': 'ग्राहक संतुष्टि',
        'website_traffic': 'वेबसाइट ट्रैफिक',
        'social_media': 'सोशल मीडिया',
        'marketplace_sales': 'मार्केटप्लेस बिक्री',
        'organic_search': 'जैविक खोज',
        'paid_ads': 'भुगतान विज्ञापन',
        'email_marketing': 'ईमेल मार्केटिंग',
        'handmade_pottery': 'हस्तनिर्मित मिट्टी के बर्तन',
        'embroidered_saree': 'कढ़ाई साड़ी',
        'wooden_sculpture': 'लकड़ी की मूर्ति',
        'brass_figurine': 'पीतल की मूर्ति',
        'textile_art': 'कपड़ा कला',
        'click_for_insights': 'जानकारी के लिए क्लिक करें',
        'last_30_days': 'पिछले 30 दिन',
        'vs_previous_month': 'पिछले महीने की तुलना में',
      },
      'en': {
        'analytics_dashboard': 'Analytics Dashboard',
        'sales_overview': 'Sales Overview',
        'total_revenue': 'Total Revenue',
        'total_orders': 'Total Orders',
        'average_order': 'Average Order',
        'conversion_rate': 'Conversion Rate',
        'top_products': 'Top Products',
        'sales_channels': 'Sales Channels',
        'customer_analytics': 'Customer Analytics',
        'market_performance': 'Market Performance',
        'monthly_growth': 'Monthly Growth',
        'product_views': 'Product Views',
        'cart_additions': 'Cart Additions',
        'checkout_rate': 'Checkout Rate',
        'return_customers': 'Return Customers',
        'new_customers': 'New Customers',
        'customer_satisfaction': 'Customer Satisfaction',
        'website_traffic': 'Website Traffic',
        'social_media': 'Social Media',
        'marketplace_sales': 'Marketplace Sales',
        'organic_search': 'Organic Search',
        'paid_ads': 'Paid Ads',
        'email_marketing': 'Email Marketing',
        'handmade_pottery': 'Handmade Pottery',
        'embroidered_saree': 'Embroidered Saree',
        'wooden_sculpture': 'Wooden Sculpture',
        'brass_figurine': 'Brass Figurine',
        'textile_art': 'Textile Art',
        'click_for_insights': 'Click for insights',
        'last_30_days': 'Last 30 days',
        'vs_previous_month': 'vs previous month',
      },
      'pa': {
        'analytics_dashboard': 'ਵਿਸ਼ਲੇਸ਼ਣ ਡੈਸ਼ਬੋਰਡ',
        'sales_overview': 'ਵਿਕਰੀ ਅਵਲੋਕਨ',
        'total_revenue': 'ਕੁੱਲ ਆਮਦਨ',
        'total_orders': 'ਕੁੱਲ ਆਰਡਰ',
        'average_order': 'ਔਸਤ ਆਰਡਰ',
        'conversion_rate': 'ਰੂਪਾਂਤਰਣ ਦਰ',
        'top_products': 'ਸਿਖਰ ਉਤਪਾਦ',
        'sales_channels': 'ਵਿਕਰੀ ਚੈਨਲ',
        'customer_analytics': 'ਗਾਹਕ ਵਿਸ਼ਲੇਸ਼ਣ',
        'market_performance': 'ਮਾਰਕੀਟ ਪ੍ਰਦਰਸ਼ਨ',
        'click_for_insights': 'ਜਾਣਕਾਰੀ ਲਈ ਕਲਿੱਕ ਕਰੋ',
        'last_30_days': 'ਪਿਛਲੇ 30 ਦਿਨ',
        'vs_previous_month': 'ਪਿਛਲੇ ਮਹੀਨੇ ਦੇ ਮੁਕਾਬਲੇ',
      },
      'bn': {
        'analytics_dashboard': 'বিশ্লেষণ ড্যাশবোর্ড',
        'sales_overview': 'বিক্রয় সংক্ষিপ্ত বিবরণ',
        'total_revenue': 'মোট আয়',
        'total_orders': 'মোট অর্ডার',
        'average_order': 'গড় অর্ডার',
        'conversion_rate': 'রূপান্তর হার',
        'top_products': 'শীর্ষ পণ্য',
        'sales_channels': 'বিক্রয় চ্যানেল',
        'customer_analytics': 'গ্রাহক বিশ্লেষণ',
        'market_performance': 'বাজার কর্মক্ষমতা',
        'click_for_insights': 'অন্তর্দৃষ্টির জন্য ক্লিক করুন',
        'last_30_days': 'গত ৩০ দিন',
        'vs_previous_month': 'পূর্ববর্তী মাসের তুলনায়',
      },
    };

    texts.addAll(fallbackTexts[currentLang] ?? fallbackTexts['en']!);

    // Try to get translations from service if available
    try {
      for (final key in fallbackTexts['en']!.keys) {
        if (currentLang != 'en') {
          try {
            final translated = await TranslationService.translateText(
              fallbackTexts['en']![key]!,
              currentLang,
              sourceLanguage: 'en'
            );
            texts[key] = translated;
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
                        _buildSalesOverview(),
                        const SizedBox(height: 30),
                        _buildPerformanceMetrics(),
                        const SizedBox(height: 30),
                        _buildTopProducts(),
                        const SizedBox(height: 30),
                        _buildSalesChannels(),
                        const SizedBox(height: 30),
                        _buildCustomerAnalytics(),
                        const SizedBox(height: 100), // Extra space for floating button
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildChatbotButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                      _getText('analytics_dashboard'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      _getText('last_30_days'),
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
                  Icons.analytics_outlined,
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

  Widget _buildSalesOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getText('sales_overview'),
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
                child: _buildMetricCard(
                  title: _getText('total_revenue'),
                  value: '₹45,230',
                  change: '+18.5%',
                  icon: Icons.currency_rupee,
                  color: Colors.green,
                  metric: 'revenue',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FadeInRight(
                duration: const Duration(milliseconds: 600),
                child: _buildMetricCard(
                  title: _getText('total_orders'),
                  value: '127',
                  change: '+12.3%',
                  icon: Icons.shopping_bag,
                  color: AppTheme.primaryBlue,
                  metric: 'orders',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FadeInLeft(
                duration: const Duration(milliseconds: 700),
                child: _buildMetricCard(
                  title: _getText('average_order'),
                  value: '₹356',
                  change: '+5.2%',
                  icon: Icons.trending_up,
                  color: AppTheme.orange,
                  metric: 'average_order',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FadeInRight(
                duration: const Duration(milliseconds: 700),
                child: _buildMetricCard(
                  title: _getText('conversion_rate'),
                  value: '3.8%',
                  change: '+0.5%',
                  icon: Icons.percent,
                  color: Colors.purple,
                  metric: 'conversion',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getText('market_performance'),
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
              child: _buildMetricCard(
                title: _getText('product_views'),
                value: '2,845',
                change: '+25.3%',
                icon: Icons.visibility,
                color: Colors.indigo,
                metric: 'views',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: _getText('cart_additions'),
                value: '189',
                change: '+8.7%',
                icon: Icons.add_shopping_cart,
                color: Colors.teal,
                metric: 'cart_additions',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopProducts() {
    final products = [
      {'name': _getText('handmade_pottery'), 'sales': '₹8,450', 'units': '23'},
      {'name': _getText('embroidered_saree'), 'sales': '₹12,300', 'units': '18'},
      {'name': _getText('wooden_sculpture'), 'sales': '₹6,890', 'units': '12'},
      {'name': _getText('brass_figurine'), 'sales': '₹4,560', 'units': '31'},
      {'name': _getText('textile_art'), 'sales': '₹7,230', 'units': '15'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getText('top_products'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
            children: products.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              return GestureDetector(
                onTap: () => _showProductInsights(product['name']!, product),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: index < products.length - 1
                        ? const Border(bottom: BorderSide(color: Colors.grey, width: 0.2))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getProductColor(index).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getProductIcon(index),
                          color: _getProductColor(index),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name']!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textDark,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              '${product['units']} units sold',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLight,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            product['sales']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getProductColor(index),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            _getText('click_for_insights'),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textLight,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: AppTheme.textLight,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesChannels() {
    final channels = [
      {'name': _getText('website_traffic'), 'percentage': '45%', 'value': '₹20,350'},
      {'name': _getText('social_media'), 'percentage': '28%', 'value': '₹12,664'},
      {'name': _getText('marketplace_sales'), 'percentage': '18%', 'value': '₹8,141'},
      {'name': _getText('organic_search'), 'percentage': '9%', 'value': '₹4,070'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getText('sales_channels'),
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
          childAspectRatio: 1.2,
          children: channels.asMap().entries.map((entry) {
            final index = entry.key;
            final channel = entry.value;
            return GestureDetector(
              onTap: () => _showChannelInsights(channel['name']!, channel),
              child: Container(
                padding: const EdgeInsets.all(16),
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
                    Icon(
                      _getChannelIcon(index),
                      color: _getChannelColor(index),
                      size: 24,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      channel['percentage']!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _getChannelColor(index),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      channel['name']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textDark,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      channel['value']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textLight,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomerAnalytics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getText('customer_analytics'),
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
              child: _buildMetricCard(
                title: _getText('new_customers'),
                value: '42',
                change: '+15.8%',
                icon: Icons.person_add,
                color: Colors.green,
                metric: 'new_customers',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: _getText('return_customers'),
                value: '85',
                change: '+22.1%',
                icon: Icons.repeat,
                color: Colors.blue,
                metric: 'return_customers',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _showCustomerSatisfactionInsights(),
          child: Container(
            width: double.infinity,
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
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getText('customer_satisfaction'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '4.8/5.0',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '+0.3 ${_getText('vs_previous_month')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '234 reviews',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color color,
    required String metric,
  }) {
    return GestureDetector(
      onTap: () => _showMetricInsights(title, metric, value, change),
      child: Container(
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
      ),
    );
  }

  Widget _buildChatbotButton() {
    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, child) {
        return FloatingActionButton(
          onPressed: () => _openChatbot(),
          backgroundColor: AppTheme.primaryBlue,
          elevation: 8,
          child: Icon(
            aiProvider.isProcessing ? Icons.auto_awesome : Icons.chat,
            color: Colors.white,
            size: 24,
          ),
        );
      },
    );
  }

  void _openChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.analytics, color: AppTheme.primaryBlue),
                      const SizedBox(width: 12),
                      Text(
                        _getText('analytics_dashboard'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: Consumer<AIAssistantProvider>(
                    builder: (context, aiProvider, child) {
                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: aiProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = aiProvider.messages[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: message['isUser'] ?? false
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!(message['isUser'] ?? false)) ...[
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      gradient: AppTheme.buttonGradient,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.analytics,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Flexible(
                                  flex: 7,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: message['isUser'] ?? false
                                          ? AppTheme.buttonGradient
                                          : null,
                                      color: message['isUser'] ?? false
                                          ? null
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      message['text'] ?? '',
                                      style: TextStyle(
                                        color: message['isUser'] ?? false
                                            ? Colors.white
                                            : AppTheme.textDark,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                                if (message['isUser'] ?? false) ...[
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: AppTheme.primaryBlue,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMetricInsights(String title, String metric, String value, String change) {
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    
    String insightMessage = '';
    switch (metric) {
      case 'revenue':
        insightMessage = '${_getText('total_revenue')} $value के बारे में विस्तार से बताएं और इसे कैसे बेहतर बना सकते हैं?';
        break;
      case 'orders':
        insightMessage = '${_getText('total_orders')} $value का विश्लेषण करें और ऑर्डर बढ़ाने के उपाय सुझाएं।';
        break;
      case 'average_order':
        insightMessage = '${_getText('average_order')} $value को कैसे बढ़ाया जा सकता है?';
        break;
      case 'conversion':
        insightMessage = '${_getText('conversion_rate')} $value में सुधार के लिए क्या करना चाहिए?';
        break;
      case 'views':
        insightMessage = '${_getText('product_views')} $value का मतलब क्या है और इसे कैसे बेहतर करें?';
        break;
      case 'cart_additions':
        insightMessage = '${_getText('cart_additions')} $value से checkout तक conversion कैसे बढ़ाएं?';
        break;
      case 'new_customers':
        insightMessage = '${_getText('new_customers')} $value को कैसे और बढ़ाया जा सकता है?';
        break;
      case 'return_customers':
        insightMessage = '${_getText('return_customers')} $value को maintain कैसे करें और बढ़ाएं?';
        break;
      default:
        insightMessage = '$title के बारे में विस्तृत जानकारी दें और सुधार के सुझाव दें।';
    }
    
    aiProvider.sendMessage(insightMessage);
    _openChatbot();
  }

  void _showProductInsights(String productName, Map<String, String> productData) {
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    
    final message = '$productName के लिए विस्तृत विश्लेषण करें। बिक्री ${productData['sales']}, ${productData['units']} units बेचे गए। इस उत्पाद की बिक्री कैसे बढ़ाई जा सकती है?';
    
    aiProvider.sendMessage(message);
    _openChatbot();
  }

  void _showChannelInsights(String channelName, Map<String, String> channelData) {
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    
    final message = '$channelName से ${channelData['percentage']} बिक्री हो रही है (${channelData['value']})। इस चैनल का प्रदर्शन कैसे बेहतर बनाया जा सकता है?';
    
    aiProvider.sendMessage(message);
    _openChatbot();
  }

  void _showCustomerSatisfactionInsights() {
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    
    final message = 'Customer satisfaction 4.8/5.0 है 234 reviews के साथ। इसे 5.0 तक कैसे सुधारा जा सकता है और अधिक reviews कैसे प्राप्त करें?';
    
    aiProvider.sendMessage(message);
    _openChatbot();
  }

  Color _getProductColor(int index) {
    const colors = [
      Colors.orange,
      Colors.pink,
      Colors.brown,
      Colors.amber,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  IconData _getProductIcon(int index) {
    const icons = [
      Icons.local_florist,
      Icons.checkroom,
      Icons.park,
      Icons.emoji_objects,
      Icons.palette,
    ];
    return icons[index % icons.length];
  }

  Color _getChannelColor(int index) {
    const colors = [
      AppTheme.primaryBlue,
      Colors.purple,
      AppTheme.orange,
      Colors.green,
    ];
    return colors[index % colors.length];
  }

  IconData _getChannelIcon(int index) {
    const icons = [
      Icons.language,
      Icons.share,
      Icons.store,
      Icons.search,
    ];
    return icons[index % icons.length];
  }
}