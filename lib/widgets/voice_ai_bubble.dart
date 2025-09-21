import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_assistant_provider.dart';
import '../utils/app_theme.dart';

class VoiceAIBubble extends StatefulWidget {
  const VoiceAIBubble({super.key});

  @override
  State<VoiceAIBubble> createState() => _VoiceAIBubbleState();
}

class _VoiceAIBubbleState extends State<VoiceAIBubble>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _pulseController;
  late AnimationController _expandController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _toggleBubble() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, child) {
        return Stack(
          children: [
            // Chat overlay when expanded
            if (_isExpanded)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleBubble,
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: ScaleTransition(
                        scale: _expandAnimation,
                        child: _buildChatInterface(aiProvider),
                      ),
                    ),
                  ),
                ),
              ),
            
            // Floating microphone bubble
            Positioned(
              bottom: 30,
              right: 20,
              child: GestureDetector(
                onTap: _isExpanded ? null : _toggleBubble,
                onLongPress: _isExpanded ? null : () => _startVoiceInput(aiProvider),
                child: AnimatedBuilder(
                  animation: aiProvider.isListening ? _pulseAnimation : _expandController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: aiProvider.isListening 
                          ? _pulseAnimation.value 
                          : 1.0,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: aiProvider.isListening
                                ? [Colors.red, Colors.redAccent]
                                : [AppTheme.primaryBlue, AppTheme.lightBlue],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: (aiProvider.isListening 
                                      ? Colors.red 
                                      : AppTheme.primaryBlue)
                                  .withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          aiProvider.isListening 
                              ? Icons.mic 
                              : Icons.mic_none_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatInterface(AIAssistantProvider aiProvider) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Voice AI Assistant',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _toggleBubble,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          
          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: aiProvider.messages.length,
              itemBuilder: (context, index) {
                final message = aiProvider.messages[index];
                return _buildMessageBubble(
                  message['text'] ?? '',
                  message['isUser'] ?? false,
                  message['timestamp'] ?? DateTime.now(),
                );
              },
            ),
          ),
          
          // Voice input controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Voice input button
                Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => _startVoiceInput(aiProvider),
                    onTapUp: (_) => _stopVoiceInput(aiProvider),
                    onTapCancel: () => _stopVoiceInput(aiProvider),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: aiProvider.isListening
                              ? [Colors.red, Colors.redAccent]
                              : [AppTheme.primaryBlue, AppTheme.lightBlue],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            aiProvider.isListening 
                                ? Icons.mic 
                                : Icons.mic_none,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            aiProvider.isListening 
                                ? 'Listening...' 
                                : 'Hold to Speak',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                if (aiProvider.isProcessing) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, DateTime timestamp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: isUser 
                    ? const LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
                      )
                    : null,
                color: isUser ? null : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
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
  }

  void _startVoiceInput(AIAssistantProvider aiProvider) {
    aiProvider.startListening();
    // Here you would integrate with speech recognition
    // For now, we'll simulate it
    _simulateVoiceInput(aiProvider);
  }

  void _stopVoiceInput(AIAssistantProvider aiProvider) {
    aiProvider.stopListening();
  }

  // Simulate voice input for demonstration
  void _simulateVoiceInput(AIAssistantProvider aiProvider) {
    Future.delayed(const Duration(seconds: 2), () {
      if (aiProvider.isListening) {
        aiProvider.stopListening();
        // Simulate sending a voice message
        aiProvider.sendMessage("I want to enhance my product photo with AI");
      }
    });
  }
}