import 'dart:math';
import 'package:bloc_clean_architecture/src/comman/enum.dart';
import 'package:bloc_clean_architecture/src/presentation/bloc/video_call/video_call_bloc.dart';
import 'package:bloc_clean_architecture/src/presentation/page/video_call/chime_meeting_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_aws_chime/models/join_info.model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallScreen extends StatefulWidget {
  final String? meetingId;
  final String? participantName;

  const VideoCallScreen({super.key, this.meetingId, this.participantName});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  // Local state variables maintained for app bar and other UI elements
  bool _isScreenSharing = false;
  bool _isConnected = false;
  bool _isConnecting = false;
  String _statusMessage = 'Ready to join';

  final TextEditingController _meetingIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // AWS Chime controller (placeholder - actual implementation would depend on the SDK)
  // late FlutterAwsChimeController _chimeController;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _meetingIdController.text = widget.meetingId ?? '';
    _nameController.text = widget.participantName ?? '';
  }

  @override
  void dispose() {
    _meetingIdController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _generateUUID() {
    // Generate a proper UUID v4 format
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Create a more random UUID-like string
    final part1 = (timestamp & 0xffffffff).toRadixString(16).padLeft(8, '0');
    final part2 = random.nextInt(0xffff).toRadixString(16).padLeft(4, '0');
    final part3 = (0x4000 | (random.nextInt(0x1000))).toRadixString(
      16,
    ); // Version 4
    final part4 = (0x8000 | (random.nextInt(0x4000))).toRadixString(
      16,
    ); // Variant bits
    final part5 =
        random.nextInt(0xffffffffffff).toRadixString(16).padLeft(12, '0');

    return '$part1-$part2-$part3-$part4-$part5';
  }

  Future<void> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      setState(() {
        _statusMessage = 'Permissions granted';
      });
    } else {
      setState(() {
        _statusMessage = 'Permissions required for video calling';
      });
    }
  }

  Future<void> _joinMeeting() async {
    if (!_isConnecting) {
      // Generate a UUID if no meeting ID is provided
      String meetingId = _meetingIdController.text.isNotEmpty
          ? _meetingIdController.text.trim()
          : (widget.meetingId ?? _generateUUID()).trim();
      final name = (_nameController.text.isNotEmpty
              ? _nameController.text
              : (widget.participantName ?? 'Guest'))
          .trim();

      // Show connecting status
      setState(() {
        _isConnecting = true;
        _statusMessage = 'Connecting to meeting...';
      });

      context.read<VideoCallBloc>().add(
            JoinVideoCall(meetingId: meetingId, participantName: name),
          );
    }
  }

  Future<void> _leaveMeeting() async {
    context.read<VideoCallBloc>().add(const LeaveVideoCall());

    setState(() {
      _isConnected = false;
      _isScreenSharing = false;
      _statusMessage = 'Left meeting';
      _isConnecting = false;
    });

    Navigator.of(context).pop();
  }

  Future<void> _generateNewMeeting() async {
    // Generate a new unique meeting ID
    final newMeetingId = 'meeting-${DateTime.now().millisecondsSinceEpoch}';

    // Clear any existing meeting cache for the old meeting ID
    if (_meetingIdController.text.isNotEmpty) {
      try {
        context.read<VideoCallBloc>().add(
              ClearMeetingCacheEvent(meetingId: _meetingIdController.text),
            );
      } catch (e) {
        debugPrint('Error clearing meeting cache: $e');
      }
    }

    _meetingIdController.text = newMeetingId;

    setState(() {
      _statusMessage = 'New meeting ID generated';
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New meeting ID: $newMeetingId'),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _toggleVideo() {
    final currentState = context.read<VideoCallBloc>().state;
    if (currentState.isConnected && currentState.attendeeId != null) {
      context.read<VideoCallBloc>().add(
            SetVideoEnabled(!currentState.isVideoEnabled),
          );

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !currentState.isVideoEnabled ? 'Video enabled' : 'Video disabled',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor:
              !currentState.isVideoEnabled ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  void _toggleAudio() {
    final currentState = context.read<VideoCallBloc>().state;
    if (currentState.isConnected && currentState.attendeeId != null) {
      context.read<VideoCallBloc>().add(
            SetAudioEnabled(!currentState.isAudioEnabled),
          );

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !currentState.isAudioEnabled ? 'Audio enabled' : 'Audio disabled',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor:
              !currentState.isAudioEnabled ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  void _toggleScreenShare() {
    context.read<VideoCallBloc>().add(SetScreenShareEnabled(!_isScreenSharing));
  }

  void _showAudioDeviceDialog() async {
    final state = context.read<VideoCallBloc>().state;
    final String? device = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Choose Audio Device"),
        children: state.audioDevices.map((device) {
          final isSelected = device == state.selectedAudioDevice;
          return SimpleDialogOption(
            child: Text(
              device,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onPressed: () {
              Navigator.pop(context, device);
              context.read<VideoCallBloc>().add(UpdateAudioDevice(device));
            },
          );
        }).toList(),
      ),
    );

    if (device == null) {
      debugPrint("No device chosen.");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<VideoCallBloc, VideoCallState>(
        listener: (context, state) {
          setState(() {
            _isConnected = state.isConnected;
            _isScreenSharing = state.isScreenSharing;
            _isConnecting = state.state == RequestState.loading;

            // Update status message based on state
            if (state.state == RequestState.error) {
              _statusMessage = 'Error: ${state.message}';
            } else if (state.state == RequestState.loading) {
              _statusMessage = 'Connecting...';
            } else if (state.isConnected) {
              _statusMessage = 'Connected to meeting';
            } else {
              _statusMessage =
                  state.message.isNotEmpty ? state.message : 'Ready to join';
            }
          });

          // Show error snackbar if there's an error
          if (state.state == RequestState.error && state.message.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        builder: (context, state) {
          debugPrint(
            '🔄 VideoCall Builder - isConnected: ${state.isConnected}, hasJoinInfo: ${state.joinInfo != null}, state: ${state.state}',
          );

          // If connected and we have JoinInfo, render ChimeMeetingWrapper
          if (state.isConnected && state.joinInfo != null) {
            debugPrint('🎬 Rendering ChimeMeetingWrapper with JoinInfo');
            debugPrint('📋 JoinInfo type: ${state.joinInfo.runtimeType}');
            debugPrint('📋 JoinInfo details: ${state.joinInfo.toString()}');

            final joinInfo = state.joinInfo;
            debugPrint('🎬 Rendering ChimeMeetingWrapper with JoinInfo');
            debugPrint('📋 JoinInfo type: ${joinInfo.runtimeType}');
            debugPrint('📋 JoinInfo details: $joinInfo');

            if (joinInfo is JoinInfo) {
              return ChimeMeetingWrapper(joinInfo: joinInfo);
            }
          }

          debugPrint('📱 Rendering pre-join UI');
          return Column(
            children: [
              // Video area
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[900],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam,
                          size: 80,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Ready to start video call',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _statusMessage,
                          style: GoogleFonts.roboto(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        if (widget.meetingId != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Meeting ID: ${widget.meetingId ?? state.meetingId}',
                            style: GoogleFonts.roboto(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Control panel
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.black,
                child: Column(
                  children: [
                    // Status bar
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _statusMessage,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Participant status indicator (only show when connected)
                    if (state.isConnected) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Participants: ${state.participantStates.length}/2',
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Show audio/video status for current user
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      state.isAudioEnabled
                                          ? Icons.mic
                                          : Icons.mic_off,
                                      color: state.isAudioEnabled
                                          ? Colors.green
                                          : Colors.red,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      state.isVideoEnabled
                                          ? Icons.videocam
                                          : Icons.videocam_off,
                                      color: state.isVideoEnabled
                                          ? Colors.green
                                          : Colors.red,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Show other participants
                            if (state.participantStates.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                children: state.participantStates.entries.map((
                                  entry,
                                ) {
                                  final attendeeId = entry.key;
                                  final participantData =
                                      entry.value as Map<String, dynamic>? ??
                                          {};
                                  final externalUserId =
                                      participantData['externalUserId']
                                              as String? ??
                                          'Unknown';
                                  final audioEnabled =
                                      participantData['audioEnabled']
                                              as bool? ??
                                          true;
                                  final videoEnabled =
                                      participantData['videoEnabled']
                                              as bool? ??
                                          true;
                                  final isLocal =
                                      attendeeId == state.attendeeId;

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLocal
                                          ? Colors.blue[800]
                                          : Colors.grey[700],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          isLocal ? 'You' : externalUserId,
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          audioEnabled
                                              ? Icons.mic
                                              : Icons.mic_off,
                                          color: audioEnabled
                                              ? Colors.green
                                              : Colors.red,
                                          size: 10,
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(
                                          videoEnabled
                                              ? Icons.videocam
                                              : Icons.videocam_off,
                                          color: videoEnabled
                                              ? Colors.green
                                              : Colors.red,
                                          size: 10,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    if (!state.isConnected) ...[
                      // Pre-join inputs
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _meetingIdController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[850],
                                hintText: 'Meeting ID',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            onPressed: _generateNewMeeting,
                            tooltip: 'Generate New Meeting ID',
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[850],
                                hintText: 'Your name',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Join/Leave button
                        if (!state.isConnected)
                          _buildControlButton(
                            icon: Icons.call,
                            label: 'Join',
                            backgroundColor: Colors.green,
                            onPressed: state.state == RequestState.loading
                                ? null
                                : _joinMeeting,
                            isLoading: state.state == RequestState.loading,
                          )
                        else
                          _buildControlButton(
                            icon: Icons.call_end,
                            label: 'Leave',
                            backgroundColor: Colors.red,
                            onPressed: _leaveMeeting,
                          ),

                        // Video toggle
                        _buildControlButton(
                          icon: state.isVideoEnabled
                              ? Icons.videocam
                              : Icons.videocam_off,
                          label: state.isVideoEnabled ? 'Video' : 'Video Off',
                          backgroundColor:
                              state.isVideoEnabled ? Colors.white : Colors.red,
                          iconColor: state.isVideoEnabled
                              ? Colors.black
                              : Colors.white,
                          onPressed: state.isConnected ? _toggleVideo : null,
                          isEnabled: state.isConnected,
                        ),

                        // Audio toggle
                        _buildControlButton(
                          icon:
                              state.isAudioEnabled ? Icons.mic : Icons.mic_off,
                          label: state.isAudioEnabled ? 'Mic' : 'Mic Off',
                          backgroundColor:
                              state.isAudioEnabled ? Colors.white : Colors.red,
                          iconColor: state.isAudioEnabled
                              ? Colors.black
                              : Colors.white,
                          onPressed: state.isConnected ? _toggleAudio : null,
                          isEnabled: state.isConnected,
                        ),

                        // Screen share toggle
                        _buildControlButton(
                          icon: state.isScreenSharing
                              ? Icons.stop_screen_share
                              : Icons.screen_share,
                          label: state.isScreenSharing ? 'Stop Share' : 'Share',
                          backgroundColor:
                              state.isScreenSharing ? Colors.red : Colors.white,
                          iconColor: state.isScreenSharing
                              ? Colors.white
                              : Colors.black,
                          onPressed: _toggleScreenShare,
                          isEnabled: state.isConnected,
                        ),

                        // Audio device selection
                        _buildControlButton(
                          icon: Icons.settings_voice,
                          label: 'Audio',
                          backgroundColor: Colors.white,
                          iconColor: Colors.black,
                          onPressed: _showAudioDeviceDialog,
                          isEnabled: _isConnected,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    Color iconColor = Colors.white,
    required VoidCallback? onPressed,
    bool isEnabled = true,
    bool isLoading = false,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isEnabled ? backgroundColor : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(icon, color: iconColor, size: 24),
                  onPressed: isEnabled ? onPressed : null,
                ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.roboto(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
