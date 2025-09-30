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
  Future<Either<Failure, void>> leaveMeeting() async {
    try {
      await _remote.leaveMeeting();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleAudio({required bool enable}) async {
    try {
      await _remote.toggleAudio(enable: enable);
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
  Future<Either<Failure, void>> toggleVideo({required bool enable}) async {
    try {
      await _remote.toggleVideo(enable: enable);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
