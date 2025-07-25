import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:notepad/common/utils/DialogUtil.dart';
import 'package:notepad/controller/AuthController.dart';
import 'package:notepad/controller/RtcController.dart';
import 'package:notepad/controller/mixin/MessageMixin.dart';
import 'package:notepad/controller/mixin/RoomMixin.dart';
import 'package:notepad/controller/mixin/UserMixin.dart';
import 'package:notepad/main.dart' as main;
import 'package:notepad/views/chat/Components/VideoCall/VideoCallPage.dart';

import '../common/domain/ChatEnumAll.dart';
import '../common/domain/ChatMessage.dart';
import '../common/module/AnoToast.dart';
import '../core/websocket_service.dart';

/// ChatController 核心控制器，负责聊天消息、用户、房间管理和 WebRTC 信令协调
class ChatController extends ChangeNotifier
    with UserMixin, RoomMixin, MessageMixin {
  final WebSocketService _ws = WebSocketService();
  late AuthController authController;
  late RtcCallController rtcCallController;

  // 保存当前正在进行视频通话的对方用户ID，用于信令发送
  String? _currentCallPeerId;
  String? get currentCallPeerId => _currentCallPeerId;

  ChatController({
    required this.authController,
    required this.rtcCallController,
  }) {
    // 滚动监听
    scrollChatListController.addListener(_onScroll);

    // 接受消息监听
    _ws.addListener((msg) {
      if (msg.code == "200") {
        final raw = msg.data;
        if (raw != null) {
          if (raw['cmd'] == Cmd.chat.name) {
            final message = ChatMessage.fromJson(raw);
            // 优先处理 WebRTC 相关的信令消息
            if (message.type == MessageType.videoCall ||
                message.type == MessageType.videoAnswer ||
                message.type == MessageType.videoReject ||
                message.type == MessageType.videoHangup ||
                message.type == MessageType.signal) {
              _handleRtcSignalingMessage(message);
              return; // WebRTC 信令不作为普通聊天消息显示
            }
            // 普通聊天消息
            addMessage(message, authController.currentUser!.id);
          } else if (raw['cmd'] == Cmd.http.name) {
            // 处理 HTTP 请求返回的数据
            if (raw['path'] == HttpPath.getUsers.name) {
              setUsers(raw["users"], authController.currentUser!.id);
            }
            if (raw['path'] == HttpPath.getRooms.name) {
              setRooms(raw["rooms"], authController.currentUser!.id);
            }
            if (raw['path'] == HttpPath.getHistory.name) {
              setMessage(raw["messages"], authController.currentUser!.id);
            }
          }
        }
      } else {
        AnoToast.showToast(msg.message, type: ToastType.error);
      }
    });
  }

  // 添加缓存未处理Offer的Map
  final Map<String, Map<String, dynamic>> _pendingOffers = {};

  /// 处理所有 WebRTC 相关的信令消息 - 优化版本
  void _handleRtcSignalingMessage(ChatMessage msg) {
    // 防止自发自收
    if (msg.senderId == authController.currentUser?.id) {
      return;
    }

    _currentCallPeerId = msg.senderId;
    _log("收到WebRTC信令", "类型: ${msg.type}, 发送者: ${msg.senderId}");

    switch (msg.type) {
      case MessageType.videoCall:
        _handleIncomingCall(msg);
        break;
      case MessageType.videoAnswer:
        _handleCallAccepted(msg);
        break;
      case MessageType.videoReject:
        _handleCallRejected(msg);
        break;
      case MessageType.videoHangup:
        _handleCallHangup(msg);
        break;
      case MessageType.signal:
        _handleWebRTCSignal(msg);
        break;
      default:
        _log("未知信令类型", msg.type.toString());
    }
  }

  /// 处理来电请求
  void _handleIncomingCall(ChatMessage msg) {
    // 如果已经在通话中，自动拒绝新来电
    if (rtcCallController.inCalling) {
      _log("已在通话中，自动拒绝来电", msg.senderId);
      sendVideoReject(msg.senderId, msg.roomId);
      return;
    }

    _log("收到来电请求", "来自: ${msg.senderId}");
    DialogUtil.showGlobalDialog(_buildIncomingCallDialog(msg));
  }

  /// 处理通话被接受
  void _handleCallAccepted(ChatMessage msg) {
    _log("对方已接听", msg.senderId);
    AnoToast.showToast("对方已接听", type: ToastType.success);

    // 如果不在通话状态，可能是异常情况
    if (!rtcCallController.inCalling) {
      _log("警告: 收到接听信令但本地未在通话状态");
    }
  }

  /// 处理通话被拒绝
  void _handleCallRejected(ChatMessage msg) {
    _log("对方拒绝通话", msg.senderId);
    AnoToast.showToast("对方已拒绝通话", type: ToastType.info);
    rtcCallController.hangUp();
  }

  /// 处理通话挂断
  void _handleCallHangup(ChatMessage msg) {
    _log("对方挂断通话", msg.senderId);
    AnoToast.showToast("通话已结束", type: ToastType.info);
    rtcCallController.hangUp();
  }

  /// 处理WebRTC信令数据
  void _handleWebRTCSignal(ChatMessage msg) {
    if (msg.metadata.isEmpty) {
      _log("警告: WebRTC信令数据为空");
      return;
    }

    final signalType = msg.metadata['type'] as String?;
    _log("处理WebRTC信令", "类型: $signalType");

    // 根据信令类型进行不同处理
    switch (signalType) {
      case 'offer':
        _handleOffer(msg);
        break;
      case 'answer':
        _handleAnswer(msg);
        break;
      case 'candidate':
        _handleCandidate(msg);
        break;
      default:
        _log("未知WebRTC信令类型", signalType ?? 'null');
    }
  }

  /// 处理Offer信令
  void _handleOffer(ChatMessage msg) {
    // 如果尚未初始化通话，需要先准备被叫方状态
    if (!rtcCallController.inCalling) {
      _log("收到Offer但未在通话状态，可能是时序问题");
      // 这里可以缓存Offer，等待用户接听后处理
      _pendingOffers[msg.senderId] = msg.metadata;
      return;
    }

    // 直接处理Offer
    rtcCallController.handleSignal(msg.metadata, (signalData) {
      _sendRtcSignalingMessage(
        senderId: authController.currentUser!.id,
        receiverId: msg.senderId,
        roomId: msg.roomId,
        signalData: signalData,
      );
    });
  }

  /// 处理Answer信令
  void _handleAnswer(ChatMessage msg) {
    if (!rtcCallController.inCalling) {
      _log("警告: 收到Answer但未在通话状态");
      return;
    }

    rtcCallController.handleSignal(msg.metadata, (signalData) {
      _sendRtcSignalingMessage(
        senderId: authController.currentUser!.id,
        receiverId: msg.senderId,
        roomId: msg.roomId,
        signalData: signalData,
      );
    });
  }

  /// 处理ICE Candidate信令
  void _handleCandidate(ChatMessage msg) {
    // ICE候选可以在任何时候收到，但需要PeerConnection存在
    rtcCallController.handleSignal(msg.metadata, (signalData) {
      _sendRtcSignalingMessage(
        senderId: authController.currentUser!.id,
        receiverId: msg.senderId,
        roomId: msg.roomId,
        signalData: signalData,
      );
    });
  }

  /// 优化的来电弹窗
  Widget _buildIncomingCallDialog(ChatMessage msg) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.videocam, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            "视频通话邀请",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            child: Text(
              msg.senderId[0].toUpperCase(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "来自 ${msg.senderId} 的视频通话",
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "是否接听？",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(main.globalContext);
                  sendVideoReject(msg.senderId, msg.roomId);
                  AnoToast.showToast("已拒绝通话", type: ToastType.info);
                },
                child: const Text("拒绝", style: TextStyle(color: Colors.red)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _acceptIncomingCall(msg),
                child: const Text("接听", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 接听来电的优化处理
  Future<void> _acceptIncomingCall(ChatMessage msg) async {
    Navigator.pop(main.globalContext);

    try {
      AnoToast.showToast("正在接听...", type: ToastType.info);

      // 初始化被叫方WebRTC
      await rtcCallController.initCall(
        isOffer: false,
        onSignalSend: (signalData) {
          _sendRtcSignalingMessage(
            senderId: authController.currentUser!.id,
            receiverId: msg.senderId,
            roomId: msg.roomId,
            signalData: signalData,
          );
        },
      );

      // 处理缓存的Offer
      final pendingOffer = _pendingOffers.remove(msg.senderId);
      if (pendingOffer != null) {
        _log("处理缓存的Offer");
        rtcCallController.handleSignal(pendingOffer, (signalData) {
          _sendRtcSignalingMessage(
            senderId: authController.currentUser!.id,
            receiverId: msg.senderId,
            roomId: msg.roomId,
            signalData: signalData,
          );
        });
      }

      // 导航到通话页面
      main.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder:
              (_) => VideoCallPage(isCaller: false, callTargetId: msg.senderId),
        ),
      );

      // 发送接听确认
      sendVideoAnswer(msg.senderId, msg.roomId);
    } catch (e) {
      _log("接听失败", e.toString());
      AnoToast.showToast("接听失败: ${e.toString()}", type: ToastType.error);
      rtcCallController.hangUp();
    }
  }

  /// 优化的发起通话方法
  void sendVideoCallRequest() {
    final currentUser = authController.currentUser;
    if (currentUser == null) {
      _log("错误: 用户未登录");
      return;
    }

    // 检查当前是否已在通话中
    if (rtcCallController.inCalling) {
      AnoToast.showToast("当前已在通话中", type: ToastType.warning);
      return;
    }

    final targetId = determineReceiverId(currentUser.id);
    if (targetId.isEmpty) {
      _log("错误: 无法确定通话目标");
      AnoToast.showToast("无法发起通话", type: ToastType.error);
      return;
    }

    _log("发起视频通话", "目标: $targetId");

    try {
      // 1. 发送通话请求信令
      final callMessage = ChatMessage(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUser.id,
        receiverId: targetId,
        roomId: chatRoom?.roomId,
        type: MessageType.videoCall,
        status: MessageStatus.sent,
        content: '发起视频通话',
        timestamp: DateTime.now(),
        attachments: [],
        metadata: {},
        read: [],
      );

      sendMessage(callMessage);
      _currentCallPeerId = targetId;

      // 2. 初始化主叫方WebRTC
      rtcCallController
          .initCall(
            isOffer: true,
            onSignalSend: (signalData) {
              _sendRtcSignalingMessage(
                senderId: currentUser.id,
                receiverId: targetId,
                roomId: chatRoom!.roomId,
                signalData: signalData,
              );
            },
          )
          .then((_) {
            // 3. 导航到通话页面
            main.navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder:
                    (_) =>
                        VideoCallPage(isCaller: true, callTargetId: targetId),
              ),
            );

            AnoToast.showToast("正在呼叫...", type: ToastType.info);
          })
          .catchError((e) {
            _log("通话初始化失败", e.toString());
            AnoToast.showToast("通话初始化失败", type: ToastType.error);
            rtcCallController.hangUp();
          });
    } catch (e) {
      _log("发起通话异常", e.toString());
      AnoToast.showToast("发起通话失败", type: ToastType.error);
    }
  }

  /// 优化的挂断方法
  void sendVideoHangup() {
    final currentUser = authController.currentUser;
    final targetId =
        _currentCallPeerId ??
        (currentUser != null ? determineReceiverId(currentUser.id) : '');

    if (currentUser == null || targetId.isEmpty) {
      _log("本地挂断", "无需发送信令");
      rtcCallController.hangUp();
      return;
    }

    _log("发送挂断信令", "目标: $targetId");

    try {
      final message = ChatMessage(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUser.id,
        receiverId: targetId,
        roomId: chatRoom?.roomId,
        type: MessageType.videoHangup,
        status: MessageStatus.sent,
        content: '视频通话已挂断',
        timestamp: DateTime.now(),
        attachments: [],
        metadata: {},
        read: [],
      );

      sendMessage(message);
      rtcCallController.hangUp();
      AnoToast.showToast("通话已结束", type: ToastType.info);
    } catch (e) {
      _log("发送挂断信令失败", e.toString());
      // 即使发送失败也要本地挂断
      rtcCallController.hangUp();
    } finally {
      _currentCallPeerId = null;
    }
  }

  /// 发送拒绝信令 - 优化版本
  void sendVideoReject(String receiverId, String roomId) {
    final currentUser = authController.currentUser;
    if (currentUser == null) return;

    _log("发送拒绝信令", "目标: $receiverId");

    try {
      final message = ChatMessage(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUser.id,
        receiverId: receiverId,
        roomId: roomId,
        type: MessageType.videoReject,
        status: MessageStatus.sent,
        content: '视频通话已拒绝',
        timestamp: DateTime.now(),
        attachments: [],
        metadata: {},
        read: [],
      );

      sendMessage(message);
      rtcCallController.hangUp();
    } catch (e) {
      _log("发送拒绝信令失败", e.toString());
      rtcCallController.hangUp();
    }
  }

  /// 发送接听信令 - 优化版本
  void sendVideoAnswer(String receiverId, String roomId) {
    final currentUser = authController.currentUser;
    if (currentUser == null) return;

    _log("发送接听信令", "目标: $receiverId");

    try {
      final message = ChatMessage(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUser.id,
        receiverId: receiverId,
        roomId: roomId,
        type: MessageType.videoAnswer,
        status: MessageStatus.sent,
        content: '视频通话已接听',
        timestamp: DateTime.now(),
        attachments: [],
        metadata: {},
        read: [],
      );

      sendMessage(message);
    } catch (e) {
      _log("发送接听信令失败", e.toString());
    }
  }

  /// 优化的WebRTC信令发送
  void _sendRtcSignalingMessage({
    required String senderId,
    required String receiverId,
    required String roomId,
    required Map<String, dynamic> signalData,
  }) {
    try {
      final message = ChatMessage(
        messageId: 'RTC_${DateTime.now().millisecondsSinceEpoch}',
        senderId: senderId,
        receiverId: receiverId,
        content: '',
        status: MessageStatus.sent,
        type: MessageType.signal,
        attachments: [],
        roomId: roomId,
        read: [],
        metadata: signalData,
        timestamp: DateTime.now(),
      );

      sendMessage(message);

      // 只记录关键信令类型，避免日志过多
      final signalType = signalData['type'] as String?;
      if (signalType == 'offer' || signalType == 'answer') {
        _log("发送WebRTC信令", "类型: $signalType, 目标: $receiverId");
      }
    } catch (e) {
      _log("发送WebRTC信令失败", e.toString());
    }
  }

  /// 日志辅助方法
  void _log(String message, [String? details]) {
    final timestamp = DateTime.now().toIso8601String();
    print('[ChatController][$timestamp] $message ${details ?? ''}');
  }

  /// 统一发送消息到 WebSocket
  void sendMessage(ChatMessage message) {
    _ws.send({
      "cmd": "chat",
      "token": authController.token,
      "senderId": message.senderId,
      "receiverId": message.receiverId,
      "content": message.content,
      "type": message.type.name,
      "roomId": message.roomId,
      "status": message.status.name,
      "attachments": message.attachments,
      "read": message.read,
      "metadata": message.metadata,
    });
  }

  void sendMessageRead() {}

  ///ListView 控制器 左侧列表
  final ScrollController scrollChatListController = ScrollController();

  final FlutterListViewController listViewController =
      FlutterListViewController();

  bool showScrollToBottom = true;

  void setScrollToBottom(bool isBottom) {
    showScrollToBottom = isBottom;
    notifyListeners();
  }

  ///
  /// 滚动到底部
  // void scrollToBottom() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     listViewController.animateTo(
  //       0,
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeOut,
  //     );
  //   });
  // }

  ///是否滚动
  bool _isScrolling = false;

  ///滚动延时计时器
  /// 滚动结束后才Hover ListTile颜色 优化
  Timer? _scrollStopTimer;

  bool get isScrolling => _isScrolling;

  void _onScroll() {
    if (!_isScrolling) {
      _isScrolling = true;
      notifyListeners();
    }

    _scrollStopTimer?.cancel();
    _scrollStopTimer = Timer(const Duration(milliseconds: 500), () {
      _isScrolling = false;
      notifyListeners();
    });
  }

  ///ListTile选择索引
  /// 选择切换 ChatDetail
  int _selectedIndex = -1;

  get selectIndex => _selectedIndex;

  ///切换左侧列表索引
  ///   选择切换 ChatDetail
  void setSelectIndex(int index) {
    _selectedIndex = index;
    setChatRoom = getRoom(index);
    notifyListeners();
  }

  @override
  void dispose() {
    _scrollStopTimer?.cancel();
    listViewController.dispose();
    super.dispose();
  }
}
