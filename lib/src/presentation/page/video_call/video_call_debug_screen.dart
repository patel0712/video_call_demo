import 'package:flutter/material.dart';
import 'package:flutter_aws_chime/models/join_info.model.dart';
import 'package:flutter_aws_chime/views/meeting.view.dart';

class VideoCallDebugScreen extends StatefulWidget {
  const VideoCallDebugScreen({super.key});

  @override
  State<VideoCallDebugScreen> createState() => _VideoCallDebugScreenState();
}

class _VideoCallDebugScreenState extends State<VideoCallDebugScreen> {
  bool _showMeetingView = false;
  JoinInfo? _testJoinInfo;

  void _createTestJoinInfo() {
    // Create a test JoinInfo with the exact data you received from your API
    final testData = {
      'Meeting': {
        'MeetingId': '9503c56c-5e07-4881-90dd-e1c7cdcb2713',
        'ExternalMeetingId': 'test-meeting-123',
        'MediaRegion': 'us-east-1',
        'MediaPlacement': {
          'AudioHostUrl':
              '07f1f9ce9b4a02658155df50acbdd6da.k.m2.ue1.app.chime.aws:3478',
          'AudioFallbackUrl':
              'wss://wss.k.m2.ue1.app.chime.aws:443/calls/9503c56c-5e07-4881-90dd-e1c7cdcb2713',
          'SignalingUrl':
              'wss://signal.m2.ue1.app.chime.aws/control/9503c56c-5e07-4881-90dd-e1c7cdcb2713',
          'TurnControlUrl':
              'https://2713.cell.us-east-1.meetings.chime.aws/v2/turn_sessions',
          'ScreenDataUrl':
              'wss://bitpw.m2.ue1.app.chime.aws:443/v2/screen/9503c56c-5e07-4881-90dd-e1c7cdcb2713',
          'ScreenViewingUrl':
              'wss://bitpw.m2.ue1.app.chime.aws:443/ws/connect?passcode=null&viewer_uuid=null&X-BitHub-Call-Id=9503c56c-5e07-4881-90dd-e1c7cdcb2713',
          'ScreenSharingUrl':
              'wss://bitpw.m2.ue1.app.chime.aws:443/v2/screen/9503c56c-5e07-4881-90dd-e1c7cdcb2713',
          'EventIngestionUrl':
              'https://data.svc.ue1.ingest.chime.aws/v1/client-events',
        },
      },
      'Attendee': {
        'ExternalUserId': 'Bob',
        'AttendeeId': '61d83b5d-598d-319f-f4b3-b2062ed873cc',
        'JoinToken':
            'NjFkODNiNWQtNTk4ZC0zMTlmLWY0YjMtYjIwNjJlZDg3M2NjOmU4ZjgxM2YyLWQ5YWUtNDhlYy05YjMyLTQwZTk1ZTdlNjdlNg',
        'Capabilities': {
          'Audio': 'SendReceive',
          'Video': 'SendReceive',
          'Content': 'SendReceive',
        },
      },
    };

    try {
      _testJoinInfo = JoinInfo.fromJson(testData);
      debugPrint('✅ Test JoinInfo created successfully!');
      debugPrint('📄 JoinInfo type: ${_testJoinInfo.runtimeType}');
      debugPrint('📄 JoinInfo toString: ${_testJoinInfo.toString()}');

      setState(() {
        _showMeetingView = true;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating JoinInfo: $e');
      debugPrint('📄 Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating JoinInfo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call Debug'),
        backgroundColor: Colors.blue,
      ),
      body: _showMeetingView && _testJoinInfo != null
          ? Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green.withOpacity(0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        'MeetingView Loading...',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showMeetingView = false;
                            _testJoinInfo = null;
                          });
                        },
                        child: const Text('Back to Debug'),
                      ),
                    ],
                  ),
                ),
                Expanded(child: MeetingView(_testJoinInfo!)),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Video Call Integration Debug',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'This screen helps debug the integration with flutter_aws_chime package.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Test Steps:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '1. Create JoinInfo from your API response data',
                            ),
                            const Text('2. Verify JoinInfo object is valid'),
                            const Text('3. Test MeetingView rendering'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _createTestJoinInfo,
                              child: const Text(
                                'Create Test JoinInfo & Show MeetingView',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your API Response Data:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Meeting ID: 9503c56c-5e07-4881-90dd-e1c7cdcb2713\n'
                              'External Meeting ID: test-meeting-123\n'
                              'Attendee: Bob\n'
                              'Region: us-east-1',
                              style: TextStyle(fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Card(
                      color: Colors.orange.withOpacity(0.1),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expected Behavior:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('✅ JoinInfo should be created without errors'),
                            Text(
                              '✅ MeetingView should render video calling interface',
                            ),
                            Text('✅ You should see camera/microphone controls'),
                            Text(
                              '✅ Video calling should work between two devices',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
