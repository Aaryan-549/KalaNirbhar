import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isPlaying = false;
  
  // Play audio from bytes (for TTS responses)
  static Future<void> playAudioFromBytes(Uint8List audioBytes) async {
    try {
      if (_isPlaying) {
        await stopAudio();
      }
      
      _isPlaying = true;
      await _audioPlayer.play(BytesSource(audioBytes));
      print('Audio playback started successfully: ${audioBytes.length} bytes');
      
      // Listen for completion
      _audioPlayer.onPlayerComplete.listen((event) {
        _isPlaying = false;
        print('Audio playback completed');
      });
      
    } catch (e) {
      _isPlaying = false;
      print('Audio playback error: $e');
    }
  }
  
  // Stop audio playback
  static Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (e) {
      print('Audio stop error: $e');
    }
  }
  
  // Set volume (0.0 to 1.0)
  static Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      print('Volume set error: $e');
    }
  }
  
  // Check if audio is currently playing
  static bool get isPlaying => _isPlaying;
  
  // Dispose resources
  static Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      _isPlaying = false;
    } catch (e) {
      print('Audio dispose error: $e');
    }
  }
}