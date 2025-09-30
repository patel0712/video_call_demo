import 'package:dartz/dartz.dart';
import 'package:bloc_clean_architecture/src/comman/failure.dart';
import 'package:bloc_clean_architecture/src/domain/repositories/video_call_repository.dart';
import 'package:flutter_aws_chime/models/join_info.model.dart';

class InitializeVideoCall {
  InitializeVideoCall(this._repo);
  final VideoCallRepository _repo;
  Future<Either<Failure, void>> call() => _repo.initialize();
}

class JoinMeeting {
  JoinMeeting(this._repo);
  final VideoCallRepository _repo;
  Future<Either<Failure, JoinInfo>> call({
    required String meetingId,
    required String participantName,
  }) =>
      _repo.joinMeeting(meetingId: meetingId, participantName: participantName);
}

class LeaveMeeting {
  LeaveMeeting(this._repo);
  final VideoCallRepository _repo;
  Future<Either<Failure, void>> call() => _repo.leaveMeeting();
}

class ToggleAudio {
  ToggleAudio(this._repo);
  final VideoCallRepository _repo;
  Future<Either<Failure, void>> call(bool enable) =>
      _repo.toggleAudio(enable: enable);
}

class ToggleVideo {
  ToggleVideo(this._repo);
  final VideoCallRepository _repo;
  Future<Either<Failure, void>> call(bool enable) =>
      _repo.toggleVideo(enable: enable);
}

class ToggleScreenShare {
  ToggleScreenShare(this._repo);
  final VideoCallRepository _repo;
  Future<Either<Failure, void>> call(bool enable) =>
      _repo.toggleScreenShare(enable: enable);
}
