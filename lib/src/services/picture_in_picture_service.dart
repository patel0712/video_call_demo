import 'package:flutter/services.dart';

class PictureInPictureService {
  static const MethodChannel _channel =
      MethodChannel('picture_in_picture_plugin');

  // Singleton instance
  static final PictureInPictureService _instance =
      PictureInPictureService._internal();
  factory PictureInPictureService() => _instance;
  PictureInPictureService._internal();

  /// Set screen sharing state to enable/disable automatic PiP mode
  Future<void> setScreenSharingState(bool sharing) async {
    try {
      await _channel
          .invokeMethod('setScreenSharingState', {'sharing': sharing});
      print('📱 Screen sharing state set to: $sharing');
    } on PlatformException catch (e) {
      print('❌ Error setting screen sharing state: ${e.message}');
    }
  }

  /// Manually enter Picture-in-Picture mode
  Future<void> enterPiPMode() async {
    try {
      await _channel.invokeMethod('enterPiPMode');
      print('📱 Entering PiP mode');
    } on PlatformException catch (e) {
      print('❌ Error entering PiP mode: ${e.message}');
    }
  }
}

