import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_assistant_provider.dart';
import '../utils/app_theme.dart';

class FeatureSuggestionChips extends StatelessWidget {
  const FeatureSuggestionChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, child) {
        final suggestions = aiProvider.getFeatureSuggestions();
        
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 8,
                right: index == suggestions.length - 1 ? 0 : 8,
              ),
              child: _buildSuggestionChip(
                context,
                suggestions[index],
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
            ),
          ],
        ),
      ),
    );
  }
}