// video_call_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:notepad/controller/RtcController.dart';
import 'package:provider/provider.dart'; // 引入 Provider

class VideoCallPage extends StatefulWidget {
  final bool isCaller; // 判断是主叫还是被叫

  const VideoCallPage({Key? key, required this.isCaller}) : super(key: key);

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  @override
  void initState() {
    super.initState();
    // // 在页面初始化时，RTCCallController 应该已经被提供并通过 Provider 访问
    // // 确保本地视频流的显示
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final rtcCallController = Provider.of<RtcCallController>(context, listen: false);
    //   if (rtcCallController.localRenderer.srcObject == null) {
    //     rtcCallController.startLocalStream();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Consumer 来监听 RTCCallController 的变化，重建UI
    return Consumer<RtcCallController>(
      builder: (context, rtcCallController, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 远程视频流 (大窗口显示对方)
              Positioned.fill(
                child: RTCVideoView(
                  rtcCallController.remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
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
                    child: RTCVideoView(
                      rtcCallController.localRenderer,
                      mirror: true, // 镜像显示本地视频，更符合用户预期
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ),
              ),
              // 控制按钮 (挂断、麦克风、摄像头)
              Positioned(
                bottom: 20.0,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      heroTag: "hangup",
                      onPressed: () {
                        // 发送挂断信令给对方
                        // 这里需要你的ChatService或类似的服务来发送挂断消息
                        // 假设你有一个方法 sendVideoHangup
                        // Provider.of<ChatService>(context, listen: false).sendVideoHangup(targetUserId);
                        rtcCallController.hangUp(); // 本地清理
                        Navigator.pop(context); // 挂断后返回
                      },
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.call_end),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 20.0,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    // 根据 isCaller 判断显示不同的文本
                    widget.isCaller ? "正在呼叫..." : "通话中", // 或者更复杂的逻辑判断通话是否已连接
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
}
