import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../providers/ai_assistant_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/feature_suggestion_chips.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _waveAnimationController;

  @override
  void initState() {
    super.initState();
    _waveAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Initialize with welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
      aiProvider.addWelcomeMessage();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _waveAnimationController.dispose();
    super.dispose();
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
                  child: Column(
                    children: [
                      Expanded(child: _buildChatArea()),
                      _buildFeatureSuggestions(),
                      _buildInputArea(),
                    ],
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
    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // AI Avatar with animation
              Stack(
                alignment: Alignment.center,
                children: [
                  if (aiProvider.isProcessing)
                    AnimatedBuilder(
                      animation: _waveAnimationController,
                      builder: (context, child) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                0.3 + 0.7 * _waveAnimationController.value,
                              ),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: AppTheme.primaryBlue,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Title and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'सरल बातचीत',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      aiProvider.isProcessing 
                          ? 'सोच रहा हूं...' 
                          : 'आपकी मदद के लिए तैयार',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              
              // Language Selector
              IconButton(
                onPressed: () => _showLanguageSelector(),
                icon: const Icon(
                  Icons.translate,
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

  Widget _buildChatArea() {
    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, child) {
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          itemCount: aiProvider.messages.length,
          itemBuilder: (context, index) {
            final message = aiProvider.messages[index];
            return FadeInUp(
              duration: Duration(milliseconds: 300 + (index * 100)),
              child: ChatBubble(
                message: message['text'],
                isUser: message['isUser'],
                timestamp: message['timestamp'],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFeatureSuggestions() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const FeatureSuggestionChips(),
    );
  }

  Widget _buildInputArea() {
    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Text Input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'अपना सवाल पूछें...',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppTheme.textLight,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                    onSubmitted: (text) => _sendMessage(text),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Voice Input Button
              VoiceInputButton(
                onVoiceInput: (text) => _sendMessage(text),
                isListening: aiProvider.isListening,
              ),
              const SizedBox(width: 8),
              
              // Send Button
              GestureDetector(
                onTap: () => _sendMessage(_messageController.text),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.buttonGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    aiProvider.sendMessage(text.trim());
    _messageController.clear();
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'भाषा चुनें / Choose Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              
              _buildLanguageOption('हिंदी', 'Hindi', 'hi'),
              _buildLanguageOption('English', 'English', 'en'),
              _buildLanguageOption('বাংলা', 'Bengali', 'bn'),
              _buildLanguageOption('मराठी', 'Marathi', 'mr'),
              _buildLanguageOption('தமிழ்', 'Tamil', 'ta'),
              _buildLanguageOption('తెలుగు', 'Telugu', 'te'),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String native, String english, String code) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            code.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        native,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        english,
        style: const TextStyle(
          fontFamily: 'Poppins',
          color: AppTheme.textLight,
        ),
      ),
      onTap: () {
        final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
        aiProvider.changeLanguage(code);
        Navigator.pop(context);
      },
    );
  }
}