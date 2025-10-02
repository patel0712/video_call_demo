import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCScreenShareService {
  MediaStream? _screenStream;

  Future<MediaStream?> startScreenShare() async {
    try {
      final stream = await navigator.mediaDevices.getDisplayMedia({
        'video': {
          'mandatory': {
            'minWidth': '1280',
            'minHeight': '720',
            'minFrameRate': '15',
          },
        },
        'audio': false,
      });
      _screenStream = stream;
      return stream;
    } catch (e) {
      print('Error starting screen share: $e');
      return null;
    }
  }

  Future<void> stopScreenShare() async {
    _screenStream?.getTracks().forEach((track) => track.stop());
    _screenStream = null;
  }

  MediaStream? get screenStream => _screenStream;
}
