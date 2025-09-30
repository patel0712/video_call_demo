import 'package:bloc_clean_architecture/src/presentation/bloc/video_call/video_call_bloc.dart';
import 'package:bloc_clean_architecture/src/presentation/page/video_call/video_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// Demo screen to test video calling with hardcoded values
/// This allows you to test the video calling feature between two devices
class VideoCallTestScreen extends StatelessWidget {
  const VideoCallTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Video Calling',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Use these hardcoded values to test calling between two devices:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Test scenarios
            _buildTestCard(
              context,
              title: 'Device 1 (Host)',
              meetingId: 'test-meeting-123',
              participantName: 'Alice (Host)',
              description: 'Start this on the first device',
              color: Colors.blue,
            ),
            const SizedBox(height: 16),

            _buildTestCard(
              context,
              title: 'Device 2 (Guest)',
              meetingId: 'test-meeting-123',
              participantName: 'Bob (Guest)',
              description: 'Start this on the second device',
              color: Colors.green,
            ),
            const SizedBox(height: 30),

            const Text(
              'Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            const Text(
              '1. Make sure your backend server is running on the configured IP\n'
              '2. Use the same meeting ID on both devices\n'
              '3. Start with Device 1 (Host) first\n'
              '4. Then start Device 2 (Guest)\n'
              '5. Both devices should connect to the same meeting',
              style: TextStyle(fontSize: 14),
            ),

            const Spacer(),

            // Quick join option
            ElevatedButton(
              onPressed: () => _joinCustomMeeting(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Custom Meeting',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(
    BuildContext context, {
    required String title,
    required String meetingId,
    required String participantName,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text('Meeting ID: $meetingId'),
            Text('Participant: $participantName'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    _joinMeeting(context, meetingId, participantName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Join as $title',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _joinMeeting(
    BuildContext context,
    String meetingId,
    String participantName,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => BlocProvider(
          create: (context) => GetIt.instance<VideoCallBloc>(),
          child: VideoCallScreen(
            meetingId: meetingId,
            participantName: participantName,
          ),
        ),
      ),
    );
  }

  void _joinCustomMeeting(BuildContext context) {
    final meetingIdController = TextEditingController();
    final nameController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join Custom Meeting'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: meetingIdController,
                decoration: const InputDecoration(
                  labelText: 'Meeting ID',
                  hintText: 'Enter meeting ID',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  hintText: 'Enter your name',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (meetingIdController.text.isNotEmpty &&
                    nameController.text.isNotEmpty) {
                  _joinMeeting(
                    context,
                    meetingIdController.text.trim(),
                    nameController.text.trim(),
                  );
                }
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }
}

/// Helper class for creating demo meetings
class VideoCallDemoHelper {
  static const String defaultMeetingId = 'demo-meeting-123';
  static const String defaultHostName = 'Host User';
  static const String defaultGuestName = 'Guest User';

  /// Create a demo meeting for testing
  static Map<String, String> createDemoMeeting({
    String? meetingId,
    String? hostName,
    String? guestName,
  }) {
    return {
      'meetingId': meetingId ?? defaultMeetingId,
      'hostName': hostName ?? defaultHostName,
      'guestName': guestName ?? defaultGuestName,
    };
  }

  /// Generate random meeting ID for testing
  static String generateMeetingId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'meeting-$timestamp';
  }
}
