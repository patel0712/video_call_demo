import 'package:bloc_clean_architecture/src/presentation/page/video_call/video_call_test_screen.dart';
import 'package:flutter/material.dart';

/// Add this to your main navigation or dashboard to easily access video call testing
class VideoCallNavigationHelper {
  /// Navigate to video call test screen
  static void navigateToTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const VideoCallTestScreen(),
      ),
    );
  }

  /// Quick join a meeting with default values
  static void quickJoinMeeting(
    BuildContext context, {
    String meetingId = 'test-meeting-123',
    String participantName = 'Test User',
  }) {
    // You can implement direct navigation to VideoCallScreen here
    // For now, navigate to test screen
    navigateToTest(context);
  }
}

/// Widget to add to your dashboard for quick access
class VideoCallQuickAccessWidget extends StatelessWidget {
  const VideoCallQuickAccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.video_call, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Video Calling',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Test video calling between devices with AWS Chime SDK',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        VideoCallNavigationHelper.navigateToTest(context),
                    icon: const Icon(Icons.science, size: 16),
                    label: const Text('Test Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        VideoCallNavigationHelper.quickJoinMeeting(context),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Quick Join'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
