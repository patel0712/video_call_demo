import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aws_chime/models/join_info.model.dart';
import 'package:flutter_aws_chime/views/meeting.view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_clean_architecture/src/presentation/bloc/video_call/video_call_bloc.dart';
import '../../../services/chime_screen_share_service.dart';

/// A widget that wraps the AWS Chime SDK meeting view with additional functionality
/// like screen sharing and meeting controls
class ChimeMeetingWrapper extends StatefulWidget {
  final JoinInfo joinInfo;

  const ChimeMeetingWrapper({required this.joinInfo, super.key});

  @override
  State<ChimeMeetingWrapper> createState() => _ChimeMeetingWrapperState();
}

class _ChimeMeetingWrapperState extends State<ChimeMeetingWrapper> {
  Timer? _participantPollingTimer;
  final ChimeScreenShareService _screenShareService = ChimeScreenShareService();

  @override
  void initState() {
    super.initState();
    debugPrint('🎥 Initializing ChimeMeetingWrapper');
    debugPrint('📋 Meeting ID: ${widget.joinInfo.meeting.meetingId}');
    debugPrint('👤 Attendee ID: ${widget.joinInfo.attendee.attendeeId}');
    debugPrint('🌍 Media Region: ${widget.joinInfo.meeting.mediaRegion}');

    // Start polling for participant states
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
                Navigator.of(context).pop();
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
    final bloc = context.read<VideoCallBloc>();
    final state = bloc.state;

    if (state.meetingId.isNotEmpty) {
      bloc.add(const EndVideoCall());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ending call...'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
    }

    Navigator.of(context).pop();
  }

  Future<void> _toggleScreenShare(BuildContext context) async {
    final bloc = context.read<VideoCallBloc>();
    final state = bloc.state;

    try {
      if (!state.isScreenSharing) {
        final success = await _screenShareService.startScreenShare(
          meetingId: widget.joinInfo.meeting.meetingId,
          userName: widget.joinInfo.attendee.attendeeId,
        );
        if (success) {
          bloc.add(const SetScreenShareEnabled(true));
          _showFeedback(context, 'Screen sharing started', Colors.blue);
        } else {
          _showFeedback(
            context,
            'Could not get screen sharing permission4',
            Colors.orange,
          );
        }
      } else {
        await _screenShareService.stopScreenShare();
        bloc.add(const SetScreenShareEnabled(false));
        _showFeedback(context, 'Screen sharing stopped', Colors.orange);
      }
    } catch (e) {
      debugPrint('Error toggling screen share: $e');
      _showFeedback(
        context,
        'Failed to ${state.isScreenSharing ? 'stop' : 'start'} screen sharing',
        Colors.red,
      );
    }
  }

  void _showFeedback(BuildContext context, String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: color,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Meeting controls header
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
                          const Text(
                            'Video Call',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Meeting: ${widget.joinInfo.meeting.meetingId.substring(0, 8)}...',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Screen share button
                    BlocBuilder<VideoCallBloc, VideoCallState>(
                      builder: (context, state) {
                        return IconButton(
                          icon: Icon(
                            state.isScreenSharing
                                ? Icons.stop_screen_share
                                : Icons.screen_share,
                            color: state.isScreenSharing
                                ? Colors.blue
                                : Colors.white,
                          ),
                          onPressed: () => _toggleScreenShare(context),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.call_end, color: Colors.red),
                      onPressed: _endCall,
                    ),
                  ],
                ),
              ),
              // Meeting view
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: MeetingView(widget.joinInfo),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
