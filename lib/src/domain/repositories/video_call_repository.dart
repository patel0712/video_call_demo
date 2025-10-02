import 'package:dartz/dartz.dart';
import 'package:bloc_clean_architecture/src/comman/failure.dart';
import 'package:flutter_aws_chime/models/join_info.model.dart';

abstract class VideoCallRepository {
  Future<Either<Failure, void>> initialize();
  Future<Either<Failure, JoinInfo>> joinMeeting({
    required String meetingId,
    required String participantName,
  });
  Future<Either<Failure, void>> leaveMeeting({
    required String meetingId,
    required String attendeeId,
  });
  Future<Either<Failure, void>> endMeeting({required String meetingId});
  Future<Either<Failure, void>> toggleAudio({
    required String meetingId,
    required String attendeeId,
    required bool enable,
  });
  Future<Either<Failure, void>> toggleVideo({
    required String meetingId,
    required String attendeeId,
    required bool enable,
  });
  Future<Either<Failure, void>> toggleScreenShare({required bool enable});
  Future<Either<Failure, Map<String, dynamic>>> getParticipantStates({
    required String meetingId,
  });
  Future<Either<Failure, void>> clearMeetingCache({required String meetingId});
}
