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

  Future<void> leaveMeeting({
    required String meetingId,
    required String attendeeId,
  });

  Future<void> endMeeting({required String meetingId});

  Future<void> toggleAudio({
    required String meetingId,
    required String attendeeId,
    required bool enable,
  });

  Future<void> toggleVideo({
    required String meetingId,
    required String attendeeId,
    required bool enable,
  });

  Future<void> toggleScreenShare({required bool enable});

  Future<Map<String, dynamic>> getParticipantStates({
    required String meetingId,
  });

  Future<void> clearMeetingCache({required String meetingId});
}

class ChimeVideoCallRemoteDataSource implements VideoCallRemoteDataSource {
  ChimeVideoCallRemoteDataSource(this._dio);

  final Dio _dio;

  // Store current meeting and attendee info for API calls
  String? _currentMeetingId;
  String? _currentAttendeeId;

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
                "AudioFallbackUrl": meeting['MediaPlacement']
                    ['AudioFallbackUrl'],
                "AudioHostUrl": meeting['MediaPlacement']['AudioHostUrl'],
                "EventIngestionUrl": meeting['MediaPlacement']
                    ['EventIngestionUrl'],
                "ScreenDataUrl": meeting['MediaPlacement']['ScreenDataUrl'],
                "ScreenSharingUrl": meeting['MediaPlacement']
                    ['ScreenSharingUrl'],
                "ScreenViewingUrl": meeting['MediaPlacement']
                    ['ScreenViewingUrl'],
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

          // Store meeting and attendee IDs for future API calls
          _currentMeetingId = meeting['ExternalMeetingId'] as String?;
          _currentAttendeeId = attendee['AttendeeId'] as String?;

          debugPrint('Stored meeting ID: $_currentMeetingId');
          debugPrint('Stored attendee ID: $_currentAttendeeId');

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
  Future<void> leaveMeeting({
    required String meetingId,
    required String attendeeId,
  }) async {
    final baseUrl = ApiConstants.awsChimeLocalhost;

    try {
      debugPrint('Leaving meeting: $meetingId, attendee: $attendeeId');

      final response = await _dio.post<dynamic>(
        '$baseUrl/leave',
        data: {
          'meetingId': meetingId,
          'attendeeId': attendeeId,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('Successfully left meeting');
        // Clear stored IDs
        _currentMeetingId = null;
        _currentAttendeeId = null;
      } else {
        throw Exception('Failed to leave meeting: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint("Dio Error leaving meeting: ${e.message}");
      debugPrint("Error Response: ${e.response?.data}");
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error leaving meeting: $e');
      throw Exception('Failed to leave meeting: $e');
    }
  }

  @override
  Future<void> endMeeting({required String meetingId}) async {
    final baseUrl = ApiConstants.awsChimeLocalhost;

    try {
      debugPrint('Ending meeting: $meetingId');

      final response = await _dio.post<dynamic>(
        '$baseUrl/end',
        data: {
          'meetingId': meetingId,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('Successfully ended meeting');
        // Clear stored IDs
        _currentMeetingId = null;
        _currentAttendeeId = null;
      } else {
        throw Exception('Failed to end meeting: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint("Dio Error ending meeting: ${e.message}");
      debugPrint("Error Response: ${e.response?.data}");
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error ending meeting: $e');
      throw Exception('Failed to end meeting: $e');
    }
  }

  @override
  Future<void> toggleAudio({
    required String meetingId,
    required String attendeeId,
    required bool enable,
  }) async {
    final baseUrl = ApiConstants.awsChimeLocalhost;

    try {
      debugPrint(
          'Toggling audio: ${enable ? "ON" : "OFF"} for meeting: $meetingId, attendee: $attendeeId');

      final response = await _dio.post<dynamic>(
        '$baseUrl/audio/toggle',
        data: {
          'meetingId': meetingId,
          'attendeeId': attendeeId,
          'audioEnabled': enable,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('Successfully toggled audio: $enable');
      } else {
        throw Exception('Failed to toggle audio: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint("Dio Error toggling audio: ${e.message}");
      debugPrint("Error Response: ${e.response?.data}");
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error toggling audio: $e');
      throw Exception('Failed to toggle audio: $e');
    }
  }

  @override
  Future<void> toggleVideo({
    required String meetingId,
    required String attendeeId,
    required bool enable,
  }) async {
    final baseUrl = ApiConstants.awsChimeLocalhost;

    try {
      debugPrint(
          'Toggling video: ${enable ? "ON" : "OFF"} for meeting: $meetingId, attendee: $attendeeId');

      final response = await _dio.post<dynamic>(
        '$baseUrl/video/toggle',
        data: {
          'meetingId': meetingId,
          'attendeeId': attendeeId,
          'videoEnabled': enable,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('Successfully toggled video: $enable');
      } else {
        throw Exception('Failed to toggle video: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint("Dio Error toggling video: ${e.message}");
      debugPrint("Error Response: ${e.response?.data}");
      throw Exception('Network error: ${e.message}');
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

  @override
  Future<Map<String, dynamic>> getParticipantStates({
    required String meetingId,
  }) async {
    final baseUrl = ApiConstants.awsChimeLocalhost;

    try {
      debugPrint('Getting participant states for meeting: $meetingId');

      final response = await _dio.get<dynamic>(
        '$baseUrl/participants/$meetingId',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('Successfully retrieved participant states');
        return data;
      } else {
        throw Exception(
            'Failed to get participant states: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint("Dio Error getting participant states: ${e.message}");
      debugPrint("Error Response: ${e.response?.data}");
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error getting participant states: $e');
      throw Exception('Failed to get participant states: $e');
    }
  }

  @override
  Future<void> clearMeetingCache({required String meetingId}) async {
    final baseUrl = ApiConstants.awsChimeLocalhost;

    try {
      debugPrint('Clearing meeting cache for: $meetingId');

      final response = await _dio.post<dynamic>(
        '$baseUrl/clear-cache',
        data: {
          'meetingId': meetingId,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('Successfully cleared meeting cache');
        // Clear stored IDs
        _currentMeetingId = null;
        _currentAttendeeId = null;
      } else {
        throw Exception(
            'Failed to clear meeting cache: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint("Dio Error clearing meeting cache: ${e.message}");
      debugPrint("Error Response: ${e.response?.data}");
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error clearing meeting cache: $e');
      throw Exception('Failed to clear meeting cache: $e');
    }
  }

  // Helper methods to get current meeting and attendee IDs
  String? get currentMeetingId => _currentMeetingId;
  String? get currentAttendeeId => _currentAttendeeId;
}
