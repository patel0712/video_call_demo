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
    this._endMeeting,
    this._clearMeetingCache,
    this._toggleAudio,
    this._toggleVideo,
    this._toggleScreenShare,
    this._getParticipantStates,
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

          // Extract attendee ID from joinInfo
          String? attendeeId;
          attendeeId = joinInfo.attendee.attendeeId;

          emit(
            state.copyWith(
              state: RequestState.loaded,
              isConnected: true,
              joinInfo: joinInfo,
              attendeeId: attendeeId,
            ),
          );
          // ignore: avoid_print
          print(
            '🏁 VideoCall state updated - isConnected: true, attendeeId: $attendeeId',
          );

          // Fetch initial participant states after joining
          add(const FetchParticipantStates());
        },
      );
    });

    on<LeaveVideoCall>((event, emit) async {
      emit(state.copyWith(state: RequestState.loading));

      if (state.meetingId.isNotEmpty && state.attendeeId != null) {
        final r = await _leave.call(
          meetingId: state.meetingId,
          attendeeId: state.attendeeId!,
        );
        r.fold(
          (f) => emit(
              state.copyWith(state: RequestState.error, message: f.message)),
          (_) => emit(VideoCallState.initial()),
        );
      } else {
        emit(VideoCallState.initial());
      }
    });

    on<EndVideoCall>((event, emit) async {
      emit(state.copyWith(state: RequestState.loading));

      if (state.meetingId.isNotEmpty) {
        final r = await _endMeeting.call(meetingId: state.meetingId);
        r.fold(
          (f) => emit(
              state.copyWith(state: RequestState.error, message: f.message)),
          (_) => emit(VideoCallState.initial()),
        );
      } else {
        emit(VideoCallState.initial());
      }
    });

    on<ClearMeetingCacheEvent>((event, emit) async {
      emit(state.copyWith(state: RequestState.loading));

      final r = await _clearMeetingCache.call(meetingId: event.meetingId);
      r.fold(
        (f) =>
            emit(state.copyWith(state: RequestState.error, message: f.message)),
        (_) => emit(state.copyWith(state: RequestState.loaded)),
      );
    });

    on<SetAudioEnabled>((event, emit) async {
      emit(state.copyWith(isAudioEnabled: event.enable));

      if (state.meetingId.isNotEmpty && state.attendeeId != null) {
        await _toggleAudio.call(
          meetingId: state.meetingId,
          attendeeId: state.attendeeId!,
          enable: event.enable,
        );
      }
    });

    on<SetVideoEnabled>((event, emit) async {
      emit(state.copyWith(isVideoEnabled: event.enable));

      if (state.meetingId.isNotEmpty && state.attendeeId != null) {
        await _toggleVideo.call(
          meetingId: state.meetingId,
          attendeeId: state.attendeeId!,
          enable: event.enable,
        );
      }
    });

    on<SetScreenShareEnabled>((event, emit) async {
      emit(state.copyWith(isScreenSharing: event.enable));
      await _toggleScreenShare.call(event.enable);
    });

    on<FetchParticipantStates>((event, emit) async {
      if (state.meetingId.isNotEmpty) {
        final r = await _getParticipantStates.call(meetingId: state.meetingId);
        r.fold(
          (f) {
            // ignore: avoid_print
            print('❌ Failed to fetch participant states: ${f.message}');
          },
          (participantData) {
            // ignore: avoid_print
            print('✅ Fetched participant states: $participantData');

            // Update participant states in the state
            final participants =
                participantData['participants'] as Map<String, dynamic>? ?? {};
            final participantCount =
                participantData['participantCount'] as int? ?? 0;

            emit(state.copyWith(
              participantStates: participants,
            ));

            // ignore: avoid_print
            print(
                '📊 Updated participant states: $participants (count: $participantCount)');
          },
        );
      }
    });

    on<AttendeeJoined>((event, emit) async {
      // ignore: avoid_print
      print(
          '👤 Attendee joined: ${event.attendeeId} (${event.externalUserId})');

      // Update participant states
      final updatedStates = Map<String, dynamic>.from(state.participantStates);
      updatedStates[event.attendeeId] = {
        'externalUserId': event.externalUserId,
        'audioEnabled': true,
        'videoEnabled': true,
        'joinedAt': DateTime.now().toIso8601String(),
      };

      emit(state.copyWith(participantStates: updatedStates));

      // Trigger a fetch to get updated participant count
      add(const FetchParticipantStates());
    });

    on<AttendeeLeft>((event, emit) async {
      // ignore: avoid_print
      print('👋 Attendee left: ${event.attendeeId} (${event.externalUserId})');

      // Remove participant from states
      final updatedStates = Map<String, dynamic>.from(state.participantStates);
      updatedStates.remove(event.attendeeId);

      emit(state.copyWith(participantStates: updatedStates));

      // Trigger a fetch to get updated participant count
      add(const FetchParticipantStates());
    });

    on<VideoTileAdded>((event, emit) async {
      // ignore: avoid_print
      print(
          '📹 Video tile added: ${event.attendeeId} (tile: ${event.tileId}, local: ${event.isLocal})');

      // Update participant state with video tile info
      final updatedStates = Map<String, dynamic>.from(state.participantStates);
      if (updatedStates.containsKey(event.attendeeId)) {
        final participantState = Map<String, dynamic>.from(
            updatedStates[event.attendeeId] as Map<String, dynamic>);
        participantState['hasVideoTile'] = true;
        participantState['tileId'] = event.tileId;
        participantState['isLocal'] = event.isLocal;
        participantState['isScreenShare'] = event.isScreenShare;
        updatedStates[event.attendeeId] = participantState;

        emit(state.copyWith(participantStates: updatedStates));
      }
    });

    on<VideoTileRemoved>((event, emit) async {
      // ignore: avoid_print
      print(
          '📹 Video tile removed: ${event.attendeeId} (tile: ${event.tileId})');

      // Update participant state to remove video tile info
      final updatedStates = Map<String, dynamic>.from(state.participantStates);
      if (updatedStates.containsKey(event.attendeeId)) {
        final participantState = Map<String, dynamic>.from(
            updatedStates[event.attendeeId] as Map<String, dynamic>);
        participantState['hasVideoTile'] = false;
        participantState.remove('tileId');
        updatedStates[event.attendeeId] = participantState;

        emit(state.copyWith(participantStates: updatedStates));
      }
    });
  }

  final InitializeVideoCall _initialize;
  final JoinMeeting _join;
  final LeaveMeeting _leave;
  final EndMeeting _endMeeting;
  final ClearMeetingCache _clearMeetingCache;
  final ToggleAudio _toggleAudio;
  final ToggleVideo _toggleVideo;
  final ToggleScreenShare _toggleScreenShare;
  final GetParticipantStates _getParticipantStates;
}
