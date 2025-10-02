import 'package:bloc_clean_architecture/src/comman/failure.dart';
import 'package:bloc_clean_architecture/src/data/datasource/video_call_remote_data_source.dart';
import 'package:bloc_clean_architecture/src/domain/repositories/video_call_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_aws_chime/models/join_info.model.dart';

class VideoCallRepositoryImpl implements VideoCallRepository {
  VideoCallRepositoryImpl(this._remote);

  final VideoCallRemoteDataSource _remote;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      await _remote.initialize();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JoinInfo>> joinMeeting({
    required String meetingId,
    required String participantName,
  }) async {
    try {
      final joinInfo = await _remote.joinMeeting(
        meetingId: meetingId,
        participantName: participantName,
      );
      return Right(joinInfo);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveMeeting({
    required String meetingId,
    required String attendeeId,
  }) async {
    try {
      await _remote.leaveMeeting(
        meetingId: meetingId,
        attendeeId: attendeeId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> endMeeting({required String meetingId}) async {
    try {
      await _remote.endMeeting(meetingId: meetingId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleAudio({
    required String meetingId,
    required String attendeeId,
    required bool enable,
  }) async {
    try {
      await _remote.toggleAudio(
        meetingId: meetingId,
        attendeeId: attendeeId,
        enable: enable,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleVideo({
    required String meetingId,
    required String attendeeId,
    required bool enable,
  }) async {
    try {
      await _remote.toggleVideo(
        meetingId: meetingId,
        attendeeId: attendeeId,
        enable: enable,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleScreenShare({
    required bool enable,
  }) async {
    try {
      await _remote.toggleScreenShare(enable: enable);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getParticipantStates({
    required String meetingId,
  }) async {
    try {
      final states = await _remote.getParticipantStates(meetingId: meetingId);
      return Right(states);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearMeetingCache(
      {required String meetingId}) async {
    try {
      await _remote.clearMeetingCache(meetingId: meetingId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
