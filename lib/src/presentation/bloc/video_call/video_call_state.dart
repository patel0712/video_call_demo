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
    );
  }
}
