import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:notepad/core/SimpleFileLogger.dart'; // 确保路径正确
import 'package:notepad/main.dart' as main;
import 'package:notepad/views/chat/Components/ScreenSelectDialog.dart';

// 定义信令发送函数类型
typedef SignalSender = Function(Map<String, dynamic> signal);

class RtcCallController extends ChangeNotifier {
  // --- 日志工具 ---
  void _log(String label, [String? details]) {
    final timestamp = DateTime.now().toIso8601String();
    SimpleFileLogger.log('[WebRTC][$timestamp] $label ${details ?? ''}');
  }

  Timer? _callTimeoutTimer;
  RTCIceConnectionState? _iceState;
  void _startCallTimeout() {
    _callTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!isConnected) {
        hangUp();
        // 通知对方超时
      }
    });
  }

  // --- 状态标志 ---
  bool _inCalling = false; // 是否在通话中
  bool get inCalling => _inCalling;

  bool _isScreenSharing = false; // 是否正在屏幕共享
  bool get isScreenSharing => _isScreenSharing;

  bool _isMicMuted = false; // 麦克风是否静音
  bool get isMicMuted => _isMicMuted;

  bool _isCameraOff = false; // 摄像头是否关闭
  bool get isCameraOff => _isCameraOff;

  // --- WebRTC 核心对象 ---
  RTCPeerConnection? _peerConnection;
  MediaStream? _localCameraStream; // 用于摄像头/麦克风的本地流
  MediaStream? _screenShareStream; // 用于屏幕共享的流

  // --- 媒体渲染器 ---
  late final RTCVideoRenderer _localRenderer;
  late final RTCVideoRenderer _remoteRenderer;

  // --- ICE 候选缓存 (用于PeerConnection创建前的候选缓存) ---
  final List<RTCIceCandidate> _cachedCandidates = [];

  // --- 可用媒体设备列表 (主要用于桌面端) ---
  List<MediaDeviceInfo> _videoDevices = []; // 存储可用视频设备列表
  String? _currentCameraDeviceId; // 当前使用的摄像头ID

  // --- ICE 服务器配置 ---
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {
        'urls': [
          'turn:anoxia.cn:3478?transport=udp',
          'turn:anoxia.cn:3478?transport=tcp',
          // 'turns:anoxia.cn:5349?transport=tcp',
        ],
        'username': 'admin',
        'credential': '123456',
      },
    ],
  };

  // --- 渲染器访问 Getter ---
  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  // --- 连接状态 Getter (更精确地判断是否已连接) ---
  bool get isConnected =>
      _peerConnection?.connectionState ==
      RTCPeerConnectionState.RTCPeerConnectionStateConnected;

  // --- 构造函数 ---
  RtcCallController() {
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    _initializeRenderers(); // 异步初始化渲染器
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
    _cleanUpResources(); // 清理所有 WebRTC 相关资源
    super.dispose();
  }

  // --- 通话初始化 ---
  /// 初始化通话并根据 `isOffer` 决定是发起方还是接收方。
  /// `onSignalSend` 用于发送信令到对方。
  Future<void> initCall({
    required bool isOffer,
    required SignalSender onSignalSend,
  }) async {
    if (_inCalling) {
      _log("已在通话中，跳过初始化");
      return;
    }

    try {
      await _getUserMedia(); // 获取本地摄像头/麦克风流
      _log(
        "✅ 本地媒体流获取成功",
        "音频轨道: ${_localCameraStream!.getAudioTracks().length}, "
            "视频轨道: ${_localCameraStream!.getVideoTracks().length}, " // 检查这里是否 > 0
            "设备ID: $_currentCameraDeviceId",
      );

      await _createPeerConnection(onSignalSend); // 创建 PeerConnection 并设置事件监听

      // 将本地摄像头流添加到 PeerConnection
      _localCameraStream?.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localCameraStream!);
        _log("添加本地摄像头/麦克风轨道", "类型: ${track.kind}, ID: ${track.id}");
      });
      _startCallTimeout();
      if (isOffer) {
        await createOffer(onSignalSend); // 如果是主叫，创建 Offer
      }

      _inCalling = true; // 设置通话状态为进行中
      notifyListeners(); // 通知 UI 更新
      _log("通话初始化完成", "角色: ${isOffer ? '主叫' : '被叫'}");
    } on PlatformException catch (e) {
      _log("❌ 通话初始化平台异常", "代码: ${e.code}, 消息: ${e.message}");
      _cleanUpResources();
      throw "无法访问媒体设备: ${e.message}"; // 向上抛出更友好的错误信息
    } catch (e) {
      _log("❌ 通话初始化失败", e.toString());
      _cleanUpResources();
      rethrow; // 重新抛出其他错误
    }
  }

  // --- 获取本地媒体流 (摄像头/麦克风) ---
  /// 获取本地摄像头和麦克风的媒体流。
  Future<void> _getUserMedia({String? deviceId}) async {
    // 如果已经有流且不需要切换设备，则直接返回
    if (_localCameraStream != null &&
        (deviceId == null || _currentCameraDeviceId == deviceId)) {
      return;
    }

    // 停止并清理旧的本地流（如果有）
    _localCameraStream?.getTracks().forEach((track) => track.stop());
    _localCameraStream?.dispose();
    _localCameraStream = null;
    _localRenderer.srcObject = null; // 清空渲染器源

    try {
      // 1. 枚举所有可用的视频输入设备 (仅在桌面端有意义)
      _videoDevices = await navigator.mediaDevices.enumerateDevices().then(
        (devices) => devices.where((d) => d.kind == 'videoinput').toList(),
      );

      // 2. 选择要使用的摄像头设备ID
      final selectedDeviceId =
          deviceId ??
          _videoDevices
              .firstWhereOrNull(
                (device) => device.deviceId != null, // 找到第一个有DeviceId的设备
                orElse:
                    () => MediaDeviceInfo(
                      label: '',
                      deviceId: '',
                    ), // 如果没有找到则返回一个空的，避免报错
              )
              ?.deviceId;

      if (selectedDeviceId == null || selectedDeviceId.isEmpty) {
        _log("警告", "没有可用的视频输入设备。");
        // 如果没有视频设备，可以尝试只获取音频
        final audioConstraints = {'audio': true, 'video': false};
        _localCameraStream = await navigator.mediaDevices.getUserMedia(
          audioConstraints,
        );
      } else {
        final constraints = {
          'audio': true,
          'video': {'deviceId': selectedDeviceId}, // 使用选定的设备ID
        };
        _localCameraStream = await navigator.mediaDevices.getUserMedia(
          constraints,
        );
        _currentCameraDeviceId = selectedDeviceId; // 更新当前设备ID
      }

      _localRenderer.srcObject = _localCameraStream; // 将本地流设置到渲染器
      notifyListeners(); // 通知 UI 更新

      _log(
        "✅ 本地媒体流获取成功",
        "音频轨道: ${_localCameraStream!.getAudioTracks().length}, "
            "视频轨道: ${_localCameraStream!.getVideoTracks().length}, "
            "设备ID: $_currentCameraDeviceId",
      );
    } on PlatformException catch (e) {
      _log("❌ 媒体获取平台异常", "代码: ${e.code}, 消息: ${e.message}");
      throw "无法访问摄像头/麦克风: ${e.message}";
    } catch (e) {
      _log("❌ 媒体获取未知错误", e.toString());
      throw "媒体获取失败: $e";
    }
  }

  // --- 创建 PeerConnection ---
  /// 创建 RTCPeerConnection 并设置所有必要的事件监听。
  Future<void> _createPeerConnection(SignalSender onSignalSend) async {
    if (_peerConnection != null) {
      _log("PeerConnection 已存在，跳过创建");
      return;
    }

    try {
      _peerConnection = await createPeerConnection(_iceServers);
      _log("PeerConnection 创建成功");

      // 配置 PeerConnection 事件监听器
      _configurePeerConnectionEvents(onSignalSend);

      // 处理缓存的 ICE 候选 (在 PeerConnection 创建前收到的)
      if (_cachedCandidates.isNotEmpty) {
        _log("处理缓存的 ICE 候选", "数量: ${_cachedCandidates.length}");
        for (final candidate in _cachedCandidates) {
          await _peerConnection!.addCandidate(candidate);
        }
        _cachedCandidates.clear();
      }
    } catch (e) {
      _log("❌ 创建PeerConnection失败", e.toString());
      _cleanUpResources();
      rethrow;
    }
  }

  // --- 配置 PeerConnection 事件 ---
  /// 设置 RTCPeerConnection 的各种事件回调。
  void _configurePeerConnectionEvents(SignalSender onSignalSend) {
    _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate == null) return;

      _log("生成 ICE 候选", candidate.candidate ?? '');
      onSignalSend({
        'type': 'candidate',
        'sdpMid': candidate.sdpMid,
        'sdpMlineIndex': candidate.sdpMLineIndex,
        'candidate': candidate.candidate,
      });
    };
    _peerConnection!.onIceGatheringState = (state) {
      _log("ICE 聚集状态", state.toString());
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      _log("收到远程轨道", "类型: ${event.track.kind}, ID: ${event.track.id}");
      if (event.track.kind == 'video') {
        _remoteRenderer.srcObject = event.streams.first; // 远程视频流
        notifyListeners();
      }
    };

    _peerConnection!.onConnectionState = (state) {
      _log("PeerConnection 连接状态变更", state.toString());
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _log("✅ PeerConnection 已连接", "通话成功建立！");
        _callTimeoutTimer?.cancel();
      } else if (state ==
              RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        _log("连接终止", "状态: $state, 自动挂断");
        hangUp();
      }
      notifyListeners(); // 通知 UI 更新连接状态
    };

    _peerConnection!.onIceConnectionState = (state) {
      _log("ICE 连接状态", state.toString());
      _iceState = state;
      notifyListeners();
    };
    _peerConnection!.onSignalingState = (state) {
      _log("onSignalingState 状态", state.toString());
      notifyListeners();
    };
  }

  // --- 信令相关方法 ---
  /// 创建并发送 Offer (主叫方)
  Future<void> createOffer(SignalSender onSignalSend) async {
    if (_peerConnection == null) {
      _log("错误", "PeerConnection 未初始化，无法创建 Offer");
      return;
    }
    try {
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      _log("Offer 创建成功", "类型: ${offer.type}");
      await onSignalSend(offer.toMap());
    } catch (e) {
      _log("❌ 创建Offer失败", e.toString());
      rethrow;
    }
  }

  /// 处理收到的 Offer 并创建 Answer (被叫方)
  Future<void> handleOffer(
    Map<String, dynamic> data,
    SignalSender onSignalSend,
  ) async {
    try {
      _log("处理Offer", "SDP: ${data['sdp']?.toString().substring(0, 30)}...");

      // 确保本地媒体流和PeerConnection已初始化
      if (_localCameraStream == null) await _getUserMedia();
      if (_peerConnection == null) await _createPeerConnection(onSignalSend);

      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['sdp'], data['type']),
      );

      await _createAnswer(onSignalSend);
    } catch (e) {
      _log("❌ 处理Offer失败", e.toString());
      hangUp();
      rethrow;
    }
  }

  /// 创建并发送 Answer (被叫方)
  Future<void> _createAnswer(SignalSender onSignalSend) async {
    if (_peerConnection == null) {
      _log("错误", "PeerConnection 未初始化，无法创建 Answer");
      return;
    }
    try {
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      _log("Answer 创建成功", "类型: ${answer.type}");
      _log("Answer SDP", answer.sdp ?? "SDP is null");
      await onSignalSend(answer.toMap());
    } catch (e) {
      _log("❌ 创建Answer失败", e.toString());
      rethrow;
    }
  }

  /// 处理收到的 Answer (主叫方)
  Future<void> handleAnswer(Map<String, dynamic> data) async {
    if (_peerConnection == null) {
      _log("错误", "PeerConnection 未初始化，无法处理 Answer");
      return;
    }
    try {
      _log("处理Answer", "SDP: ${data['sdp']?.toString().substring(0, 30)}...");

      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(data['sdp'], data['type']),
      );
    } catch (e) {
      _log("❌ 处理Answer失败", e.toString());
      hangUp();
      rethrow;
    }
  }

  /// 处理收到的 ICE Candidate
  Future<void> handleCandidate(Map<String, dynamic> data) async {
    try {
      final candidate = RTCIceCandidate(
        data['candidate'],
        data['sdpMid'],
        data['sdpMlineIndex'],
      );

      if (_peerConnection == null) {
        _log("缓存ICE候选", "等待PeerConnection初始化");
        _cachedCandidates.add(candidate);
        return;
      }

      await _peerConnection!.addCandidate(candidate);
      _log("添加ICE候选成功", candidate.candidate ?? '');
    } catch (e) {
      _log("❌ 添加ICE候选失败", e.toString());
    }
  }

  /// 统一处理所有信令
  void handleSignal(
    Map<String, dynamic> signalData,
    SignalSender onSignalSend,
  ) {
    if (!signalData.containsKey('type')) {
      _log("警告", "接收到无效信令，缺少 'type' 字段: $signalData");
      return;
    }

    _log("处理信令", "类型: ${signalData['type']}");

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
      case 'hangup': // 新增：处理对方发来的挂断信令
        _log("收到挂断信令", "对方已挂断");
        hangUp();
        break;
      default:
        _log("未知信令类型", signalData['type'].toString());
    }
  }

  // --- 通话控制方法 ---
  /// 挂断当前通话并清理所有资源。
  void hangUp() {
    _log("执行挂断通话流程");
    _cleanUpResources();
    _inCalling = false; // 重置通话状态
    _isScreenSharing = false; // 重置屏幕共享状态
    _isMicMuted = false; // 重置麦克风状态
    _isCameraOff = false; // 重置摄像头状态
    _currentCameraDeviceId = null; // 重置当前设备ID
    _cachedCandidates.clear(); // 清除缓存候选
    notifyListeners(); // 通知 UI 更新
    _log("挂断完成");
  }

  /// 清理所有 WebRTC 相关资源。
  void _cleanUpResources() {
    _log("清理所有 WebRTC 资源...");

    // 停止并清理屏幕共享流
    _screenShareStream?.getTracks().forEach((track) => track.stop());
    _screenShareStream?.dispose();
    _screenShareStream = null;
    // 停止并清理本地摄像头/麦克风流
    _localCameraStream?.getTracks().forEach((track) => track.stop());
    _localCameraStream?.dispose();
    _localCameraStream = null;

    // 关闭 PeerConnection
    _peerConnection?.close();
    _peerConnection = null;

    // 重置渲染器源
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;

    _log("资源清理完成");
  }

  /// 切换麦克风的静音状态。
  void toggleMic() {
    final audioTrack = _localCameraStream?.getAudioTracks().firstOrNull;
    if (audioTrack != null) {
      audioTrack.enabled = !audioTrack.enabled;
      _isMicMuted = !audioTrack.enabled;
      _log("麦克风状态切换", "静音: $_isMicMuted");
      notifyListeners();
    } else {
      _log("警告", "未找到本地音频轨道，无法切换麦克风状态。");
    }
  }

  /// 切换摄像头的开启/关闭状态。
  void toggleCamera() {
    final videoTrack = _localCameraStream?.getVideoTracks().firstOrNull;
    if (videoTrack != null) {
      videoTrack.enabled = !videoTrack.enabled;
      _isCameraOff = !videoTrack.enabled;
      _log("摄像头状态切换", "关闭: $_isCameraOff");
      notifyListeners();
    } else {
      _log("警告", "未找到本地视频轨道，无法切换摄像头状态。");
    }
  }

  /// 切换前后摄像头或桌面端可用摄像头。
  Future<void> switchCamera() async {
    if (_localCameraStream == null) {
      _log("错误", "本地流未初始化，无法切换摄像头。");
      return;
    }

    if (_videoDevices.isEmpty) {
      _log("警告", "未检测到多个视频设备，无法切换摄像头。");
      return;
    }

    // 找到当前设备在列表中的索引
    int currentIndex = _videoDevices.indexWhere(
      (device) => device.deviceId == _currentCameraDeviceId,
    );
    // 计算下一个设备的索引
    int nextIndex = (currentIndex + 1) % _videoDevices.length;
    // 获取下一个设备的ID
    String? nextDeviceId = _videoDevices[nextIndex].deviceId;

    if (nextDeviceId != null && nextDeviceId.isNotEmpty) {
      _log("切换摄像头", "从 $_currentCameraDeviceId 到 $nextDeviceId");
      await _getUserMedia(deviceId: nextDeviceId); // 使用新的设备ID重新获取本地流
      // 重新将流添加到 PeerConnection (这会触发协商)
      await _replaceLocalStreamTracks();
    } else {
      _log("错误", "无法找到下一个有效的摄像头设备ID。");
    }
  }

  /// 替换 PeerConnection 中的本地流轨道 (用于摄像头切换或屏幕共享切换)
  Future<void> _replaceLocalStreamTracks() async {
    if (_peerConnection == null) {
      _log("警告", "PeerConnection 未初始化，无法替换轨道。");
      return;
    }

    final senders = await _peerConnection!.getSenders();

    // 替换音频轨道
    final audioTrack = _localCameraStream?.getAudioTracks().firstOrNull;
    final audioSender = senders.firstWhereOrNull(
      (s) => s.track?.kind == 'audio',
    );
    if (audioTrack != null && audioSender != null) {
      await audioSender.replaceTrack(audioTrack);
      _log("替换音频轨道", "成功");
    } else {
      _log("警告", "未找到音频轨道或发送器，跳过音频轨道替换。");
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
      _log("替换视频轨道", "成功");
    } else {
      _log("警告", "未找到视频轨道或发送器，跳过视频轨道替换。");
    }

    // 通常 replaceTrack 会触发 renegotiationNeeded 事件，但手动触发可能更稳健
    // if (_peerConnection!.signalingState == RTCSignalingState.RTCSignalingStateStable) {
    //   _log("触发 Offer 重新协商", "");
    //   // TODO: 这里需要一个机制来判断当前是主叫还是被叫，并根据角色重新发起 Offer/Answer
    //   // 这通常需要信令服务提供一个方法来触发协商
    // }
    notifyListeners();
  }

  // --- 屏幕共享功能 ---
  /// 启动屏幕共享。
  Future<void> startScreenShare() async {
    if (_isScreenSharing) {
      _log("警告", "已在屏幕共享中，跳过启动。");
      return;
    }
    if (_peerConnection == null) {
      _log("错误", "PeerConnection 未初始化，无法启动屏幕共享。");
      return;
    }

    try {
      final sources = await desktopCapturer.getSources(
        types: [SourceType.Screen, SourceType.Window],
        thumbnailSize: ThumbnailSize(320, 240), // 设置缩略图大小
      );

      final source = await showDialog<DesktopCapturerSource>(
        context: main.globalContext, // 确保 main.globalContext 可用且正确
        builder: (_) => ScreenSelectDialog(sources),
      );
      if (source == null) {
        _log("提示", "未选择任何共享源，取消屏幕共享。");
        return;
      }
      _log("启动屏幕共享...", "选中源：${source.name}");

      // 获取屏幕共享流
      // 添加高级配置参数
      final stream = await navigator.mediaDevices.getDisplayMedia(
        <String, dynamic>{
          'audio': false, // 通常屏幕共享不共享系统音频
          'video': {
            'deviceId': {'exact': source.id}, // 精确匹配用户选择的源ID
            'mandatory': {'frameRate': 30.0}, // 可以设置帧率
          },
        },
      );

      final screenTrack =
          stream.getVideoTracks().firstOrNull; // 使用 firstOrNull 防止空指针
      if (screenTrack == null) {
        throw "无法获取屏幕共享视频轨道";
      }

      // 替换 PeerConnection 中的视频轨道为屏幕共享轨道
      final senders = await _peerConnection!.getSenders();
      final videoSender = senders.firstWhereOrNull(
        (s) => s.track?.kind == 'video',
      );

      if (videoSender != null) {
        await videoSender.replaceTrack(screenTrack);
        _localRenderer.srcObject = _screenShareStream; // 更新本地渲染器显示屏幕共享内容
        _isScreenSharing = true;
        notifyListeners();
        _log("✅ 屏幕共享已启动", "视频轨道ID: ${screenTrack.id}");

        // 监听屏幕共享流的结束事件（如用户点击停止共享按钮）
        screenTrack.onEnded = () {
          _log("屏幕共享流已结束", "用户可能停止了共享");
          stopScreenShare(); // 当用户从系统层面停止共享时，自动停止
        };
      } else {
        throw "未找到视频发送器，无法进行屏幕共享";
      }
    } catch (e) {
      _log("❌ 屏幕共享失败", e.toString());
      _isScreenSharing = false; // 确保状态正确
      // hangUp(); // 如果是关键错误，可以考虑挂断
      if (e.toString().contains("source not found")) {
        _showWindowsScreenCaptureGuide();
      }
    }
  }

  void _showWindowsScreenCaptureGuide() {
    showDialog(
      context: main.globalContext,
      builder:
          (ctx) => AlertDialog(
            title: Text("屏幕共享需要权限"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("请完成以下步骤："),
                SizedBox(height: 16),
                Text("1. 打开 Windows 设置 → 隐私 → 屏幕截图权限"),
                Text("2. 开启 '允许应用访问屏幕截图'"),
                Text("3. 确保 '允许桌面应用访问' 已启用"),
                SizedBox(height: 16),
                ElevatedButton(onPressed: () {}, child: Text("打开隐私设置")),
              ],
            ),
          ),
    );
  }

  /// 停止屏幕共享并恢复摄像头。
  Future<void> stopScreenShare() async {
    if (!_isScreenSharing) {
      _log("警告", "未在屏幕共享中，跳过停止。");
      return;
    }
    if (_peerConnection == null) {
      _log("错误", "PeerConnection 未初始化，无法停止屏幕共享。");
      // 此时只需清理屏幕共享流状态
      _screenShareStream?.getTracks().forEach((track) => track.stop());
      _screenShareStream?.dispose();
      _screenShareStream = null;
      _isScreenSharing = false;
      notifyListeners();
      return;
    }

    try {
      _log("停止屏幕共享...");

      // 先停止并清理屏幕共享流
      _screenShareStream?.getTracks().forEach((track) => track.stop());
      _screenShareStream?.dispose();
      _screenShareStream = null;

      // 恢复摄像头视频流 (需要确保 _localCameraStream 仍然有效或重新获取)
      if (_localCameraStream == null) {
        await _getUserMedia(deviceId: _currentCameraDeviceId); // 重新获取摄像头流
      }

      final cameraTrack = _localCameraStream?.getVideoTracks().firstOrNull;
      if (cameraTrack == null) {
        throw "无法获取摄像头视频轨道以恢复";
      }

      // 替换回摄像头轨道
      final senders = await _peerConnection!.getSenders();
      final videoSender = senders.firstWhereOrNull(
        (s) => s.track?.kind == 'video',
      );

      if (videoSender != null) {
        await videoSender.replaceTrack(cameraTrack);
        _localRenderer.srcObject = _localCameraStream; // 更新本地渲染器显示摄像头内容
        _isScreenSharing = false;
        notifyListeners();
        _log("✅ 已恢复摄像头");
      } else {
        throw "未找到视频发送器，无法恢复摄像头";
      }
    } catch (e) {
      _log("❌ 停止屏幕共享失败", e.toString());
      _isScreenSharing = false; // 确保状态正确
      // hangUp(); // 严重错误时终止通话
      rethrow;
    }
  }
}

// 辅助扩展：用于安全地获取列表中的第一个元素或 null
extension FirstWhereOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) {
      return it.current;
    }
    return null;
  }

  E? firstWhereOrNull(bool Function(E element) test, {E? Function()? orElse}) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return orElse?.call();
  }
}
