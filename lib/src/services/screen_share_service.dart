import 'package:flutter/services.dart';

class ScreenShareService {
  static const MethodChannel _channel = MethodChannel('screen_share_plugin');

  // Singleton instance
  static final ScreenShareService _instance = ScreenShareService._internal();
  factory ScreenShareService() => _instance;
  ScreenShareService._internal();

  bool _isScreenSharing = false;
  bool get isScreenSharing => _isScreenSharing;

  /// Start screen sharing
  Future<bool> startScreenShare() async {
    try {
      final result = await _channel.invokeMethod('startScreenShare') as bool;
      if (result) {
        _isScreenSharing = true;
        // Native side will handle switching video source to screen capture
      }
      return result;
    } on PlatformException catch (e) {
      print('Error starting screen share: ${e.message}');
      _isScreenSharing = false;
      return false;
    }
  }

  /// Stop screen sharing
  Future<void> stopScreenShare() async {
    try {
      await _channel.invokeMethod('stopScreenShare');
      // Native side will handle switching video source back to camera
      _isScreenSharing = false;
    } on PlatformException catch (e) {
      print('Error stopping screen share: ${e.message}');
    }
  }
}
