import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/controller/ChatController.dart';
import 'package:notepad/controller/RtcController.dart';
import 'package:provider/provider.dart';

// 移除 _sendSignalingMessage，因为它现在由 ChatController 处理
class VideoCallPage extends StatefulWidget {
  final bool isCaller; // 判断是主叫还是被叫 (可根据需要保留，但通话状态应以 RtcCallController 为准)
  final String callTargetId; // 呼叫的目标ID，用于信令传递 (主要用于 ChatController 确定发送对象)

  const VideoCallPage({
    super.key,
    required this.isCaller,
    required this.callTargetId,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RtcCallController>(
      builder: (context, rtcCallController, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_getCallStatusText(rtcCallController, widget.isCaller)),
            actions: [
              // 切换摄像头按钮 (仅在未进行屏幕共享时可用)
              if (!rtcCallController.isScreenSharing)
                IconButton(
                  tooltip: "切换摄像头",
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCameraRotated01,
                    // 如果摄像头关闭且不是屏幕共享状态，显示关闭图标
                    size: 20,
                  ),
                  onPressed: () => rtcCallController.switchCamera(),
                ),

              IconButton(
                tooltip: rtcCallController.isCameraOff ? "打开摄像头" : "关闭摄像头",
                icon: HugeIcon(
                  icon:
                      rtcCallController.isCameraOff &&
                              !rtcCallController.isScreenSharing
                          ? HugeIcons.strokeRoundedVideoOff
                          : HugeIcons.strokeRoundedVideo01,
                  size: 20,
                ),
                onPressed: () => rtcCallController.toggleCamera(),
              ),
              IconButton(
                tooltip: rtcCallController.isMicMuted ? "取消静音" : "静音",
                icon: HugeIcon(
                  icon:
                      rtcCallController.isMicMuted
                          ? HugeIcons.strokeRoundedMicOff01
                          : HugeIcons.strokeRoundedMic01,
                  size: 20,
                ),
                onPressed: () => rtcCallController.toggleMic(),
              ),
              IconButton(
                tooltip: rtcCallController.isScreenSharing ? "停止共享屏幕" : "共享屏幕",
                icon: HugeIcon(
                  icon:
                      rtcCallController.isScreenSharing
                          ? HugeIcons.strokeRoundedComputerRemove
                          : HugeIcons.strokeRoundedComputerScreenShare,
                  size: 20,
                ),
                onPressed: () {
                  if (rtcCallController.isScreenSharing) {
                    rtcCallController.stopScreenShare();
                  } else {
                    rtcCallController.startScreenShare();
                  }
                },
              ),
                SizedBox(width: 10), // 添加间距
              // 挂断按钮
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ), // 缩小内边距
                  minimumSize: const Size(0, 36), // 设置更小的最小高度（默认是 40+）
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 去掉点击区域额外扩张
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6), // 圆角小一点
                  ),
                ),
                onPressed: () {
                  Provider.of<ChatController>(
                    context,
                    listen: false,
                  ).sendVideoHangup();
                },
                label: const Text('挂断', style: TextStyle(color: Colors.white)),
                icon: const Icon(
                  Icons.call_end_rounded,
                  color: Colors.white,
                  size: 18, // 图标也可以略缩小
                ),
              ),
              SizedBox(width: 10), // 添加间距
            ],
          ),
          body: Stack(
            children: [
              // 远程视频流 (大窗口显示对方)
              Positioned.fill(
                child:
                    rtcCallController.remoteRenderer.srcObject != null
                        ? RTCVideoView(
                          rtcCallController.remoteRenderer,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                        : Center(
                          child: Text(
                            // 根据连接状态显示不同的文本
                            rtcCallController.isConnected
                                ? '正在连接远程视频...'
                                : _getCallStatusText(
                                  rtcCallController,
                                  widget.isCaller,
                                ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
              ),

              // 本地视频流 (小窗口显示自己)
              Positioned(
                top: 40.0,
                right: 20.0,
                width: 100.0,
                height: 150.0,
                child: AspectRatio(
                  aspectRatio: 0.7, // 保持视频比例
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child:
                        rtcCallController.localRenderer.srcObject != null
                            ? RTCVideoView(
                              rtcCallController.localRenderer,
                              mirror: !rtcCallController.isScreenSharing,
                              objectFit:
                                  RTCVideoViewObjectFit
                                      .RTCVideoViewObjectFitCover,
                            )
                            : Container(
                              color: Colors.grey[800],
                              child: Center(
                                child: Text(
                                  rtcCallController.isScreenSharing
                                      ? '正在共享屏幕...'
                                      : '本地视频未准备好',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 辅助函数：根据状态获取呼叫文本
  String _getCallStatusText(
    RtcCallController rtcCallController,
    bool isCaller,
  ) {
    if (rtcCallController.inCalling && rtcCallController.isConnected) {
      return "通话中";
    } else if (rtcCallController.inCalling && isCaller) {
      // isCaller 更多是初始状态的标记
      return "正在呼叫...";
    } else if (rtcCallController.inCalling && !isCaller) {
      // !isCaller 更多是初始状态的标记
      return "等待接听..."; // 被叫方等待接听
    } else {
      return "连接中..."; // 例如，PeerConnection 尚未完全建立
    }
  }
}
