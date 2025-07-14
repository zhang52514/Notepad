import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// 视频通话弹窗组件
class VideoCallDialog extends StatelessWidget {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final VoidCallback onHangUp;

  const VideoCallDialog({
    super.key,
    required this.localRenderer,
    required this.remoteRenderer,
    required this.onHangUp,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Stack(
          children: [
            // 远程视频
            RTCVideoView(
              remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),

            // 本地视频（小窗口）
            Positioned(
              right: 12,
              top: 12,
              width: 120,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: RTCVideoView(
                  localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),

            // 挂断按钮
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onHangUp();
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
