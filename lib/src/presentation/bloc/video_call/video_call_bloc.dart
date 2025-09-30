import 'package:bloc_clean_architecture/src/comman/enum.dart';
import 'package:bloc_clean_architecture/src/domain/usecase/video_call_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'video_call_event.dart';
part 'video_call_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  VideoCallBloc(
    this._initialize,
    this._join,
    this._leave,
    this._toggleAudio,
    this._toggleVideo,
    this._toggleScreenShare,
  ) : super(VideoCallState.initial()) {
    on<InitializeVideo>((event, emit) async {
      emit(state.copyWith(state: RequestState.loading));
      final r = await _initialize.call();
      r.fold(
        (f) =>
            emit(state.copyWith(state: RequestState.error, message: f.message)),
        (_) => emit(state.copyWith(state: RequestState.loaded)),
      );
    });

    on<JoinVideoCall>((event, emit) async {
      // ignore: avoid_print
      print('🔄 JoinVideoCall event started');
      emit(
        state.copyWith(
          state: RequestState.loading,
          meetingId: event.meetingId,
          participantName: event.participantName,
        ),
      );
      // ignore: avoid_print
      print(
        '📤 Calling join usecase with meetingId: ${event.meetingId}, participant: ${event.participantName}',
      );
      final r = await _join.call(
        meetingId: event.meetingId,
        participantName: event.participantName,
      );
      r.fold(
        (f) {
          // ignore: avoid_print
          print('❌ JoinVideoCall failed: ${f.message}');
          emit(state.copyWith(state: RequestState.error, message: f.message));
        },
        (joinInfo) {
          // ignore: avoid_print
          print(
            '✅ JoinVideoCall success! JoinInfo received: ${joinInfo.runtimeType}',
          );
          // ignore: avoid_print
          print('📄 JoinInfo details: ${joinInfo.toString()}');
          emit(
            state.copyWith(
              state: RequestState.loaded,
              isConnected: true,
              joinInfo: joinInfo,
            ),
          );
          // ignore: avoid_print
          print(
            '🏁 VideoCall state updated - isConnected: true, joinInfo type: ${joinInfo.runtimeType}',
          );
        },
      );
    });

    on<LeaveVideoCall>((event, emit) async {
      emit(state.copyWith(state: RequestState.loading));
      final r = await _leave.call();
      r.fold(
        (f) =>
            emit(state.copyWith(state: RequestState.error, message: f.message)),
        (_) => emit(VideoCallState.initial()),
      );
    });

    on<SetAudioEnabled>((event, emit) async {
      emit(state.copyWith(isAudioEnabled: event.enable));
      await _toggleAudio.call(event.enable);
    });

    on<SetVideoEnabled>((event, emit) async {
      emit(state.copyWith(isVideoEnabled: event.enable));
      await _toggleVideo.call(event.enable);
    });

    on<SetScreenShareEnabled>((event, emit) async {
      emit(state.copyWith(isScreenSharing: event.enable));
      await _toggleScreenShare.call(event.enable);
    });
  }

  final InitializeVideoCall _initialize;
  final JoinMeeting _join;
  final LeaveMeeting _leave;
  final ToggleAudio _toggleAudio;
  final ToggleVideo _toggleVideo;
  final ToggleScreenShare _toggleScreenShare;
}
