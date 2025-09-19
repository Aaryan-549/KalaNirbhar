import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();
  
  static Future<Uint8List?> pickImageFromCamera({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        print('Image captured from camera: ${bytes.length} bytes');
        return bytes;
      } else {
        print('No image selected from camera');
        return null;
      }
    } on PlatformException catch (e) {
      print('Platform exception in camera picker: ${e.message}');
      return null;
    } catch (e) {
      print('Camera picker error: $e');
      return null;
    }
  }
  
  static Future<Uint8List?> pickImageFromGallery({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        print('Image selected from gallery: ${bytes.length} bytes');
        return bytes;
      } else {
        print('No image selected from gallery');
        return null;
      }
    } on PlatformException catch (e) {
      print('Platform exception in gallery picker: ${e.message}');
      return null;
    } catch (e) {
      print('Gallery picker error: $e');
      return null;
    }
  }
  
  static Future<List<Uint8List>?> pickMultipleImages({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
    int limit = 5,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
        limit: limit,
      );
      
      if (images.isNotEmpty) {
        List<Uint8List> imageBytes = [];
        for (final image in images) {
          final bytes = await image.readAsBytes();
          imageBytes.add(bytes);
        }
        print('Selected ${imageBytes.length} images from gallery');
        return imageBytes;
      } else {
        print('No images selected');
        return null;
      }
    } on PlatformException catch (e) {
      print('Platform exception in multiple image picker: ${e.message}');
      return null;
    } catch (e) {
      print('Multiple image picker error: $e');
      return null;
    }
  }
  
  // Helper method to validate image format
  static bool isValidImageFormat(String path) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final extension = path.toLowerCase();
    return validExtensions.any((ext) => extension.endsWith(ext));
  }
}