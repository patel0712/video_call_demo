import 'dart:convert';

import 'package:flutter_aws_chime/models/join_info.model.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ChimeApiService {
  final String _baseUrl = ApiConfig.apiUrl;
  final String _region = ApiConfig.region;

  Future<ApiResponse> join({
    required String meetingId,
    required String attendeeId,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/join?title=$meetingId&name=$attendeeId&region=$_region',
    );

    try {
      final response = await http.post(url);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final joinInfoMap = jsonDecode(response.body);
        final joinInfo = JoinInfo.fromJson(joinInfoMap as Map<String, dynamic>);
        return ApiResponse(success: true, joinInfo: joinInfo);
      } else {
        throw Exception('Failed to join meeting: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Map<String, dynamic> joinInfoToJson(JoinInfo info) {
    return {
      'MeetingId': info.meeting.meetingId,
      'ExternalMeetingId': info.meeting.externalMeetingId,
      'MediaRegion': info.meeting.mediaRegion,
      'AudioHostUrl': info.meeting.mediaPlacement.audioHostUrl,
      'AudioFallbackUrl': info.meeting.mediaPlacement.audioFallbackUrl,
      'SignalingUrl': info.meeting.mediaPlacement.signalingUrl,
      'TurnControlUrl': info.meeting.mediaPlacement.turnControllerUrl,
      'ExternalUserId': info.attendee.externalUserId,
      'AttendeeId': info.attendee.attendeeId,
      'JoinToken': info.attendee.joinToken,
    };
  }
}

class ApiResponse {
  final bool success;
  final JoinInfo? joinInfo;
  final String? error;

  ApiResponse({required this.success, this.joinInfo, this.error});
}
