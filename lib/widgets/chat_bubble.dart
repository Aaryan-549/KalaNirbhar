import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/app_theme.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final List<Uint8List>? images;
  final String? imagePrompt;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.images,
    this.imagePrompt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(),
            const SizedBox(width: 12),
          ],
          Flexible(
            flex: 7,
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Main message bubble
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser 
                        ? AppTheme.buttonGradient 
                        : null,
                    color: isUser 
                        ? null 
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image prompt (if this was an image enhancement request)
                      if (imagePrompt != null && imagePrompt!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (isUser ? Colors.white.withOpacity(0.2) : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.photo_camera,
                                size: 16,
                                color: isUser ? Colors.white70 : AppTheme.textLight,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Image Request: $imagePrompt',
                                  style: TextStyle(
                                    color: isUser ? Colors.white70 : AppTheme.textLight,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      
                      // Main message text
                      if (message.isNotEmpty)
                        Text(
                          message,
                          style: TextStyle(
                            color: isUser ? Colors.white : AppTheme.textDark,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            height: 1.4,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Enhanced images section
                if (images != null && images!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildImagesSection(),
                ],
                
                const SizedBox(height: 4),
                Text(
                  _formatTime(timestamp),
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 11,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 16,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 6),
              Text(
                'Enhanced Images (${images!.length})',
                style: const TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Images grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: images!.length,
            itemBuilder: (context, index) {
              return _buildImageCard(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Image
            Image.memory(
              images![index],
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            
            // Overlay with download button
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () => _downloadImage(index),
                  icon: const Icon(
                    Icons.download,
                    color: Colors.white,
                    size: 20,
                  ),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
            ),
            
            // Image number badge
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadImage(int index) async {
    try {
      // Request storage permission
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission denied');
        }
      }

      // Get downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) {
        throw Exception('Could not access downloads directory');
      }

      // Create filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'kalanirbhar_enhanced_$timestamp.png';
      final filePath = '${downloadsDir.path}/$filename';

      // Write file
      final file = File(filePath);
      await file.writeAsBytes(images![index]);

      // Show success message with haptic feedback
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Image saved to Downloads/$filename',
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () {
              // You can implement opening the file here if needed
            },
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to save image: $e',
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        gradient: AppTheme.buttonGradient,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.smart_toy_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.person,
        color: AppTheme.primaryBlue,
        size: 20,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}

// Global navigator key for snackbar access
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();