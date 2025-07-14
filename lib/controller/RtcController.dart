import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:notepad/core/SimpleFileLogger.dart';

typedef SignalSender = Function(Map<String, dynamic> signal);

/// WebRTC 模型控制器，用于处理视频通话、媒体流初始化、ICE候选、屏幕共享等逻辑。
/// 配合 Provider 使用，自动通知 UI 更新状态。
class RtcCallController extends ChangeNotifier {
  void _debugLog(String label, [String? value]) {
    final timestamp = DateTime.now().toIso8601String();
    SimpleFileLogger.log('[WebRTC][$timestamp] $label ${value ?? ''}');
  }

  bool _inCalling = false;
  bool get inCalling => _inCalling;

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer(); // 本地视频渲染器
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer(); // 远程视频渲染器
  RTCPeerConnection? _peerConnection; // WebRTC peer 对象
  MediaStream? _localStream; // 本地音视频流
  MediaStreamTrack? _screenTrack; // 屏幕共享轨道（预留）
  Timer? _screenCaptureTimer; // 屏幕共享定时截图任务

  // ICE 服务器配置，用于穿透 NAT
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'}, // Google 的公共 STUN 服务器
      // 如果需要 TURN 服务器，可以在这里添加
    ],
  };

  // 外部只读访问渲染器，用于 RTCVideoView 显示
  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  // 当前连接是否建立成功
  bool get isConnected =>
      _peerConnection?.connectionState ==
      RTCPeerConnectionState.RTCPeerConnectionStateConnected;

  // 是否接收到远程流
  bool get hasRemoteStream => _remoteRenderer.srcObject != null;

  /// 构造函数：初始化视频渲染器，并传入 WebSocketService 和信令发送回调
  RtcCallController() {
    _initializeRenderers();
  }

  /// 初始化 RTCVideoView 渲染器（UI组件依赖）
  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  /// 销毁控制器（释放资源）
  @override
  void dispose() {
    _cleanUp();
    super.dispose();
  }

  /// 初始化通话流程
  /// - 获取本地音视频流
  /// - 建立 PeerConnection
  /// - （主叫方）创建 Offer
  Future<void> initCall({
    bool isOffer = false,
    required SignalSender onSignalSend,
  }) async {
    SimpleFileLogger.log('[RtcCallController] 初始化呼叫。isOffer: $isOffer');
    await _getUserMedia();
    await _createPeerConnection(onSignalSend);
    if (isOffer) {
      await createOffer(onSignalSend);
    }
    _inCalling = true;
    notifyListeners();
  }

  /// 获取本地音视频流并绑定到本地渲染器
  Future<void> _getUserMedia() async {
    final constraints = {
      'audio': true,
      'video': {'facingMode': 'user'}, // 使用前置摄像头
    };
    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    _localRenderer.srcObject = _localStream;
    notifyListeners(); // 通知 UI 刷新本地视频
  }

  /// 创建 WebRTC peer connection，并绑定事件处理器
  Future<void> _createPeerConnection(SignalSender onSignalSend) async {
    if (_peerConnection != null) {
      SimpleFileLogger.log('[RtcCallController] PeerConnection 已存在，跳过创建。');
      return;
    }

    _peerConnection = await createPeerConnection(_iceServers);
    // _peerConnection = await createPeerConnection({});
    SimpleFileLogger.log('[RtcCallController] PeerConnection 已创建。');

    // 添加本地音视频轨道
    _localStream?.getTracks().forEach((track) {
      track.enabled = true;
      _peerConnection!.addTrack(track, _localStream!);
      _debugLog(
        '🎬 添加本地轨道',
        'kind=${track.kind}, id=${track.id}, enabled=${track.enabled}',
      );
    });

    // 监听 ICE 候选（需要通过信令发送给远端）
    _peerConnection!.onIceCandidate = (candidate) {
      SimpleFileLogger.log('[WebRTC] ICE 候选: ${candidate.toMap()}');
      // 通过信令发送 ICE Candidate
      onSignalSend({
        'type': 'candidate',
        'sdpMid': candidate.sdpMid,
        'sdpMlineIndex': candidate.sdpMLineIndex,
        'candidate': candidate.candidate,
      });
    };

    // // 接收到远程媒体流时绑定到远程渲染器
    // _peerConnection!.onAddStream = (stream) {
    //   SimpleFileLogger.log(
    //     '----- DEBUG: onAddStream callback triggered! Stream ID: ${stream.id}',
    //   ); // 新增的调试日志
    //   SimpleFileLogger.log('[WebRTC] 远程流已接收： ${stream.id}');
    //   _remoteRenderer.srcObject = stream;
    //   notifyListeners(); // 通知 UI 展示远端视频
    // };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'video') {
        _debugLog(
          '📺 onTrack - 收到远程视频轨道',
          'trackId=${event.track.id}, streamId=${event.streams.first.id}',
        );
        _remoteRenderer.srcObject = event.streams.first;
        notifyListeners();
      } else {
        _debugLog('📡 onTrack - 收到非视频轨道', 'kind=${event.track.kind}');
      }
    };

    // 监听连接状态变更
    _peerConnection!.onConnectionState = (state) {
      SimpleFileLogger.log('[WebRTC] 连接状态： $state');
      if ([
        RTCPeerConnectionState.RTCPeerConnectionStateDisconnected,
        RTCPeerConnectionState.RTCPeerConnectionStateFailed,
        RTCPeerConnectionState.RTCPeerConnectionStateClosed,
      ].contains(state)) {
        SimpleFileLogger.log('[WebRTC] PeerConnection 已断开、失败或关闭。挂断.');
        hangUp(); // 连接断开、失败或关闭时自动挂断
      }
      notifyListeners(); // 刷新连接状态 UI
    };

    _peerConnection!.onIceConnectionState = (state) {
      SimpleFileLogger.log('[WebRTC] ICE连接状态：$state');
      notifyListeners();
    };
  }

  /// 创建 Offer（主叫方使用）并设置本地 SDP
  Future<void> createOffer(SignalSender onSignalSend) async {
    if (_peerConnection == null) {
      _debugLog('❌ createOffer - PeerConnection为空');
      return;
    }

    _debugLog('🎥 createOffer - 开始创建 Offer');

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _debugLog('✅ createOffer - SDP 设置成功，类型: ${offer.type}');
    _debugLog('🔼 createOffer - 发送 Offer 信令');
    // 通过信令发送 Offer
    onSignalSend(offer.toMap());
  }

  /// 处理对方发来的 Offer（被叫方）
  Future<void> handleOffer(
    Map<String, dynamic> data,
    SignalSender onSignalSend,
  ) async {
    SimpleFileLogger.log('[WebRTC] 处理传入的 offer： ${data['type']}');
    if (_peerConnection == null) {
      await _createPeerConnection(
        onSignalSend,
      ); // 如果是第一次收到 Offer，需要先创建 PeerConnection
    }
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(data['sdp'], data['type']),
    );
    SimpleFileLogger.log('[WebRTC] 设置远程描述（offer）.');
    await _createAnswer(onSignalSend); // 收到 Offer 后创建并发送 Answer
  }

  /// 创建 Answer 响应 Offer，并设置本地 SDP
  Future<void> _createAnswer(SignalSender onSignalSend) async {
    if (_peerConnection == null) {
      _debugLog('❌ createAnswer - PeerConnection为空');
      return;
    }
    _debugLog('🎥 createAnswer - 开始创建 Answer');
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    _debugLog('✅ createAnswer - SDP 设置成功，类型: ${answer.type}');
    _debugLog('🔼 createAnswer - 发送 Answer 信令');
    // 通过信令发送 Answer
    onSignalSend(answer.toMap());
  }

  /// 处理对方返回的 Answer
  Future<void> handleAnswer(Map<String, dynamic> data) async {
    _debugLog('📥 handleAnswer - 接收 Answer');
    if (_peerConnection == null) {
      _debugLog('❌ handleAnswer - PeerConnection为空');
      return;
    }
    await _peerConnection?.setRemoteDescription(
      RTCSessionDescription(data['sdp'], data['type']),
    );
    _debugLog('✅ handleAnswer - 设置远程 SDP 成功');
  }

  /// 处理接收到的 ICE 候选信息
  Future<void> handleCandidate(Map<String, dynamic> data) async {
    _debugLog('📥 handleCandidate - 接收 ICE 候选');
    if (_peerConnection == null) {
      _debugLog('❌ handleCandidate - PeerConnection为空');
      return;
    }
    final candidate = RTCIceCandidate(
      data['candidate'],
      data['sdpMid'],
      data['sdpMlineIndex'],
    );
    await _peerConnection?.addCandidate(candidate);

    _debugLog('✅ handleCandidate - 添加候选成功');
  }

  /// 统一处理接收到的 WebRTC 信令
  void handleSignal(
    Map<String, dynamic> signalData,
    SignalSender onSignalSend,
  ) {
    SimpleFileLogger.log('[RtcCallController] 接收信号: ${signalData['type']}');
    if (!signalData.containsKey('type')) return;
    switch (signalData['type']) {
      case 'offer':
        handleOffer(signalData, onSignalSend);
        break;
      case 'answer':
        handleAnswer(signalData);
        break;
      case 'candidate':
        handleCandidate(signalData);
        break;
      default:
        SimpleFileLogger.log(
          '[RtcCallController] 未知信号类型: ${signalData['type']}',
        );
    }
  }

  /// 挂断通话：关闭 Peer、清理资源
  void hangUp() {
    SimpleFileLogger.log('[WebRTC] 已发起挂断.');
    _cleanUp();
    _inCalling = false;
    notifyListeners();
  }

  /// 清理 WebRTC 和 UI 状态
  void _cleanUp() {
    _screenCaptureTimer?.cancel();
    _screenCaptureTimer = null;
    _screenTrack?.stop();
    _screenTrack = null;

    _peerConnection?.close();
    _peerConnection = null;

    _localStream?.getTracks().forEach((track) {
      track.stop(); // 停止所有本地媒体轨道
    });
    _localStream?.dispose();
    _localStream = null;

    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;

    // 重新初始化渲染器，确保下次通话时状态正确
    _initializeRenderers();
    SimpleFileLogger.log('[WebRTC] 资源已清理.');
  }

  /// 启动屏幕共享截图流程（通过平台通道截图）
  /// [captureFrame] 是一个回调函数，用于从平台层获取屏幕截图的 Uint8List。
  /// **注意：** 在 Windows 上实现屏幕截图并转换为视频流需要复杂的平台通道代码，
  /// 这里仅提供骨架。你需要：
  /// 1. 在 Flutter 端调用 Windows API (如 `GetDesktopWindow`, `GetWindowDC`, `BitBlt`) 进行截图。
  /// 2. 将截图数据 (如 BMP) 转换为可用的视频帧格式。
  /// 3. 将视频帧数据添加到 WebRTC 的 MediaStreamTrack 中。
  void startScreenShare(Future<Uint8List?> Function() captureFrame) async {
    if (_peerConnection == null) {
      SimpleFileLogger.log('[ScreenShare]PeerConnection 未初始化.');
      return;
    }

    // 尝试获取屏幕媒体流 (WebRTC API 方式，可能不适用于所有桌面平台)
    // 更好的方式是使用平台通道获取截图并手动添加到 MediaStreamTrack
    try {
      final MediaStream screenStream = await navigator.mediaDevices
          .getDisplayMedia({
            'video': true,
            'audio': false, // 通常屏幕共享不包含音频
          });
      _screenTrack = screenStream.getVideoTracks().first;

      // 替换或添加屏幕共享轨道到 PeerConnection
      if (_localStream != null) {
        // 移除旧的视频轨道（如果存在）
        // 遍历所有的 RTCRtpSender
        _peerConnection!.getSenders().then((senders) {
          for (var sender in senders) {
            // 检查这个 sender 是否正在发送一个视频轨道
            // 并且这个视频轨道是否是我们本地流中的一个
            if (sender.track?.kind == 'video' &&
                _localStream!.getVideoTracks().contains(sender.track)) {
              // 找到了对应的 RTCRtpSender，可以移除它了
              _peerConnection!.removeTrack(sender);
              // 停止发送的轨道，释放资源
              sender.track?.stop(); // 注意这里是停止 sender.track
              break; // 假设通常只有一个本地视频轨道需要替换
            }
          }

          // 现在旧的视频轨道已经被移除了，可以添加新的屏幕共享轨道了
          // 这是一个异步操作，所以确保在移除完成后再添加新轨道
          _peerConnection!.addTrack(_screenTrack!, _localStream!);
          _localRenderer.srcObject = _localStream; // 更新本地预览以显示屏幕共享
          notifyListeners();
          SimpleFileLogger.log('[ScreenShare] 通过 getDisplayMedia 开始屏幕共享并替换轨道.');
        });
        // 添加新的屏幕共享轨道
        _peerConnection!.addTrack(_screenTrack!, _localStream!);
      } else {
        // 如果没有本地流，创建一个新的流来承载屏幕共享
        _localStream = screenStream;
        _peerConnection!.addStream(_localStream!);
      }
      _localRenderer.srcObject = _localStream; // 更新本地预览以显示屏幕共享
      notifyListeners();
      SimpleFileLogger.log('[ScreenShare] 通过 getDisplayMedia 开始屏幕共享。');
    } catch (e) {
      SimpleFileLogger.log('[ScreenShare]无法获取 DisplayMedia: $e。回退到手动捕获（未实现）.');
      // 如果 getDisplayMedia 失败，可以尝试手动截图并编码
      // _screenCaptureTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      //   final frame = await captureFrame();
      //   if (frame != null) {
      //     // TODO: 编码 frame 为视频轨推送到 WebRTC
      //     // 这需要将 Uint8List 转换为视频帧，并创建一个 MediaStreamTrack
      //     // 这是一个复杂的过程，通常需要额外的编解码库
      //   }
      // });
    }
  }

  /// 停止屏幕共享
  void stopScreenShare() async {
    SimpleFileLogger.log('[ScreenShare]停止屏幕共享.');
    _screenCaptureTimer?.cancel();
    _screenCaptureTimer = null;

    if (_screenTrack != null) {
      _screenTrack!.stop(); // 停止屏幕共享轨道

      if (_peerConnection != null && _localStream != null) {
        // 1. 找到并移除屏幕共享的 RTCRtpSender
        await _peerConnection!.getSenders().then((senders) {
          for (var sender in senders) {
            // 检查这个 sender 是否正在发送我们的屏幕共享轨道
            if (sender.track == _screenTrack) {
              _peerConnection!.removeTrack(sender);
              SimpleFileLogger.log('[ScreenShare] 删除了屏幕共享轨道发送器.');
              break; // 找到并移除后即可退出循环
            }
          }
        });

        // 2. 重新添加摄像头视频轨道（如果之前有的话）
        // 在这里添加逻辑以确保不会重复添加现有的摄像头轨道
        // 最佳实践是先移除旧的摄像头 sender（如果存在），然后添加新的
        // 这里简化处理，直接获取摄像头流并添加到 _localStream 和 peerConnection
        try {
          final newCameraStream = await navigator.mediaDevices.getUserMedia({
            'audio': true,
            'video': {
              'facingMode': 'user',
              'width': 640,
              'height': 480,
              'frameRate': 30,
            },
          });

          // 先清理 _localStream 中旧的视频轨道（如果有的话），避免重复
          _localStream!.getVideoTracks().forEach((track) {
            track.stop(); // 停止旧的摄像头轨道
            // 找到并移除旧的摄像头 sender
            _peerConnection!.getSenders().then((senders) {
              for (var sender in senders) {
                if (sender.track == track) {
                  _peerConnection!.removeTrack(sender);
                  SimpleFileLogger.log('[ScreenShare]删除了旧的摄像机轨迹发送器.');
                  break;
                }
              }
            });
          });
          _localStream!.getAudioTracks().forEach((track) {
            // 如果音频轨道也需要替换，在这里处理
            // 否则保持不变，或只替换视频
          });

          // 更新 _localStream 为新的摄像头流
          _localStream = newCameraStream;
          // 将新摄像头流的所有轨道添加到 PeerConnection
          _localStream!.getTracks().forEach((track) {
            _peerConnection!.addTrack(track, _localStream!);
            SimpleFileLogger.log('[ScreenShare] 添加了新的摄像机轨迹: ${track.kind}.');
          });

          _localRenderer.srcObject = _localStream; // 更新本地预览
          SimpleFileLogger.log('[ScreenShare] 切换回相机流.');
        } catch (e) {
          SimpleFileLogger.log('[ScreenShare] 停止屏幕共享后无法获取摄像头流: $e');
        }
      }
      _screenTrack = null; // 清空屏幕共享轨道引用
      notifyListeners();
    }
  }
}
