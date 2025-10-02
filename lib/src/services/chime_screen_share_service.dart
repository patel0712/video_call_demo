import 'platform_screen_share.dart';
import 'picture_in_picture_service.dart';

class ChimeScreenShareService {
  static final ChimeScreenShareService _instance =
      ChimeScreenShareService._internal();
  factory ChimeScreenShareService() => _instance;
  ChimeScreenShareService._internal();

  bool _isScreenSharing = false;
  bool get isScreenSharing => _isScreenSharing;

  final PictureInPictureService _pipService = PictureInPictureService();

  /// Start screen sharing session
  Future<bool> startScreenShare({
    required String meetingId,
    required String userName,
  }) async {
    print('🎥 Starting screen share for meeting: $meetingId, user: $userName');
    try {
      // Test plugin communication first
      print('🧪 Testing plugin communication...');
      final testResult = await PlatformScreenShare.testPlugin();
      print('🧪 Plugin test result: $testResult');

      print('📱 Requesting native screen capture...');
      final success = await PlatformScreenShare.startScreenShare();
      print('📱 Screen capture request result: $success');
      if (success) {
        _isScreenSharing = true;
        // Enable automatic PiP mode when screen sharing
        await _pipService.setScreenSharingState(true);
        print('📱 PiP mode enabled for screen sharing');
      }
      return success;
    } catch (e) {
      print('Error starting screen share: $e');
      await stopScreenShare();
      return false;
    }
  }

  /// Stop screen sharing session
  Future<void> stopScreenShare() async {
    print('🎥 Stopping screen share');
    try {
      print('📱 Requesting to stop native screen capture...');
      await PlatformScreenShare.stopScreenShare();
      print('📱 Screen capture stopped successfully');
      _isScreenSharing = false;

      // Disable PiP mode when screen sharing stops
      await _pipService.setScreenSharingState(false);
      print('📱 PiP mode disabled');
    } catch (e) {
      print('❌ Error stopping screen share: $e');
    }
  }

  /// Manually enter Picture-in-Picture mode
  Future<void> enterPiPMode() async {
    await _pipService.enterPiPMode();
  }

  /// Clean up resources
  void dispose() {
    stopScreenShare();
  }
}
