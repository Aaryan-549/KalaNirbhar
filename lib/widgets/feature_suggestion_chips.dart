import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_assistant_provider.dart';
import '../utils/app_theme.dart';

class FeatureSuggestionChips extends StatefulWidget {
  const FeatureSuggestionChips({super.key});

  @override
  State<FeatureSuggestionChips> createState() => _FeatureSuggestionChipsState();
}

class _FeatureSuggestionChipsState extends State<FeatureSuggestionChips> {
  List<String> _suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload suggestions when language changes
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    try {
      final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
      final suggestions = await aiProvider.getFeatureSuggestions();
      
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading suggestions: $e');
      // Fallback suggestions
      if (mounted) {
        setState(() {
          _suggestions = [
            '📸 AI Photo Enhancement',
            '📝 Generate Story',
            '🛡️ Create Certificate',
            '📊 View Analytics',
            '📱 Marketing Content'
          ];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          ),
        ),
      );
    }

    if (_suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, child) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 8,
                right: index == _suggestions.length - 1 ? 0 : 8,
              ),
              child: _buildSuggestionChip(
                context,
                _suggestions[index],
                aiProvider,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSuggestionChip(
    BuildContext context,
    String suggestion,
    AIAssistantProvider aiProvider,
  ) {
    return GestureDetector(
      onTap: () {
        aiProvider.handleFeatureSuggestion(suggestion);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppTheme.buttonGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              suggestion,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}