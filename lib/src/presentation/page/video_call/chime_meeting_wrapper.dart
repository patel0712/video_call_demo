import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_aws_chime/models/join_info.model.dart';
import 'package:flutter_aws_chime/views/meeting.view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_clean_architecture/src/presentation/bloc/video_call/video_call_bloc.dart';

/// Wrapper widget for AWS Chime MeetingView
/// This renders the video call interface using the AWS Chime SDK
class ChimeMeetingWrapper extends StatefulWidget {
  final JoinInfo joinInfo;

  const ChimeMeetingWrapper({required this.joinInfo, super.key});

  @override
  State<ChimeMeetingWrapper> createState() => _ChimeMeetingWrapperState();
}

class _ChimeMeetingWrapperState extends State<ChimeMeetingWrapper> {
  Timer? _participantPollingTimer;

  @override
  void initState() {
    super.initState();
    debugPrint('🎥 Initializing ChimeMeetingWrapper');
    debugPrint('📋 Meeting ID: ${widget.joinInfo.meeting.meetingId}');
    debugPrint('👤 Attendee ID: ${widget.joinInfo.attendee.attendeeId}');
    debugPrint('🌍 Media Region: ${widget.joinInfo.meeting.mediaRegion}');
    debugPrint(
        '🔗 Signaling URL: ${widget.joinInfo.meeting.mediaPlacement.signalingUrl}');

    // Start polling for participant states every 3 seconds
    _startParticipantPolling();
  }

  @override
  void dispose() {
    _participantPollingTimer?.cancel();
    super.dispose();
  }

  void _startParticipantPolling() {
    _participantPollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        if (mounted) {
          debugPrint('🔄 Polling for participant states...');
          context.read<VideoCallBloc>().add(const FetchParticipantStates());
        }
      },
    );
    debugPrint('⏰ Started participant polling timer');
  }

  void _endCall() {
    debugPrint('🔴 Ending call from ChimeMeetingWrapper');

    // Show confirmation dialog
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'End Call',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to end this call?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _confirmEndCall();
              },
              child: const Text(
                'End Call',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmEndCall() {
    // Get the current bloc state to access meeting and attendee IDs
    final bloc = context.read<VideoCallBloc>();
    final state = bloc.state;

    if (state.meetingId.isNotEmpty) {
      // Trigger end meeting event to properly clean up the meeting
      bloc.add(const EndVideoCall());

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ending call...'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
    }

    // Navigate back
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎬 Building ChimeMeetingWrapper UI');

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _endCall();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // Header with meeting info
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black87,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _endCall,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Video Call',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Meeting: ${widget.joinInfo.meeting.meetingId.substring(0, 8)}...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.call_end, color: Colors.red),
                      onPressed: _endCall,
                    ),
                  ],
                ),
              ),
              // AWS Chime MeetingView
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Builder(
                    builder: (context) {
                      try {
                        return MeetingView(widget.joinInfo);
                      } catch (e) {
                        debugPrint('❌ Error rendering MeetingView: $e');
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load video call',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Error: $e',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                    },
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
