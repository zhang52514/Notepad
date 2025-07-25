import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/utils/themeUtil.dart';
import 'package:notepad/controller/ChatController.dart';
import 'package:notepad/controller/RtcController.dart';
import 'package:notepad/views/chat/Components/VideoCall/VideoStreamWidget.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class VideoCallPage extends StatefulWidget {
  final bool isCaller;
  final String callTargetId;

  const VideoCallPage({
    super.key,
    required this.isCaller,
    required this.callTargetId,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _controlsVisible = true;
  
  @override
  void initState() {
    super.initState();
    
    // 脉冲动画控制器（用于等待连接时的呼吸效果）
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // 淡入淡出控制器（用于控制栏的显示隐藏）
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: 1.0,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    // 开始脉冲动画
    _pulseController.repeat(reverse: true);
    
    // 3秒后自动隐藏控制栏
    _startHideControlsTimer();
  }
  
  void _startHideControlsTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _controlsVisible) {
        _hideControls();
      }
    });
  }
  
  void _showControls() {
    setState(() => _controlsVisible = true);
    _fadeController.forward();
    _startHideControlsTimer();
  }
  
  void _hideControls() {
    _fadeController.reverse().then((_) {
      if (mounted) {
        setState(() => _controlsVisible = false);
      }
    });
  }
  
  void _toggleControls() {
    if (_controlsVisible) {
      _hideControls();
    } else {
      _showControls();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RtcCallController>(
      builder: (context, rtcController, _) {
        // 停止脉冲动画当连接建立时
        if (rtcController.isConnected && _pulseController.isAnimating) {
          _pulseController.stop();
          _pulseController.reset();
        } else if (!rtcController.isConnected && !_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        }
        
        return Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: _controlsVisible ? _buildAppBar(rtcController) : null,
          body: GestureDetector(
            onTap: _toggleControls,
            child: Stack(
              children: [
                // 主视频区域
                Positioned.fill(
                  child: _buildMainVideoArea(rtcController),
                ),
                
                // 小窗口视频
                if (rtcController.isConnected)
                  _buildPictureInPicture(rtcController),
                
                // 底部控制栏
                if (_controlsVisible)
                  _buildBottomControls(rtcController),
                
                // 连接状态指示器
                if (!rtcController.isConnected)
                  _buildConnectionStatus(rtcController),
                
                // 网络质量指示器
                if (rtcController.isConnected)
                  _buildNetworkQualityIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(RtcCallController rtcController) {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.3),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.minimize, color: Colors.white),
        onPressed: () => WindowManager.instance.minimize(),
      ),
      title: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getCallStatusText(rtcController),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (rtcController.isConnected)
                  Text(
                    _formatDuration(rtcController.callDuration),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      centerTitle: true,
      flexibleSpace: const DragToMoveArea(child: SizedBox.expand()),
    );
  }

  Widget _buildMainVideoArea(RtcCallController rtcController) {
    if (rtcController.noResponse) {
      return _buildNoResponseUI();
    }

    Widget mainVideo;
    
    if (rtcController.isSwapped) {
      // 显示本地视频为主视频
      mainVideo = rtcController.localRenderer.srcObject != null
          ? VideoStreamWidget(
              renderer: rtcController.localRenderer,
              mirror: !rtcController.isScreenSharing,
              isSwapped: true,
            )
          : _buildVideoPlaceholder("本地视频");
    } else {
      // 显示远程视频为主视频
      mainVideo = rtcController.remoteRenderer.srcObject != null
          ? VideoStreamWidget(
              renderer: rtcController.remoteRenderer,
              mirror: false,
              isSwapped: false,
            )
          : _buildVideoPlaceholder("远程视频");
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a1a1a),
            Color(0xFF000000),
          ],
        ),
      ),
      child: mainVideo,
    );
  }

  Widget _buildPictureInPicture(RtcCallController rtcController) {
    return Positioned(
      top: 60,
      right: 20,
      child: GestureDetector(
        onTap: () => rtcController.setSwapped(!rtcController.isSwapped),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildSmallVideo(rtcController),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallVideo(RtcCallController rtcController) {
    if (rtcController.isSwapped) {
      // 小窗口显示远程视频
      return rtcController.remoteRenderer.srcObject != null
          ? VideoStreamWidget(
              renderer: rtcController.remoteRenderer,
              mirror: false,
              isSwapped: true,
            )
          : _buildVideoPlaceholder("远程", small: true);
    } else {
      // 小窗口显示本地视频
      return rtcController.localRenderer.srcObject != null
          ? VideoStreamWidget(
              renderer: rtcController.localRenderer,
              mirror: !rtcController.isScreenSharing,
              isSwapped: false,
            )
          : _buildVideoPlaceholder("本地", small: true);
    }
  }

  Widget _buildVideoPlaceholder(String label, {bool small = false}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off,
            size: small ? 24 : 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: small ? 10 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(RtcCallController rtcController) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: rtcController.isMicMuted
                        ? HugeIcons.strokeRoundedMicOff01
                        : HugeIcons.strokeRoundedMic01,
                    label: rtcController.isMicMuted ? "取消静音" : "静音",
                    onPressed: rtcController.toggleMic,
                    isActive: !rtcController.isMicMuted,
                  ),
                  _buildControlButton(
                    icon: rtcController.isCameraOff
                        ? HugeIcons.strokeRoundedVideoOff
                        : HugeIcons.strokeRoundedVideo01,
                    label: rtcController.isCameraOff ? "打开摄像头" : "关闭摄像头",
                    onPressed: rtcController.toggleCamera,
                    isActive: !rtcController.isCameraOff,
                  ),
                  if (!rtcController.isScreenSharing)
                    _buildControlButton(
                      icon: HugeIcons.strokeRoundedCameraRotated01,
                      label: "切换摄像头",
                      onPressed: rtcController.switchCamera,
                      isActive: true,
                    ),
                  _buildControlButton(
                    icon: rtcController.isScreenSharing
                        ? HugeIcons.strokeRoundedComputerRemove
                        : HugeIcons.strokeRoundedComputerScreenShare,
                    label: rtcController.isScreenSharing ? "停止共享" : "共享屏幕",
                    onPressed: rtcController.isScreenSharing
                        ? rtcController.stopScreenShare
                        : rtcController.startScreenShare,
                    isActive: rtcController.isScreenSharing,
                  ),
                  _buildHangupButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive 
                ? Colors.white.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            border: Border.all(
              color: isActive ? Colors.white : Colors.red,
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: HugeIcon(
              icon: icon,
              color: isActive ? Colors.white : Colors.red,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHangupButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          child: IconButton(
            onPressed: () {
              Provider.of<ChatController>(context, listen: false)
                  .sendVideoHangup();
            },
            icon: const Icon(
              Icons.call_end_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "挂断",
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionStatus(RtcCallController rtcController) {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.3),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            _getCallStatusText(rtcController),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.callTargetId,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkQualityIndicator() {
    return Positioned(
      top: 60,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              "网络良好",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResponseUI() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedCallBlocked,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 30),
          const Text(
            "对方无应答",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "通话将在 3 秒后自动结束",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _getCallStatusText(RtcCallController rtcController) {
    if (rtcController.noResponse) {
      return "对方无应答";
    } else if (rtcController.isConnected) {
      return "通话中";
    } else if (widget.isCaller) {
      return "正在呼叫...";
    } else {
      return "连接中...";
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return "${hours.toString().padLeft(2, '0')}:"
             "${minutes.toString().padLeft(2, '0')}:"
             "${seconds.toString().padLeft(2, '0')}";
    } else {
      return "${minutes.toString().padLeft(2, '0')}:"
             "${seconds.toString().padLeft(2, '0')}";
    }
  }
}