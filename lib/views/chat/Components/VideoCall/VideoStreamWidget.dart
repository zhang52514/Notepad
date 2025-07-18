import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoStreamWidget extends StatelessWidget {
  final RTCVideoRenderer renderer;
  final bool mirror;
  final bool isSwapped;

  const VideoStreamWidget({
    super.key,
    required this.renderer,
    required this.mirror,
    required this.isSwapped,
  });

  @override
  Widget build(BuildContext context) {
    return RTCVideoView(
      renderer,
      mirror: mirror,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    );
  }
}