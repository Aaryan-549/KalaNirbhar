import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_assistant_provider.dart';
import '../utils/app_theme.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleVoiceInput,
      onLongPressStart: (_) => _startListening(),
      onLongPressEnd: (_) => _stopListening(),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isListening ? _pulseAnimation.value : 1.0,
            child: Container(
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
                    blurRadius: widget.isListening ? 15 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.isListening ? Icons.mic : Icons.mic_none_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleVoiceInput() {
    if (widget.isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    aiProvider.startListening();
    
    _showListeningDialog();
  }

  void _stopListening() {
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    aiProvider.stopListening();
    
    Navigator.of(context, rootNavigator: true).pop();
    
    // Simulate voice recognition result
    _simulateVoiceRecognition();
  }

  void _showListeningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red, Colors.redAccent],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'सुन रहा हूं...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'बोलना जारी रखें',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _stopListening();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'रोकें',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _simulateVoiceRecognition() {
    // Simulate some common voice inputs in Hindi
    final List<String> sampleInputs = [
      'मेरी फोटो को बेहतर बनाएं',
      'मेरे उत्पाद की कहानी लिखें',
      'डिजिटल प्रमाणपत्र बनाएं',
      'मेरी बिक्री कैसी चल रही है?',
      'मार्केटिंग में मदद करें',
    ];
    
    // Random selection for demo
    final randomInput = sampleInputs[
      DateTime.now().millisecond % sampleInputs.length
    ];
    
    // Delay to simulate processing
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onVoiceInput(randomInput);
    });
  }
}