import 'package:bloc_clean_architecture/src/comman/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_aws_chime/models/join_info.model.dart';

abstract class VideoCallRemoteDataSource {
  Future<void> initialize();

  Future<JoinInfo> joinMeeting({
    required String meetingId,
    required String participantName,
  });

  Future<void> leaveMeeting();

  Future<void> toggleAudio({required bool enable});

  Future<void> toggleVideo({required bool enable});

  Future<void> toggleScreenShare({required bool enable});
}

class ChimeVideoCallRemoteDataSource implements VideoCallRemoteDataSource {
  ChimeVideoCallRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<void> initialize() async {
    // AWS Chime SDK initialization if required
    debugPrint('Initializing AWS Chime SDK...');
  }

  @override
  Future<JoinInfo> joinMeeting({
    required String meetingId,
    required String participantName,
  }) async {
    final baseUrl = ApiConstants.awsChimeLocalhost;

    try {
      debugPrint(
        'Joining meeting: $meetingId with participant: $participantName',
      );

      final response = await _dio.post<dynamic>(
        '$baseUrl/join',
        data: {
          'meetingId': meetingId,
          'name': participantName,
          // Add any additional parameters your backend expects
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      debugPrint("Raw API response =====> ${response.data}");

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        debugPrint("Raw API response =====> ${response.data}");

        if (response.statusCode == 200 &&
            response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          final meeting = data['Meeting'] as Map<String, dynamic>;
          final attendee = data['Attendee'] as Map<String, dynamic>;

          final joinInfo = JoinInfo(
            MeetingInfo.fromJson({
              'MeetingId': meeting['MeetingId'],
              'ExternalMeetingId': meeting['ExternalMeetingId'],
              'MediaRegion': meeting['MediaRegion'],
              'MediaPlacement': {
                "AudioFallbackUrl":
                    meeting['MediaPlacement']['AudioFallbackUrl'],
                "AudioHostUrl": meeting['MediaPlacement']['AudioHostUrl'],
                "EventIngestionUrl":
                    meeting['MediaPlacement']['EventIngestionUrl'],
                "ScreenDataUrl": meeting['MediaPlacement']['ScreenDataUrl'],
                "ScreenSharingUrl":
                    meeting['MediaPlacement']['ScreenSharingUrl'],
                "ScreenViewingUrl":
                    meeting['MediaPlacement']['ScreenViewingUrl'],
                "SignalingUrl": meeting['MediaPlacement']['SignalingUrl'],
                "TurnControlUrl": meeting['MediaPlacement']['TurnControlUrl'],
              },
            }),
            AttendeeInfo.fromJson({
              "AttendeeId": attendee['AttendeeId'],
              "ExternalUserId": attendee['ExternalUserId'],
              "JoinToken": attendee['JoinToken'],
            }),
          );

          return joinInfo;
        } else {
          throw Exception("Failed to join meeting: ${response.statusCode}");
        }
      }

      throw Exception(
        'Failed to fetch JoinInfo (status: ${response.statusCode})',
      );
    } on DioException catch (e) {
      debugPrint("Dio Error =======> ${e.message}");
      debugPrint("Error Response =======> ${e.response?.data}");
      throw Exception('Network error: ${e.message}');
    } on Exception catch (e, s) {
      debugPrint("Error =======> $e\nStackTrace =======> $s");
      throw Exception('Failed to join meeting: $e');
    }
  }

  @override
  Future<void> leaveMeeting() async {
    try {
      debugPrint('Leaving meeting...');
      // Implement leave meeting logic here
      // This might involve calling your backend to clean up the meeting
      await Future<void>.delayed(const Duration(milliseconds: 500));
      debugPrint('Successfully left meeting');
    } catch (e) {
      debugPrint('Error leaving meeting: $e');
      throw Exception('Failed to leave meeting: $e');
    }
  }

  @override
  Future<void> toggleAudio({required bool enable}) async {
    try {
      debugPrint('Toggling audio: ${enable ? "ON" : "OFF"}');
      // AWS Chime SDK handles audio toggling internally in the MeetingView
      // You can implement additional logic here if needed
    } catch (e) {
      debugPrint('Error toggling audio: $e');
      throw Exception('Failed to toggle audio: $e');
    }
  }

  @override
  Future<void> toggleVideo({required bool enable}) async {
    try {
      debugPrint('Toggling video: ${enable ? "ON" : "OFF"}');
      // AWS Chime SDK handles video toggling internally in the MeetingView
      // You can implement additional logic here if needed
    } catch (e) {
      debugPrint('Error toggling video: $e');
      throw Exception('Failed to toggle video: $e');
    }
  }

  @override
  Future<void> toggleScreenShare({required bool enable}) async {
    try {
      debugPrint('Toggling screen share: ${enable ? "ON" : "OFF"}');
      // AWS Chime SDK handles screen sharing internally in the MeetingView
      // You can implement additional logic here if needed
    } catch (e) {
      debugPrint('Error toggling screen share: $e');
      throw Exception('Failed to toggle screen share: $e');
    }
  }
}
