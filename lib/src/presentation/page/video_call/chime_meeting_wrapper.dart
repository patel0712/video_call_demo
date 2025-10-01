import 'package:flutter/material.dart';
import 'package:flutter_aws_chime/models/join_info.model.dart';
import 'package:flutter_aws_chime/views/meeting.view.dart';

/// Wrapper widget for AWS Chime MeetingView
/// This renders the video call interface using the AWS Chime SDK
class ChimeMeetingWrapper extends StatelessWidget {
  final JoinInfo joinInfo;

  const ChimeMeetingWrapper({required this.joinInfo, super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🎥 Rendering ChimeMeetingWrapper with JoinInfo');
    debugPrint('� Meeting ID: ${joinInfo.toJson()['Meeting']?['MeetingId']}');

    // MeetingView handles all the video calling UI and functionality
    return MeetingView(joinInfo);
  }
}
