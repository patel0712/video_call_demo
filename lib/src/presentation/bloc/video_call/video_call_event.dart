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

class EndVideoCall extends VideoCallEvent {
  const EndVideoCall();
}

class ClearMeetingCacheEvent extends VideoCallEvent {
  const ClearMeetingCacheEvent({required this.meetingId});
  final String meetingId;
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

// AWS Chime specific events
class UpdateAudioDevice extends VideoCallEvent {
  const UpdateAudioDevice(this.deviceName);
  final String deviceName;
}

class ListAudioDevices extends VideoCallEvent {
  const ListAudioDevices();
}

class AttendeeJoined extends VideoCallEvent {
  const AttendeeJoined({
    required this.attendeeId,
    required this.externalUserId,
  });
  final String attendeeId;
  final String externalUserId;
}

class AttendeeLeft extends VideoCallEvent {
  const AttendeeLeft({
    required this.attendeeId,
    required this.externalUserId,
    this.didDrop = false,
  });
  final String attendeeId;
  final String externalUserId;
  final bool didDrop;
}

class VideoTileAdded extends VideoCallEvent {
  const VideoTileAdded({
    required this.attendeeId,
    required this.tileId,
    required this.isLocal,
    required this.isScreenShare,
  });
  final String attendeeId;
  final int tileId;
  final bool isLocal;
  final bool isScreenShare;
}

class VideoTileRemoved extends VideoCallEvent {
  const VideoTileRemoved({required this.attendeeId, required this.tileId});
  final String attendeeId;
  final int tileId;
}

class FetchParticipantStates extends VideoCallEvent {
  const FetchParticipantStates();
}
