import 'package:flutter/foundation.dart';
import 'package:flutter_aws_chime/models/join_info.model.dart';

class ChimeApiResponse {
  final Meeting meeting;
  final Attendee attendee;

  ChimeApiResponse({required this.meeting, required this.attendee});

  factory ChimeApiResponse.fromJson(Map<String, dynamic> json) {
    return ChimeApiResponse(
      meeting: Meeting.fromJson(json['Meeting'] as Map<String, dynamic>),
      attendee: Attendee.fromJson(json['Attendee'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'Meeting': meeting.toJson(), 'Attendee': attendee.toJson()};
  }

  // Convert to JoinInfo for the AWS Chime SDK
  JoinInfo toJoinInfo() {
    try {
      // Create the JSON structure that AWS Chime SDK expects
      final joinInfoJson = {
        'meeting': {
          'MeetingId': meeting.meetingId,
          'ExternalMeetingId': meeting.externalMeetingId,
          'MediaRegion': meeting.mediaRegion,
          'MediaPlacement': {
            'AudioHostUrl': meeting.mediaPlacement.audioHostUrl,
            'AudioFallbackUrl': meeting.mediaPlacement.audioFallbackUrl,
            'SignalingUrl': meeting.mediaPlacement.signalingUrl,
            'TurnControlUrl': meeting.mediaPlacement.turnControlUrl,
            'ScreenDataUrl': meeting.mediaPlacement.screenDataUrl,
            'ScreenViewingUrl': meeting.mediaPlacement.screenViewingUrl,
            'ScreenSharingUrl': meeting.mediaPlacement.screenSharingUrl,
            'EventIngestionUrl': meeting.mediaPlacement.eventIngestionUrl,
          },
        },
        'attendee': {
          'ExternalUserId': attendee.externalUserId,
          'AttendeeId': attendee.attendeeId,
          'JoinToken': attendee.joinToken,
          'Capabilities': {
            'Audio': attendee.capabilities.audio,
            'Video': attendee.capabilities.video,
            'Content': attendee.capabilities.content,
          },
        },
      };

      debugPrint('📄 Creating JoinInfo with JSON: $joinInfoJson');
      debugPrint('🔍 meeting (lowercase): ${joinInfoJson['meeting']}');
      debugPrint('🔍 attendee (lowercase): ${joinInfoJson['attendee']}');
      debugPrint(
        '🔍 Capabilities: ${joinInfoJson['attendee']!['Capabilities']}',
      );

      return JoinInfo.fromJson(joinInfoJson);
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating JoinInfo: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      debugPrint(
        '🔍 Meeting data: meetingId=${meeting.meetingId}, externalId=${meeting.externalMeetingId}',
      );
      debugPrint(
        '🔍 Attendee data: attendeeId=${attendee.attendeeId}, externalUserId=${attendee.externalUserId}',
      );
      rethrow;
    }
  }
}

class Meeting {
  final String meetingId;
  final String? meetingHostId;
  final String externalMeetingId;
  final String mediaRegion;
  final MediaPlacement mediaPlacement;
  final String? primaryMeetingId;
  final List<String> tenantIds;
  final String meetingArn;

  Meeting({
    required this.meetingId,
    this.meetingHostId,
    required this.externalMeetingId,
    required this.mediaRegion,
    required this.mediaPlacement,
    this.primaryMeetingId,
    required this.tenantIds,
    required this.meetingArn,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      meetingId: json['MeetingId'] as String,
      meetingHostId: json['MeetingHostId'] as String?,
      externalMeetingId: json['ExternalMeetingId'] as String,
      mediaRegion: json['MediaRegion'] as String,
      mediaPlacement: MediaPlacement.fromJson(
        json['MediaPlacement'] as Map<String, dynamic>,
      ),
      primaryMeetingId: json['PrimaryMeetingId'] as String?,
      tenantIds: (json['TenantIds'] as List<dynamic>).cast<String>(),
      meetingArn: json['MeetingArn'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MeetingId': meetingId,
      'MeetingHostId': meetingHostId,
      'ExternalMeetingId': externalMeetingId,
      'MediaRegion': mediaRegion,
      'MediaPlacement': mediaPlacement.toJson(),
      'PrimaryMeetingId': primaryMeetingId,
      'TenantIds': tenantIds,
      'MeetingArn': meetingArn,
    };
  }
}

class MediaPlacement {
  final String audioHostUrl;
  final String audioFallbackUrl;
  final String signalingUrl;
  final String turnControlUrl;
  final String screenDataUrl;
  final String screenViewingUrl;
  final String screenSharingUrl;
  final String eventIngestionUrl;

  MediaPlacement({
    required this.audioHostUrl,
    required this.audioFallbackUrl,
    required this.signalingUrl,
    required this.turnControlUrl,
    required this.screenDataUrl,
    required this.screenViewingUrl,
    required this.screenSharingUrl,
    required this.eventIngestionUrl,
  });

  factory MediaPlacement.fromJson(Map<String, dynamic> json) {
    return MediaPlacement(
      audioHostUrl: json['AudioHostUrl'] as String,
      audioFallbackUrl: json['AudioFallbackUrl'] as String,
      signalingUrl: json['SignalingUrl'] as String,
      turnControlUrl: json['TurnControlUrl'] as String,
      screenDataUrl: json['ScreenDataUrl'] as String,
      screenViewingUrl: json['ScreenViewingUrl'] as String,
      screenSharingUrl: json['ScreenSharingUrl'] as String,
      eventIngestionUrl: json['EventIngestionUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AudioHostUrl': audioHostUrl,
      'AudioFallbackUrl': audioFallbackUrl,
      'SignalingUrl': signalingUrl,
      'TurnControlUrl': turnControlUrl,
      'ScreenDataUrl': screenDataUrl,
      'ScreenViewingUrl': screenViewingUrl,
      'ScreenSharingUrl': screenSharingUrl,
      'EventIngestionUrl': eventIngestionUrl,
    };
  }
}

class Attendee {
  final String externalUserId;
  final String attendeeId;
  final String joinToken;
  final Capabilities capabilities;

  Attendee({
    required this.externalUserId,
    required this.attendeeId,
    required this.joinToken,
    required this.capabilities,
  });

  factory Attendee.fromJson(Map<String, dynamic> json) {
    // AWS Chime SDK may not always return Capabilities, so provide defaults
    final capabilitiesJson = json['Capabilities'] as Map<String, dynamic>?;

    return Attendee(
      externalUserId: json['ExternalUserId'] as String,
      attendeeId: json['AttendeeId'] as String,
      joinToken: json['JoinToken'] as String,
      capabilities: capabilitiesJson != null
          ? Capabilities.fromJson(capabilitiesJson)
          : Capabilities(
              audio: 'SendReceive',
              video: 'SendReceive',
              content: 'SendReceive',
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ExternalUserId': externalUserId,
      'AttendeeId': attendeeId,
      'JoinToken': joinToken,
      'Capabilities': capabilities.toJson(),
    };
  }
}

class Capabilities {
  final String audio;
  final String video;
  final String content;

  Capabilities({
    required this.audio,
    required this.video,
    required this.content,
  });

  factory Capabilities.fromJson(Map<String, dynamic> json) {
    return Capabilities(
      audio: json['Audio'] as String,
      video: json['Video'] as String,
      content: json['Content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'Audio': audio, 'Video': video, 'Content': content};
  }
}
