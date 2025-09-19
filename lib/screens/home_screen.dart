import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/app_theme.dart';
import '../widgets/feature_card.dart';
import '../services/dynamic_localization_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, String> _localizedTexts = {};

  @override
  void initState() {
    super.initState();
    _loadLocalizedTexts();
  }

  Future<void> _loadLocalizedTexts() async {
    final texts = <String, String>{};
    
    // Preload all texts used in this screen
    final keys = [
      'welcome_message', 'business_question', 'daily_summary', 'today_sales',
      'new_orders', 'main_services', 'recent_activity', 'image_enhancement',
      'improve_photos', 'storyteller', 'write_descriptions', 'security_shield',
      'digital_certificates', 'marketing_assistant', 'marketing_help'
    ];
    
    for (final key in keys) {
      texts[key] = await DynamicLocalizationService.getText(key);
    }
    
    if (mounted) {
      setState(() {
        _localizedTexts = texts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localizedTexts['welcome_message'] ?? 'Hello, Priya ji',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  _localizedTexts['business_question'] ?? 'How is your business doing today?',
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
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _localizedTexts['daily_summary'] ?? 'Today\'s Summary',
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
                  title: _localizedTexts['today_sales'] ?? 'Today\'s Sales',
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
                  title: _localizedTexts['new_orders'] ?? 'New Orders',
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
          _localizedTexts['main_services'] ?? 'Main Services',
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
                title: _localizedTexts['image_enhancement'] ?? 'Image Enhancement',
                subtitle: _localizedTexts['improve_photos'] ?? 'Make photos better',
                icon: Icons.photo_camera,
                color: Colors.purple,
              ),
            ),
            FadeInUp(
              duration: const Duration(milliseconds: 900),
              child: FeatureCard(
                title: _localizedTexts['storyteller'] ?? 'Storyteller',
                subtitle: _localizedTexts['write_descriptions'] ?? 'Write product descriptions',
                icon: Icons.auto_stories,
                color: Colors.orange,
              ),
            ),
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: FeatureCard(
                title: _localizedTexts['security_shield'] ?? 'Security Shield',
                subtitle: _localizedTexts['digital_certificates'] ?? 'Digital Certificates',
                icon: Icons.security,
                color: Colors.teal,
              ),
            ),
            FadeInUp(
              duration: const Duration(milliseconds: 1100),
              child: FeatureCard(
                title: _localizedTexts['marketing_assistant'] ?? 'Marketing Assistant',
                subtitle: _localizedTexts['marketing_help'] ?? 'Marketing Help',
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
          _localizedTexts['recent_activity'] ?? 'Recent Activity',
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
            DynamicLocalizationService.getTextSync('certificate_received'),
            '2 ${DynamicLocalizationService.getTextSync('hours_ago')}',
            Icons.verified,
            Colors.green,
          ),
        ),
        FadeInUp(
          duration: const Duration(milliseconds: 1300),
          child: _buildActivityItem(
            DynamicLocalizationService.getTextSync('new_order_amazon'),
            '5 ${DynamicLocalizationService.getTextSync('hours_ago')}',
            Icons.shopping_cart,
            AppTheme.orange,
          ),
        ),
        FadeInUp(
          duration: const Duration(milliseconds: 1400),
          child: _buildActivityItem(
            DynamicLocalizationService.getTextSync('collaboration_proposal'),
            '1 ${DynamicLocalizationService.getTextSync('day_ago')}',
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