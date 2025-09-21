import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/ai_assistant_provider.dart';
import '../utils/app_theme.dart';
import 'dart:typed_data';

class ImageDisplayButton extends StatefulWidget {
  const ImageDisplayButton({super.key});

  @override
  State<ImageDisplayButton> createState() => _ImageDisplayButtonState();
}

class _ImageDisplayButtonState extends State<ImageDisplayButton> {
  final TextEditingController _imagePromptController = TextEditingController();
  XFile? _selectedImage;
  bool _isImageSelected = false;

  @override
  void dispose() {
    _imagePromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, child) {
        // If image is selected, show the prompt input
        if (_isImageSelected && _selectedImage != null) {
          return _buildImagePromptInput();
        }
        
        // Show image picker buttons
        return _buildImagePickerButton();
      },
    );
  }

  Widget _buildImagePickerButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Camera button
          Expanded(
            child: GestureDetector(
              onTap: () => _pickImage(ImageSource.camera),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Camera',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Gallery button
          Expanded(
            child: GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.orange, Color(0xFFFF8A65)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Gallery',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePromptInput() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected image preview
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FutureBuilder<Uint8List>(
                future: _selectedImage!.readAsBytes(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryBlue,
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Prompt input
          TextField(
            controller: _imagePromptController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe what you want to do with this image...\n\nExample: "Make the background white and professional for e-commerce" or "Place this product in a modern living room setting"',
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                color: AppTheme.textLight,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primaryBlue),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.black, // Fixed text color
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Action buttons
          Row(
            children: [
              // Cancel button
              Expanded(
                child: TextButton(
                  onPressed: _cancelImageSelection,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Process button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _processImageWithPrompt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Enhance Image',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _isImageSelected = true;
        });
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error selecting image: $e',
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
  }

  void _cancelImageSelection() {
    setState(() {
      _selectedImage = null;
      _isImageSelected = false;
      _imagePromptController.clear();
    });
  }

  Future<void> _processImageWithPrompt() async {
    if (_selectedImage == null) return;
    
    final prompt = _imagePromptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please describe what you want to do with the image',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: AppTheme.orange,
        ),
      );
      return;
    }

    try {
      // Show processing dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.primaryBlue),
              const SizedBox(height: 16),
              const Text(
                'Enhancing your image with AI...',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                prompt,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
      
      // Process with AI
      final bytes = await _selectedImage!.readAsBytes();
      final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
      await aiProvider.enhanceProductImageWithPrompt(bytes, prompt);
      
      // Close processing dialog
      if (mounted) {
        Navigator.pop(context);
        
        // Reset the input
        _cancelImageSelection();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Image enhanced and added to chat!',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      
    } catch (e) {
      // Close any open dialogs
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error processing image: $e',
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
  }
}