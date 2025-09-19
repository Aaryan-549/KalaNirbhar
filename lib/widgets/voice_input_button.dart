import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/ai_assistant_provider.dart';
import '../services/speech_recognition_service.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onVoiceInput;
  final bool isListening;

  const VoiceInputButton({
    super.key,
    required this.onVoiceInput,
    required this.isListening,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isListening) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleVoiceInput,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated ripple effect when listening
          if (widget.isListening)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryBlue.withOpacity(_opacityAnimation.value),
                    ),
                  ),
                );
              },
            ),
          
          // Main button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: widget.isListening 
                  ? const LinearGradient(
                      colors: [Colors.red, Colors.redAccent],
                    )
                  : AppTheme.buttonGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.isListening ? Colors.red : AppTheme.primaryBlue)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              widget.isListening ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _handleVoiceInput() async {
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    
    if (widget.isListening || SpeechRecognitionService.isListening) {
      // Stop listening
      await SpeechRecognitionService.stopListening();
      aiProvider.stopListening();
    } else {
      // Start listening
      aiProvider.startListening();
      await _startSpeechRecognition();
    }
  }

  Future<void> _startSpeechRecognition() async {
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    
    try {
      // Initialize speech recognition if needed
      if (!SpeechRecognitionService.isInitialized) {
        final initialized = await SpeechRecognitionService.initialize();
        if (!initialized) {
          _showError('Speech recognition not available on this device');
          aiProvider.stopListening();
          return;
        }
      }
      
      // Start listening for speech
      await SpeechRecognitionService.startListening(
        onResult: (recognizedText) {
          print('Speech recognized: $recognizedText');
          if (recognizedText.isNotEmpty) {
            widget.onVoiceInput(recognizedText);
          }
          aiProvider.stopListening();
        },
        languageCode: aiProvider.currentLanguage,
        onError: (error) {
          print('Speech recognition error: $error');
          _showError(error);
          aiProvider.stopListening();
        },
      );
      
    } catch (e) {
      print('Voice input error: $e');
      _showError('Failed to start voice recognition: $e');
      aiProvider.stopListening();
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}