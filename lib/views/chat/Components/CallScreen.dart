import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:notepad/controller/ChatController.dart';
import 'package:notepad/controller/RtcController.dart';
import 'package:provider/provider.dart';

// 移除 _sendSignalingMessage，因为它现在由 ChatController 处理

class VideoCallPage extends StatefulWidget {
  final bool isCaller; // 判断是主叫还是被叫 (可根据需要保留，但通话状态应以 RtcCallController 为准)
  final String callTargetId; // 呼叫的目标ID，用于信令传递 (主要用于 ChatController 确定发送对象)

  const VideoCallPage({
    Key? key,
    required this.isCaller,
    required this.callTargetId,
  }) : super(key: key);

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  // 不再需要 late RtcCallController _rtcCallController;
  // 因为我们将直接通过 Consumer 或 Provider.of<RtcCallController>(context) 使用它

  @override
  void initState() {
    super.initState();
    // 在这里不再调用 initCall
    // initCall 应该在 ChatController 中，当发起或接听通话时被调用
    // VideoCallPage 只是一个展示层
  }

  @override
  void dispose() {
    // 页面销毁时，不要在这里直接调用 _rtcCallController.hangUp();
    // 因为挂断操作的信令发送和逻辑清理应由 ChatController 统一处理
    // 例如，在 ChatController 中监听 VideoCallPage 的 pop 事件，或在用户点击挂断按钮时
    // 直接通过 ChatController 发送挂断信令。
    // RtcCallController 的 dispose 会自动清理其内部的 RTCVideoRenderer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Consumer 监听 RtcCallController 的变化，以便实时更新 UI
    return Consumer<RtcCallController>(
      builder: (context, rtcCallController, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 远程视频流 (大窗口显示对方)
              Positioned.fill(
                child: rtcCallController.remoteRenderer.srcObject != null
                    ? RTCVideoView(
                        rtcCallController.remoteRenderer,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : Center(
                        child: Text(
                          // 根据连接状态显示不同的文本
                          rtcCallController.isConnected ? '正在连接远程视频...' : _getCallStatusText(rtcCallController, widget.isCaller),
                          style: const TextStyle(color: Colors.white, fontSize: 20),
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
                    child: rtcCallController.localRenderer.srcObject != null
                        ? RTCVideoView(
                            rtcCallController.localRenderer,
                            mirror: !rtcCallController.isScreenSharing,
                            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          )
                        : Container(
                            color: Colors.grey[800],
                            child: Center(
                              child: Text(
                                rtcCallController.isScreenSharing ? '正在共享屏幕...' : '本地视频未准备好',
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              // 控制按钮 (居中显示)
              Positioned(
                bottom: 20.0,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 挂断按钮
                    FloatingActionButton(
                      heroTag: "hangup",
                      onPressed: () {
                        // **重要：这里应该触发 ChatController 的挂断逻辑**
                        // 因为 ChatController 负责发送挂断信令给对方
                        Provider.of<ChatController>(context, listen: false).sendVideoHangup();
                        // ChatController 的 sendVideoHangup 内部会调用 rtcCallController.hangUp()
                        // 并最终 pop 掉当前页面
                        // 所以这里不需要再 Navigator.pop(context);
                      },
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.call_end),
                    ),
                    // 麦克风开关
                    FloatingActionButton(
                      heroTag: "toggle_mic",
                      onPressed: () => rtcCallController.toggleMic(),
                      backgroundColor: rtcCallController.isMicMuted ? Colors.grey : Colors.blue,
                      child: Icon(
                        rtcCallController.isMicMuted ? Icons.mic_off : Icons.mic,
                      ),
                    ),
                    // 摄像头开关
                    FloatingActionButton(
                      heroTag: "toggle_camera",
                      onPressed: () => rtcCallController.toggleCamera(),
                      backgroundColor: rtcCallController.isCameraOff ? Colors.grey : Colors.blue,
                      child: Icon(
                        rtcCallController.isCameraOff && !rtcCallController.isScreenSharing
                            ? Icons.videocam_off
                            : Icons.videocam,
                      ),
                    ),
                    // 切换摄像头按钮 (仅在未进行屏幕共享时可用)
                    if (!rtcCallController.isScreenSharing)
                      FloatingActionButton(
                        heroTag: "switch_camera",
                        onPressed: () => rtcCallController.switchCamera(),
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.cameraswitch),
                      ),
                    // 屏幕共享按钮
                    FloatingActionButton(
                      heroTag: "toggle_screen_share",
                      onPressed: () {
                        if (rtcCallController.isScreenSharing) {
                          rtcCallController.stopScreenShare();
                        } else {
                          rtcCallController.startScreenShare();
                        }
                      },
                      backgroundColor: rtcCallController.isScreenSharing ? Colors.orange : Colors.blue,
                      child: Icon(
                        rtcCallController.isScreenSharing ? Icons.offline_bolt : Icons.screen_share,
                      ),
                    ),
                  ],
                ),
              ),

              // 呼叫状态文本
              Positioned(
                top: 20.0,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    _getCallStatusText(rtcCallController, widget.isCaller),
                    style: const TextStyle(color: Colors.white, fontSize: 18.0),
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
  String _getCallStatusText(RtcCallController rtcCallController, bool isCaller) {
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