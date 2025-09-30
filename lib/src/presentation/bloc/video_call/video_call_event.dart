part of 'video_call_bloc.dart';

abstract class VideoCallEvent {
  const VideoCallEvent();
}

class InitializeVideo extends VideoCallEvent {
  const InitializeVideo();
}

class JoinVideoCall extends VideoCallEvent {
  const JoinVideoCall({required this.meetingId, required this.participantName});
  final String meetingId;
  final String participantName;
}

class LeaveVideoCall extends VideoCallEvent {
  const LeaveVideoCall();
}

class SetAudioEnabled extends VideoCallEvent {
  const SetAudioEnabled(this.enable);
  final bool enable;
}

class SetVideoEnabled extends VideoCallEvent {
  const SetVideoEnabled(this.enable);
  final bool enable;
}

class SetScreenShareEnabled extends VideoCallEvent {
  const SetScreenShareEnabled(this.enable);
  final bool enable;
}
