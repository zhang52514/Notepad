import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:notepad/controller/mixin/WebRTCStatsMixin.dart';
import 'package:notepad/core/SimpleFileLogger.dart';
import 'package:notepad/main.dart' as main;
import 'package:notepad/views/chat/Components/VideoCall/ScreenSelectDialog.dart';

typedef SignalSender = Function(Map<String, dynamic> signal);

class RtcCallController extends ChangeNotifier with WebRTCStatsMixin {
  // --- 日志工具 ---
  void _log(String label, [String? details]) {
    final timestamp = DateTime.now().toIso8601String();
    SimpleFileLogger.log('[WebRTC][$timestamp] $label ${details ?? ''}');
  }

  // --- 通话时长管理 ---
  DateTime? _callStartTime;
  Timer? _durationTimer;
  Duration get callDuration =>
      _callStartTime == null
          ? Duration.zero
          : DateTime.now().difference(_callStartTime!);

  // --- 超时及无应答标记 ---
  Timer? _callTimeoutTimer;
  bool _noResponse = false;
  bool get noResponse => _noResponse;

  // --- 状态标志 ---
  bool _inCalling = false;
  bool get inCalling => _inCalling;

  bool _isScreenSharing = false;
  bool get isScreenSharing => _isScreenSharing;

  bool _isMicMuted = false;
  bool get isMicMuted => _isMicMuted;

  bool _isCameraOff = false;
  bool get isCameraOff => _isCameraOff;

  bool _isCaller = false;
  bool isSwapped = false;

  void setSwapped(bool value) {
    isSwapped = value;
    notifyListeners();
  }

  // --- WebRTC 核心对象 ---
  RTCPeerConnection? _peerConnection;
  MediaStream? _localCameraStream;
  MediaStream? _screenShareStream;

  // --- 媒体渲染器 ---
  late final RTCVideoRenderer _localRenderer;
  late final RTCVideoRenderer _remoteRenderer;

  // --- 优化的ICE服务器配置 ---
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      // 多个STUN服务器提高连通性
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},

      // 你的TURN服务器
      {
        'urls': [
          'turn:anoxia.cn:3478?transport=udp',
          'turn:anoxia.cn:3478?transport=tcp',
        ],
        'username': 'admin',
        'credential': '123456',
      },
    ],
    // 优化ICE传输策略
    'iceTransportPolicy': 'all',
    'bundlePolicy': 'max-bundle',
    'rtcpMuxPolicy': 'require',
  };
  
  // --- 优化的媒体约束 ---
  final Map<String, dynamic> _mediaConstraints = {
    'audio': {
      'echoCancellation': true,
      'noiseSuppression': true,
      'autoGainControl': true,
      'sampleRate': 44100,
      'channelCount': 1,
    },
    'video': {
      'width': {'min': 640, 'ideal': 1920, 'max': 1920},
      'height': {'min': 480, 'ideal': 1080, 'max': 1080},
      'frameRate': {'min': 15, 'ideal': 30, 'max': 60},
      'facingMode': 'user',
    },
  };

  // --- 可用媒体设备列表 ---
  List<MediaDeviceInfo> _videoDevices = [];
  String? _currentCameraDeviceId;

  // --- 渲染器访问 Getter ---
  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  // --- 连接状态 Getter ---
  bool get isConnected =>
      _peerConnection?.connectionState ==
      RTCPeerConnectionState.RTCPeerConnectionStateConnected;

  // --- 构造函数 ---
  RtcCallController() {
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    _initializeRenderers();
  }

  /// 初始化媒体渲染器
  Future<void> _initializeRenderers() async {
    await Future.wait([
      _localRenderer.initialize(),
      _remoteRenderer.initialize(),
    ]);
    _log("渲染器初始化完成");
  }

  @override
  void dispose() {
    _log("控制器销毁中...");
    stopStats();
    hangUp();
    super.dispose();
  }

  // --- 通话初始化 ---
  Future<void> initCall({
    required bool isOffer,
    required SignalSender onSignalSend,
  }) async {
    if (_inCalling) {
      _log("已在通话中，跳过初始化");
      return;
    }

    try {
      _inCalling = true;
      _isCaller = isOffer;
      notifyListeners();

      await _getUserMedia();
      _log(
        "本地媒体流获取成功",
        "音频轨道: ${_localCameraStream!.getAudioTracks().length}, "
            "视频轨道: ${_localCameraStream!.getVideoTracks().length}",
      );

      await _createPeerConnection(onSignalSend);

      // 添加本地流到PeerConnection
      for (final track in _localCameraStream!.getTracks()) {
        await _peerConnection!.addTrack(track, _localCameraStream!);
        _log("添加本地轨道", "类型: ${track.kind}, ID: ${track.id}");
      }

      // 设置编码参数优化
      await _configureEncodingParameters();
      _startCallTimeout();

      if (isOffer) {
        await createOffer(onSignalSend);
      }

      _log("通话初始化完成", "角色: ${isOffer ? '主叫' : '被叫'}");
    } catch (e) {
      _log("❌ 通话初始化失败", e.toString());
      _inCalling = false;
      notifyListeners();
      rethrow;
    }
  }

  void _startCallTimeout() {
    _noResponse = false;
    _callTimeoutTimer?.cancel();
    _callTimeoutTimer = Timer(Duration(seconds: 45), () {
      if (!isConnected) {
        _noResponse = true;
        _log("对方无应答，超时");
        notifyListeners();
        Future.delayed(const Duration(seconds: 3), hangUp);
      }
    });
  }

  // --- 优化的本地媒体获取 ---
  Future<void> _getUserMedia({String? deviceId}) async {
    if (_localCameraStream != null &&
        (deviceId == null || _currentCameraDeviceId == deviceId)) {
      return;
    }

    _localCameraStream?.getTracks().forEach((track) => track.stop());
    _localCameraStream?.dispose();
    _localCameraStream = null;
    _localRenderer.srcObject = null;

    try {
      _videoDevices = await navigator.mediaDevices.enumerateDevices().then(
        (devices) => devices.where((d) => d.kind == 'videoinput').toList(),
      );

      final selectedDeviceId =
          deviceId ?? _videoDevices.firstOrNull?.deviceId ?? '';

      final constraints = Map<String, dynamic>.from(_mediaConstraints);
      if (selectedDeviceId.isNotEmpty) {
        constraints['video']['deviceId'] = {'exact': selectedDeviceId};
        _currentCameraDeviceId = selectedDeviceId;
      }

      _localCameraStream = await navigator.mediaDevices.getUserMedia(
        constraints,
      );
      _localRenderer.srcObject = _localCameraStream;
      notifyListeners();

      _log(
        "✅ 本地媒体流获取成功",
        "设备ID: $_currentCameraDeviceId, "
            "分辨率: ${constraints['video']['width']['ideal']}x${constraints['video']['height']['ideal']}",
      );
    } catch (e) {
      _log("❌ 媒体获取失败", e.toString());
      rethrow;
    }
  }

  // --- 优化的PeerConnection创建 ---
  Future<void> _createPeerConnection(SignalSender onSignalSend) async {
    if (_peerConnection != null) {
      _log("PeerConnection 已存在，跳过创建");
      return;
    }

    try {
      _peerConnection = await createPeerConnection(_iceServers);
      _log("PeerConnection 创建成功");

      _configurePeerConnectionEvents(onSignalSend);
    } catch (e) {
      _log("❌ 创建PeerConnection失败", e.toString());
      rethrow;
    }
  }

  // --- 编码参数优化 ---
  Future<void> _configureEncodingParameters() async {
    if (_peerConnection == null) return;

    try {
      final senders = await _peerConnection!.getSenders();
      for (final sender in senders) {
        if (sender.track?.kind == 'video') {
          final params = sender.parameters;
          if (params.encodings != null && params.encodings!.isNotEmpty) {
            // 设置视频编码参数
            params.encodings![0].maxBitrate = 2000000; // 2Mbps
            params.encodings![0].maxFramerate = 30;
            params.encodings![0].scaleResolutionDownBy = 1.0;
            await sender.setParameters(params);
            _log("视频编码参数已优化", "码率: 2Mbps, 帧率: 30fps");
          }
        } else if (sender.track?.kind == 'audio') {
          final params = sender.parameters;
          if (params.encodings != null && params.encodings!.isNotEmpty) {
            // 设置音频编码参数
            params.encodings![0].maxBitrate = 128000; // 128kbps
            await sender.setParameters(params);
            _log("音频编码参数已优化", "码率: 128kbps");
          }
        }
      }
    } catch (e) {
      _log("编码参数优化失败", e.toString());
    }
  }

  // --- 优化的事件配置 ---
  void _configurePeerConnectionEvents(SignalSender onSignalSend) {
    _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate != null) {
        _log(
          "生成 ICE 候选",
          "类型: ${candidate.candidate?.split(' ')[2] ?? 'unknown'}",
        );
        onSignalSend({
          'type': 'candidate',
          'sdpMid': candidate.sdpMid,
          'sdpMlineIndex': candidate.sdpMLineIndex,
          'candidate': candidate.candidate,
        });
      }
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      _log("收到远程轨道", "类型: ${event.track.kind}");
      if (event.track.kind == 'video' && event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams.first;
        notifyListeners();
      }
    };

    _peerConnection!.onConnectionState = (state) {
      _log("连接状态变更", state.toString());

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _handleConnectionEstablished();
      } else if (_isFailedState(state)) {
        _log("连接失败或断开", "状态: $state");
        hangUp();
      }
      notifyListeners();
    };

    _peerConnection!.onDataChannel = (channel) {
      _log("收到数据通道", channel.label);
    };
  }

  void _handleConnectionEstablished() {
    _log("✅ 连接已建立");
    _callTimeoutTimer?.cancel();

    if (_callStartTime == null) {
      _callStartTime = DateTime.now();
      _durationTimer = Timer.periodic(Duration(seconds: 1), (_) {
        notifyListeners();
      });
      startStats();
      _log("通话时长计时器已启动");
    }
  }

  bool _isFailedState(RTCPeerConnectionState state) {
    return state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
        state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
        state == RTCPeerConnectionState.RTCPeerConnectionStateClosed;
  }

  // --- 优化的SDP处理 ---
  String _optimizeSdp(String sdp) {
    final lines = sdp.split('\r\n');
    final optimizedLines = <String>[];

    for (String line in lines) {
      // 优先选择H.264编解码器
      if (line.startsWith('m=video')) {
        optimizedLines.add(_reorderVideoCodecs(line, lines));
      } else if (line.contains('a=fmtp') && line.contains('H264')) {
        // 优化H.264参数
        if (!line.contains('profile-level-id')) {
          line += ';profile-level-id=42e01f';
        }
        if (!line.contains('level-asymmetry-allowed')) {
          line += ';level-asymmetry-allowed=1';
        }
        if (!line.contains('packetization-mode')) {
          line += ';packetization-mode=1';
        }
        optimizedLines.add(line);
      } else {
        optimizedLines.add(line);
      }
    }

    return optimizedLines.join('\r\n');
  }

  String _reorderVideoCodecs(String mLine, List<String> allLines) {
    final parts = mLine.split(' ');
    if (parts.length < 4) return mLine;

    final h264Payloads = <String>[];
    final otherPayloads = <String>[];

    // 找出H.264的payload类型
    for (String line in allLines) {
      if (line.startsWith('a=rtpmap:') && line.toLowerCase().contains('h264')) {
        final payload = line.split(':')[1].split(' ')[0];
        h264Payloads.add(payload);
      }
    }

    // 分离H.264和其他编解码器
    for (int i = 3; i < parts.length; i++) {
      if (h264Payloads.contains(parts[i])) {
        h264Payloads.add(parts[i]);
      } else {
        otherPayloads.add(parts[i]);
      }
    }

    // 重新排序：H.264优先
    final reordered = [
      parts[0],
      parts[1],
      parts[2],
      ...h264Payloads.toSet(),
      ...otherPayloads,
    ];

    return reordered.join(' ');
  }

  // --- 信令处理 ---
  Future<void> createOffer(SignalSender onSignalSend) async {
    if (_peerConnection == null) return;

    try {
      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
        'iceRestart': false,
      });

      final optimizedSdp = _optimizeSdp(offer.sdp!);
      final optimizedOffer = RTCSessionDescription(optimizedSdp, offer.type);

      await _peerConnection!.setLocalDescription(optimizedOffer);
      await onSignalSend(optimizedOffer.toMap());

      _log("✅ Offer创建并发送成功");
    } catch (e) {
      _log("❌ 创建Offer失败", e.toString());
    }
  }

  Future<void> handleOffer(
    Map<String, dynamic> data,
    SignalSender onSignalSend,
  ) async {
    try {
      if (_peerConnection == null) {
        _log("❌ PeerConnection未初始化");
        return;
      }

      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['sdp'], data['type']),
      );

      final answer = await _peerConnection!.createAnswer();
      final optimizedSdp = _optimizeSdp(answer.sdp!);
      final optimizedAnswer = RTCSessionDescription(optimizedSdp, answer.type);

      await _peerConnection!.setLocalDescription(optimizedAnswer);
      await onSignalSend(optimizedAnswer.toMap());

      _log("✅ Answer创建并发送成功");
    } catch (e) {
      _log("❌ 处理Offer失败", e.toString());
      rethrow;
    }
  }

  Future<void> handleAnswer(Map<String, dynamic> data) async {
    if (_peerConnection == null) return;

    try {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['sdp'], data['type']),
      );
      _log("✅ Answer处理成功");
    } catch (e) {
      _log("❌ 处理Answer失败", e.toString());
    }
  }

  Future<void> handleCandidate(Map<String, dynamic> data) async {
    if (_peerConnection == null) {
      _log("⚠️ PeerConnection未就绪，忽略ICE候选");
      return;
    }

    try {
      final candidate = RTCIceCandidate(
        data['candidate'],
        data['sdpMid'],
        data['sdpMlineIndex'],
      );
      await _peerConnection!.addCandidate(candidate);
      _log("✅ ICE候选添加成功");
    } catch (e) {
      _log("❌ 添加ICE候选失败", e.toString());
    }
  }

  void handleSignal(
    Map<String, dynamic> signalData,
    SignalSender onSignalSend,
  ) {
    if (!signalData.containsKey('type')) {
      _log("⚠️ 无效信令，缺少type字段");
      return;
    }

    final type = signalData['type'];
    _log("处理信令", "类型: $type");

    switch (type) {
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
        _log("⚠️ 未知信令类型", type.toString());
    }
  }

  // --- 通话控制 ---
  void hangUp() {
    _log("执行挂断流程");

    _cleanupResources();
    _resetState();
    _navigateBack();

    notifyListeners();
    _log("✅ 挂断完成");
  }

  void _cleanupResources() {
    // 停止并清理媒体流
    _screenShareStream?.getTracks().forEach((t) => t.stop());
    _screenShareStream?.dispose();
    _screenShareStream = null;

    _localCameraStream?.getTracks().forEach((t) => t.stop());
    _localCameraStream?.dispose();
    _localCameraStream = null;

    // 关闭PeerConnection
    _peerConnection?.close();
    _peerConnection = null;

    // 清空渲染器
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;

    // 停止统计和计时器
    stopStats();
    _durationTimer?.cancel();
    _durationTimer = null;
    _callTimeoutTimer?.cancel();
    _callTimeoutTimer = null;
  }

  void _resetState() {
    _inCalling = false;
    _isScreenSharing = false;
    _isMicMuted = false;
    _isCameraOff = false;
    _noResponse = false;
    _callStartTime = null;
    setSwapped(false);
  }

  void _navigateBack() {
    while (main.navigatorKey.currentState?.canPop() ?? false) {
      main.navigatorKey.currentState?.pop();
    }
  }

  // --- 媒体控制 ---
  void toggleMic() {
    final audioTrack = _localCameraStream?.getAudioTracks().firstOrNull;
    if (audioTrack != null) {
      audioTrack.enabled = !audioTrack.enabled;
      _isMicMuted = !audioTrack.enabled;
      _log("麦克风切换", "静音: $_isMicMuted");
      notifyListeners();
    }
  }

  void toggleCamera() {
    final videoTrack = _localCameraStream?.getVideoTracks().firstOrNull;
    if (videoTrack != null) {
      videoTrack.enabled = !videoTrack.enabled;
      _isCameraOff = !videoTrack.enabled;
      _log("摄像头切换", "关闭: $_isCameraOff");
      notifyListeners();
    }
  }

  Future<void> switchCamera() async {
    if (_localCameraStream == null || _videoDevices.length < 2) {
      _log("⚠️ 无法切换摄像头", "设备数量: ${_videoDevices.length}");
      return;
    }

    try {
      int currentIndex = _videoDevices.indexWhere(
        (device) => device.deviceId == _currentCameraDeviceId,
      );
      int nextIndex = (currentIndex + 1) % _videoDevices.length;
      String nextDeviceId = _videoDevices[nextIndex].deviceId;

      _log("切换摄像头", "到设备: $nextDeviceId");

      await _getUserMedia(deviceId: nextDeviceId);
      await _replaceLocalStreamTracks();

      _log("✅ 摄像头切换成功");
    } catch (e) {
      _log("❌ 摄像头切换失败", e.toString());
    }
  }

  Future<void> _replaceLocalStreamTracks() async {
    if (_peerConnection == null) return;

    try {
      final senders = await _peerConnection!.getSenders();

      // 替换音频轨道
      final audioTrack = _localCameraStream?.getAudioTracks().firstOrNull;
      final audioSender = senders.firstWhereOrNull(
        (s) => s.track?.kind == 'audio',
      );
      if (audioTrack != null && audioSender != null) {
        await audioSender.replaceTrack(audioTrack);
      }

      // 替换视频轨道
      final videoTrack =
          (_isScreenSharing ? _screenShareStream : _localCameraStream)
              ?.getVideoTracks()
              .firstOrNull;
      final videoSender = senders.firstWhereOrNull(
        (s) => s.track?.kind == 'video',
      );
      if (videoTrack != null && videoSender != null) {
        await videoSender.replaceTrack(videoTrack);
      }

      notifyListeners();
    } catch (e) {
      _log("❌ 替换轨道失败", e.toString());
    }
  }

  // --- 屏幕共享 ---
  Future<void> startScreenShare() async {
    if (_isScreenSharing || _peerConnection == null) {
      _log("⚠️ 屏幕共享条件不满足");
      return;
    }

    try {
      final source = await showScreenSelectDialog(main.globalContext);
      if (source == null) {
        _log("屏幕共享已取消");
        return;
      }

      _log("启动屏幕共享", "源: ${source.name}");

      final stream = await navigator.mediaDevices.getDisplayMedia({
        'audio': false,
        'video': {
          'deviceId': {'exact': source.id},
          'width': {'ideal': 1920},
          'height': {'ideal': 1080},
          'frameRate': {'ideal': 30},
        },
      });

      _screenShareStream = stream;
      final screenTrack = stream.getVideoTracks().firstOrNull;

      if (screenTrack != null) {
        final senders = await _peerConnection!.getSenders();
        final videoSender = senders.firstWhereOrNull(
          (s) => s.track?.kind == 'video',
        );

        if (videoSender != null) {
          await videoSender.replaceTrack(screenTrack);
          _localRenderer.srcObject = _screenShareStream;
          _isScreenSharing = true;

          screenTrack.onEnded = stopScreenShare;

          notifyListeners();
          _log("✅ 屏幕共享已启动");
        }
      }
    } catch (e) {
      _log("❌ 屏幕共享失败", e.toString());
      _isScreenSharing = false;
    }
  }

  Future<void> stopScreenShare() async {
    if (!_isScreenSharing) return;

    try {
      _log("停止屏幕共享");

      _screenShareStream?.getTracks().forEach((track) => track.stop());
      _screenShareStream?.dispose();
      _screenShareStream = null;

      if (_localCameraStream == null) {
        await _getUserMedia(deviceId: _currentCameraDeviceId);
      }

      final cameraTrack = _localCameraStream?.getVideoTracks().firstOrNull;
      if (cameraTrack != null && _peerConnection != null) {
        final senders = await _peerConnection!.getSenders();
        final videoSender = senders.firstWhereOrNull(
          (s) => s.track?.kind == 'video',
        );

        if (videoSender != null) {
          await videoSender.replaceTrack(cameraTrack);
          _localRenderer.srcObject = _localCameraStream;
          _isScreenSharing = false;
          notifyListeners();
          _log("✅ 已恢复摄像头");
        }
      }
    } catch (e) {
      _log("❌ 停止屏幕共享失败", e.toString());
      _isScreenSharing = false;
    }
  }

  @override
  void log(String label, [String? details]) {
    _log(label, details);
  }

  @override
  RTCPeerConnection? get peerConnection => _peerConnection;
}

// 扩展方法
extension FirstWhereOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;

  E? firstWhereOrNull(bool Function(E element) test, {E? Function()? orElse}) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return orElse?.call();
  }
}
