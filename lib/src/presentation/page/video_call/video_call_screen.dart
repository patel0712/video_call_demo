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
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;
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
      final meetingId =
          (_meetingIdController.text.isNotEmpty
                  ? _meetingIdController.text
                  : (widget.meetingId ?? 'demo-meeting-id'))
              .trim();
      final name =
          (_nameController.text.isNotEmpty
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

  void _toggleVideo() {
    context.read<VideoCallBloc>().add(SetVideoEnabled(!_isVideoEnabled));
  }

  void _toggleAudio() {
    context.read<VideoCallBloc>().add(SetAudioEnabled(!_isAudioEnabled));
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isConnected
              ? _leaveMeeting
              : () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isConnected ? 'In Call' : 'Video Call',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isConnected)
            IconButton(
              icon: const Icon(Icons.call_end, color: Colors.red),
              onPressed: _leaveMeeting,
            ),
        ],
      ),
      body: BlocConsumer<VideoCallBloc, VideoCallState>(
        listener: (context, state) {
          setState(() {
            _isConnected = state.isConnected;
            _isAudioEnabled = state.isAudioEnabled;
            _isVideoEnabled = state.isVideoEnabled;
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
              _statusMessage = state.message.isNotEmpty
                  ? state.message
                  : 'Ready to join';
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
          // If connected and we have JoinInfo, render ChimeMeetingWrapper
          if (state.isConnected && state.joinInfo != null) {
            debugPrint('🎬 Rendering ChimeMeetingWrapper with JoinInfo');
            return ChimeMeetingWrapper(joinInfo: state.joinInfo! as JoinInfo);
          }

          debugPrint(
            'VideoCall State: isConnected=${state.isConnected}, hasJoinInfo=${state.joinInfo != null}, state=${state.state}',
          );
          return Column(
            children: [
              // Video area
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[900],
                  child: _isConnected
                      ? Stack(
                          children: [
                            // Remote video (placeholder)
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 100,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    widget.participantName ??
                                        'Remote Participant',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Remote video will appear here',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Local video (placeholder)
                            Positioned(
                              top: 20,
                              right: 20,
                              child: Container(
                                width: 120,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.videocam,
                                      color: _isVideoEnabled
                                          ? Colors.white
                                          : Colors.red,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'You',
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _isVideoEnabled
                                          ? 'Video On'
                                          : 'Video Off',
                                      style: GoogleFonts.roboto(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(
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

                    const SizedBox(height: 16),

                    if (!_isConnected) ...[
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
                          const SizedBox(width: 12),
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
                        if (!_isConnected)
                          _buildControlButton(
                            icon: Icons.call,
                            label: 'Join',
                            backgroundColor: Colors.green,
                            onPressed: _isConnecting ? null : _joinMeeting,
                            isLoading: _isConnecting,
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
                          icon: _isVideoEnabled
                              ? Icons.videocam
                              : Icons.videocam_off,
                          label: _isVideoEnabled ? 'Video' : 'Video Off',
                          backgroundColor: _isVideoEnabled
                              ? Colors.white
                              : Colors.red,
                          iconColor: _isVideoEnabled
                              ? Colors.black
                              : Colors.white,
                          onPressed: _toggleVideo,
                          isEnabled: _isConnected,
                        ),

                        // Audio toggle
                        _buildControlButton(
                          icon: _isAudioEnabled ? Icons.mic : Icons.mic_off,
                          label: _isAudioEnabled ? 'Mic' : 'Mic Off',
                          backgroundColor: _isAudioEnabled
                              ? Colors.white
                              : Colors.red,
                          iconColor: _isAudioEnabled
                              ? Colors.black
                              : Colors.white,
                          onPressed: _toggleAudio,
                          isEnabled: _isConnected,
                        ),

                        // Screen share toggle
                        _buildControlButton(
                          icon: _isScreenSharing
                              ? Icons.stop_screen_share
                              : Icons.screen_share,
                          label: _isScreenSharing ? 'Stop Share' : 'Share',
                          backgroundColor: _isScreenSharing
                              ? Colors.red
                              : Colors.white,
                          iconColor: _isScreenSharing
                              ? Colors.white
                              : Colors.black,
                          onPressed: _toggleScreenShare,
                          isEnabled: _isConnected,
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
