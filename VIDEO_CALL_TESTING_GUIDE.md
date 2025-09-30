# Video Calling Feature Testing Guide

## Overview
This guide explains how to test the AWS Chime SDK video calling feature in your Flutter app. The implementation supports one-to-one video calling with proper clean architecture pattern.

## Prerequisites

### 1. Backend Server Setup
- Ensure your AWS Chime backend server is running on `http://192.168.20.115:5000` (or update the IP in `ApiConstants.awsChimeLocalhost`)
- The server should have a `/join` endpoint that accepts POST requests with `meetingId` and `name` parameters
- Server should return the meeting and attendee information as shown in your API response

### 2. Device Requirements
- **Two physical devices** or **one device + simulator** for testing
- Camera and microphone permissions
- Network connectivity to your backend server

### 3. Dependencies Check
Ensure these dependencies are in your `pubspec.yaml`:
```yaml
dependencies:
  flutter_aws_chime: ^1.0.0
  permission_handler: ^11.0.1
  # ... other dependencies
```

## Testing Methods

### Method 1: Using the Test Screen (Recommended)

1. **Add Test Screen to Navigation**
   - Import the test screen in your main dashboard or home screen:
   ```dart
   import 'package:bloc_clean_architecture/src/presentation/page/video_call/video_call_test_screen.dart';
   ```

2. **Add Navigation Button**
   ```dart
   // In your dashboard or home screen
   ElevatedButton(
     onPressed: () {
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (context) => const VideoCallTestScreen(),
         ),
       );
     },
     child: const Text('Video Call Test'),
   )
   ```

3. **Test Between Two Devices**
   - Open the app on **Device 1**
   - Navigate to Video Call Test Screen
   - Tap **"Join as Device 1 (Host)"**
   - Open the app on **Device 2** 
   - Navigate to Video Call Test Screen
   - Tap **"Join as Device 2 (Guest)"**
   - Both devices should connect to the same meeting

### Method 2: Direct Navigation

```dart
// Navigate directly to video call screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => GetIt.instance<VideoCallBloc>(),
      child: const VideoCallScreen(
        meetingId: 'test-meeting-123',
        participantName: 'Test User',
      ),
    ),
  ),
);
```

### Method 3: Using the Quick Access Widget

Add this widget to your dashboard:

```dart
import 'package:bloc_clean_architecture/src/presentation/widget/video_call_navigation_helper.dart';

// In your dashboard widget tree
const VideoCallQuickAccessWidget(),
```

## Testing Scenarios

### Scenario 1: Basic Connection Test
1. **Device A**: Join with Meeting ID `test-meeting-123` as `Alice`
2. **Device B**: Join with Meeting ID `test-meeting-123` as `Bob`
3. **Expected**: Both devices connect and can see/hear each other

### Scenario 2: Custom Meeting IDs
1. Use the "Custom Meeting" button in test screen
2. Enter a unique meeting ID (e.g., `meeting-$(timestamp)`)
3. Share this meeting ID with the second device
4. Both join using the same custom meeting ID

### Scenario 3: Error Handling
1. Try joining with incorrect server URL
2. Try joining without network connection
3. Verify error messages are displayed properly

## Debugging

### 1. Check Console Logs
Look for these debug messages:
```
I/flutter: Joining meeting: test-meeting-123 with participant: Alice
I/flutter: Raw API response =====> {Meeting: {...}, Attendee: {...}}
I/flutter: Meeting ID: 370dc658-86e7-4da2-bc76-bc9be46f2713
I/flutter: Attendee ID: 2f927734-d9d0-c0e3-86aa-50d12b1949cf
```

### 2. Network Issues
- Verify your device can reach the backend server
- Check if the IP address in `ApiConstants.awsChimeLocalhost` is correct
- For Android emulator, use `http://10.0.2.2:5000` instead of localhost

### 3. Permission Issues
The app should automatically request camera and microphone permissions. If not:
- Check device settings for app permissions
- Verify `permission_handler` is properly configured

## Expected API Response Format

Your backend should return this JSON structure:
```json
{
  "Meeting": {
    "MeetingId": "370dc658-86e7-4da2-bc76-bc9be46f2713",
    "ExternalMeetingId": "room-123",
    "MediaRegion": "us-east-1",
    "MediaPlacement": {
      "AudioHostUrl": "...",
      "AudioFallbackUrl": "...",
      "SignalingUrl": "...",
      "TurnControlUrl": "...",
      "ScreenDataUrl": "...",
      "ScreenViewingUrl": "...",
      "ScreenSharingUrl": "...",
      "EventIngestionUrl": "..."
    }
  },
  "Attendee": {
    "ExternalUserId": "Jeet Patel",
    "AttendeeId": "2f927734-d9d0-c0e3-86aa-50d12b1949cf",
    "JoinToken": "...",
    "Capabilities": {
      "Audio": "SendReceive",
      "Video": "SendReceive",
      "Content": "SendReceive"
    }
  }
}
```

## Troubleshooting Common Issues

### Issue 1: "Target of URI doesn't exist" errors
- **Solution**: Run `flutter clean && flutter pub get`
- Make sure all imports are correct

### Issue 2: Connection timeouts
- **Solution**: Check network connectivity and server status
- Verify the backend server is running and accessible

### Issue 3: Permissions denied
- **Solution**: Grant camera and microphone permissions manually in device settings
- Restart the app after granting permissions

### Issue 4: Video not showing
- **Solution**: Ensure AWS Chime SDK is properly integrated
- Check if `MeetingView` widget is receiving correct `JoinInfo`

## Testing Checklist

- [ ] Backend server is running and accessible
- [ ] Both devices have camera/microphone permissions
- [ ] App builds without errors
- [ ] Navigation to video call screen works
- [ ] API call succeeds and returns proper response
- [ ] Meeting connection is established
- [ ] Audio/video controls work
- [ ] Leave meeting functionality works
- [ ] Error handling displays appropriate messages

## Production Considerations

1. **Replace hardcoded values** with dynamic meeting creation
2. **Implement proper user authentication** 
3. **Add meeting invitation/sharing features**
4. **Handle network quality indicators**
5. **Add background/foreground state handling**
6. **Implement proper error recovery**

## Next Steps

After successful testing, you can:
1. Integrate with your user management system
2. Add meeting scheduling features
3. Implement group video calling
4. Add chat functionality
5. Implement call recording features

## Support

If you encounter issues:
1. Check the debug console for error messages
2. Verify your backend API response format
3. Test network connectivity
4. Check AWS Chime SDK documentation for additional troubleshooting