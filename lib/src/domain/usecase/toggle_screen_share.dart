import 'package:dartz/dartz.dart';
import 'package:bloc_clean_architecture/src/comman/failure.dart';
import 'package:bloc_clean_architecture/src/domain/repositories/video_call_repository.dart';
import 'package:bloc_clean_architecture/src/services/screen_share_service.dart';

class ToggleScreenShare {
  final VideoCallRepository repository;
  final ScreenShareService _screenShareService;

  ToggleScreenShare(this.repository)
      : _screenShareService = ScreenShareService();

  Future<Either<Failure, void>> call(bool enable) async {
    try {
      if (enable) {
        final success = await _screenShareService.startScreenShare();
        if (!success) {
          return const Left(ServerFailure('Failed to start screen sharing'));
        }
      } else {
        await _screenShareService.stopScreenShare();
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
