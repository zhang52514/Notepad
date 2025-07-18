import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/utils/themeUtil.dart';
import 'package:notepad/controller/ChatController.dart';
import 'package:notepad/controller/RtcController.dart';
import 'package:notepad/views/chat/Components/VideoCall/VideoStreamWidget.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

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
      builder: (context, rtcCallController, _) {
        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor:
                ThemeUtil.isDarkMode(context) ? null : Color(0xFFE6E6E9),
            title: Text(_getCallStatusText(rtcCallController, widget.isCaller)),
            actions: _buildActionButtons(rtcCallController),
            flexibleSpace: const DragToMoveArea(child: SizedBox.expand()),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient:
                  ThemeUtil.isDarkMode(context)
                      ? null
                      : LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFE6E6E9), // 开始颜色 灰色
                          Color(0xFFEAE6DB), // 结束颜色 米色
                        ],
                      ),
            ),
            child:
                rtcCallController.noResponse
                    ? CallNotConnected()
                    : Stack(
                      children: [
                        Positioned.fill(
                          child: _buildMainVideo(rtcCallController),
                        ),
                        Positioned(
                          top: 40.0,
                          right: 20.0,
                          width: 100.0,
                          height: 150.0,
                          child: GestureDetector(
                            onTap:
                                () => rtcCallController.setSwapped(
                                  !rtcCallController.isSwapped,
                                ),
                            child: AspectRatio(
                              aspectRatio: 0.7,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white, // 边框颜色
                                    width: 2.0, // 边框宽度
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    6.0,
                                  ), // 注意要比 Container 的圆角稍小
                                  child: _buildLocalVideo(rtcCallController),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }

  Widget _buildMainVideo(RtcCallController rtcCallController) {
    if (rtcCallController.isSwapped &&
        rtcCallController.localRenderer.srcObject != null) {
      return VideoStreamWidget(
        renderer: rtcCallController.localRenderer,
        mirror: !rtcCallController.isScreenSharing,
        isSwapped: rtcCallController.isSwapped,
      );
    }

    if (!rtcCallController.isSwapped &&
        rtcCallController.remoteRenderer.srcObject != null) {
      return VideoStreamWidget(
        renderer: rtcCallController.remoteRenderer,
        mirror: rtcCallController.isSwapped,
        isSwapped: rtcCallController.isSwapped,
      );
    }

    return _buildStatusText(rtcCallController, widget.isCaller);
  }

  Widget _buildLocalVideo(RtcCallController rtcCallController) {
    if (!rtcCallController.isSwapped &&
        rtcCallController.localRenderer.srcObject != null) {
      return VideoStreamWidget(
        renderer: rtcCallController.localRenderer,
        mirror: !rtcCallController.isScreenSharing,
        isSwapped: rtcCallController.isSwapped,
      );
    }

    if (rtcCallController.isSwapped &&
        rtcCallController.remoteRenderer.srcObject != null) {
      return VideoStreamWidget(
        renderer: rtcCallController.remoteRenderer,
        mirror: rtcCallController.isSwapped,
        isSwapped: rtcCallController.isSwapped,
      );
    }

    return _buildStatusText(rtcCallController, widget.isCaller);
  }

  Widget _buildStatusText(RtcCallController rtcCallController, bool isCaller) {
    return Center(
      child: Text(
        rtcCallController.isConnected
            ? '正在连接远程视频...'
            : _getCallStatusText(rtcCallController, isCaller),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  // 辅助函数：根据状态获取呼叫文本
  String _getCallStatusText(
    RtcCallController rtcCallController,
    bool isCaller,
  ) {
    if (rtcCallController.inCalling && rtcCallController.isConnected) {
      return "通话中${_formatDuration(rtcCallController.callDuration)}";
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

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  List<Widget> _buildActionButtons(RtcCallController rtcCallController) {
    return [
      if (!rtcCallController.isScreenSharing)
        IconButton(
          tooltip: "切换摄像头",
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedCameraRotated01,
            size: 20,
          ),
          onPressed: rtcCallController.switchCamera,
        ),
      IconButton(
        tooltip: rtcCallController.isCameraOff ? "打开摄像头" : "关闭摄像头",
        icon: HugeIcon(
          icon:
              rtcCallController.isCameraOff
                  ? HugeIcons.strokeRoundedVideoOff
                  : HugeIcons.strokeRoundedVideo01,
          size: 20,
        ),
        onPressed: rtcCallController.toggleCamera,
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
        onPressed: rtcCallController.toggleMic,
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
        onPressed:
            rtcCallController.isScreenSharing
                ? rtcCallController.stopScreenShare
                : rtcCallController.startScreenShare,
      ),
      const SizedBox(width: 10),
      FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: () {
          Provider.of<ChatController>(context, listen: false).sendVideoHangup();
        },
        label: const Text('挂断', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.call_end_rounded, color: Colors.white, size: 18),
      ),
      const SizedBox(width: 10),
    ];
  }

  Widget CallNotConnected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 电话挂断图标（假设你有一个图标库，比如 icons: Icons.phone_callback_rounded 或 Icons.call_end）
          HugeIcon(
            icon: HugeIcons.strokeRoundedCallBlocked, // 示例图标，你可以选择更合适的
            size: 80,
            color: Colors.grey[400], // 柔和的灰色
          ),
          SizedBox(height: 20),
          Text(
            "对方无应答，结束通话",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700], // 深一点的灰色，显得稳重
            ),
          ),
          SizedBox(height: 10),
          Text(
            "请稍后重试，或稍后再联系TA。",
            style: TextStyle(fontSize: 18, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
