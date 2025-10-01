part of 'video_call_bloc.dart';

class VideoCallState {
  const VideoCallState({
    required this.state,
    required this.message,
    required this.isConnected,
    required this.isAudioEnabled,
    required this.isVideoEnabled,
    required this.isScreenSharing,
    required this.meetingId,
    required this.participantName,
    this.joinInfo,
    this.selectedAudioDevice,
    this.audioDevices = const [],
    this.localAttendeeId,
    this.remoteAttendeeId,
    this.contentAttendeeId,
    this.attendees = const {},
  });

  factory VideoCallState.initial() => const VideoCallState(
    state: RequestState.empty,
    message: '',
    isConnected: false,
    isAudioEnabled: true,
    isVideoEnabled: true,
    isScreenSharing: false,
    meetingId: '',
    participantName: '',
  );

  final RequestState state;
  final String message;
  final bool isConnected;
  final bool isAudioEnabled;
  final bool isVideoEnabled;
  final bool isScreenSharing;
  final String meetingId;
  final String participantName;
  final Object? joinInfo; // JoinInfo from flutter_aws_chime
  final String? selectedAudioDevice;
  final List<String> audioDevices;
  final String? localAttendeeId;
  final String? remoteAttendeeId;
  final String? contentAttendeeId;
  final Map<String, dynamic> attendees;

  VideoCallState copyWith({
    RequestState? state,
    String? message,
    bool? isConnected,
    bool? isAudioEnabled,
    bool? isVideoEnabled,
    bool? isScreenSharing,
    String? meetingId,
    String? participantName,
    Object? joinInfo,
    String? selectedAudioDevice,
    List<String>? audioDevices,
    String? localAttendeeId,
    String? remoteAttendeeId,
    String? contentAttendeeId,
    Map<String, dynamic>? attendees,
  }) {
    return VideoCallState(
      state: state ?? this.state,
      message: message ?? this.message,
      isConnected: isConnected ?? this.isConnected,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      meetingId: meetingId ?? this.meetingId,
      participantName: participantName ?? this.participantName,
      joinInfo: joinInfo ?? this.joinInfo,
      selectedAudioDevice: selectedAudioDevice ?? this.selectedAudioDevice,
      audioDevices: audioDevices ?? this.audioDevices,
      localAttendeeId: localAttendeeId ?? this.localAttendeeId,
      remoteAttendeeId: remoteAttendeeId ?? this.remoteAttendeeId,
      contentAttendeeId: contentAttendeeId ?? this.contentAttendeeId,
      attendees: attendees ?? this.attendees,
    );
  }
}
