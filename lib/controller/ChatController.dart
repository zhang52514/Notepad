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
import 'package:notepad/views/chat/Components/CallScreen.dart'; // 确认此路径指向 VideoCallPage

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
            addMessage(message, scrollToBottom, authController.currentUser!.id);
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

  /// 处理所有 WebRTC 相关的信令消息
  void _handleRtcSignalingMessage(ChatMessage msg) {
    // 如果是自己发送的信令（防止自发自收，尽管通常服务端会处理）
    if (msg.senderId == authController.currentUser?.id) {
      // 可以在这里处理自己发送信令后的UI反馈，例如等待对方接听等
      return;
    }

    _currentCallPeerId = msg.senderId; // 记录当前通话的对方ID

    switch (msg.type) {
      case MessageType.videoCall:
        // 收到视频通话请求 (被叫方)
        AnoToast.showToast(
          "收到来自 ${msg.senderId} 的视频通话请求",
          type: ToastType.info,
        );
        DialogUtil.showGlobalDialog(_buildIncomingCallDialog(msg));
        break;
      case MessageType.videoAnswer:
        // 对方已接听 (主叫方收到)
        AnoToast.showToast("对方已接听", type: ToastType.info);
        // 如果当前通话页面已存在，不需要重复导航
        // 确保 rtcCallController 已经根据 isOffer:true 初始化
        if (!rtcCallController.inCalling) {
          // 重新初始化或处理异常
        }
        break;
      case MessageType.videoReject:
        // 对方拒绝通话 (主叫方收到)
        AnoToast.showToast("对方已拒绝通话", type: ToastType.info);
        rtcCallController.hangUp(); // 本地挂断并清理资源
        // 关闭可能的通话页面
        _popVideoCallPageIfOpen();
        break;
      case MessageType.videoHangup:
        // 对方已挂断 (双方都可能收到)
        AnoToast.showToast("对方已挂断通话", type: ToastType.info);
        rtcCallController.hangUp(); // 本地挂断并清理资源
        // 关闭可能的通话页面
        _popVideoCallPageIfOpen();
        break;
      case MessageType.signal:
        // WebRTC 信令 (SDP Offer/Answer, ICE Candidate)
        if (msg.metadata.isNotEmpty) {
          if (msg.metadata['type'] == 'offer') {
            // 如果是Offer且当前不在通话中，先缓存
            if (!rtcCallController.inCalling) {
              _pendingOffers[msg.senderId] = msg.metadata;
              return;
            }
          }
          rtcCallController.handleSignal(msg.metadata, (signalData) {
            // 当 RtcCallController 内部生成新的信令时，通过此回调发送给对方
            _sendRtcSignalingMessage(
              senderId: authController.currentUser!.id,
              receiverId: msg.senderId, // 回复给信令的发送方
              roomId: msg.roomId,
              signalData: signalData,
            );
          });
        }
        break;
      default:
        // 其他消息类型不处理
        break;
    }
  }

  /// 构建来电弹窗
  Widget _buildIncomingCallDialog(ChatMessage msg) {
    return AlertDialog(
      title: const Text("收到视频通话请求"),
      content: Text("来自 ${msg.senderId} 的视频通话请求"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(main.globalContext); // 关闭弹窗
            sendVideoReject(msg.senderId, msg.roomId); // 发送拒绝信令
            AnoToast.showToast("已拒绝通话", type: ToastType.info);
          },
          child: const Text("拒绝"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(main.globalContext); // 关闭弹窗
            AnoToast.showToast("正在接听...", type: ToastType.info);

            try {
              // 作为被叫方初始化 WebRTC
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
              final pendingOffer = _pendingOffers[msg.senderId];
              if (pendingOffer != null) {
                rtcCallController.handleOffer(pendingOffer, (signalData) {
                  _sendRtcSignalingMessage(
                    senderId: authController.currentUser!.id,
                    receiverId: msg.senderId,
                    roomId: msg.roomId,
                    signalData: signalData,
                  );
                });
                _pendingOffers.remove(msg.senderId);
              }

              // 导航到视频通话页面，并传入必要的参数
              main.navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder:
                      (_) => VideoCallPage(
                        isCaller: false, // 被叫方
                        callTargetId: msg.senderId, // 呼叫方ID
                      ),
                ),
              );

              // 接听成功后，向对方发送接听信令（可选，如果需要明确状态）
              sendVideoAnswer(msg.senderId, msg.roomId);
            } catch (e) {
              AnoToast.showToast(
                "接听失败: ${e.toString()}",
                type: ToastType.error,
              );
              rtcCallController.hangUp(); // 确保清理资源
              _popVideoCallPageIfOpen(); // 确保关闭页面
            }
          },
          child: const Text("接听"),
        ),
      ],
    );
  }

  /// 发送视频通话呼叫请求 (主叫方)
  void sendVideoCallRequest() {
    final currentUser = authController.currentUser;
    final targetId = determineReceiverId(currentUser!.id); // 确定呼叫目标ID

    if (currentUser == null || targetId == null) {
      AnoToast.showToast("无法发起通话：用户未登录或未选择通话对象", type: ToastType.error);
      return;
    }

    // 1. 发送 'videoCall' 消息给对方，告知其有来电
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
    AnoToast.showToast("已发起视频通话请求...", type: ToastType.info);

    _currentCallPeerId = targetId; // 记录当前通话的对方ID

    // 2. 作为主叫方初始化 WebRTC
    rtcCallController
        .initCall(
          isOffer: true,
          onSignalSend: (signalData) {
            // 当 RtcCallController 内部生成新的信令时，通过此回调发送给对方
            _sendRtcSignalingMessage(
              senderId: currentUser.id,
              receiverId: targetId,
              roomId: chatRoom.roomId,
              signalData: signalData,
            );
          },
        )
        .then((_) {
          // 3. 初始化成功后，导航到视频通话页面
          main.navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder:
                  (_) => VideoCallPage(
                    isCaller: true, // 主叫方
                    callTargetId: targetId, // 呼叫目标ID
                  ),
            ),
          );
        })
        .catchError((e) {
          AnoToast.showToast(
            "视频通话初始化失败: ${e.toString()}",
            type: ToastType.error,
          );
          rtcCallController.hangUp(); // 确保清理资源
          _popVideoCallPageIfOpen(); // 确保关闭页面
        });
  }

  /// 发送视频通话拒绝信令
  void sendVideoReject(String receiverId, String roomId) {
    final currentUser = authController.currentUser;
    if (currentUser == null) return;

    final message = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUser.id,
      receiverId: receiverId,
      roomId: roomId,
      type: MessageType.videoReject, // 视频通话拒绝类型
      status: MessageStatus.sent,
      content: '视频通话已拒绝',
      timestamp: DateTime.now(),
      attachments: [],
      metadata: {},
      read: [],
    );
    sendMessage(message);
    rtcCallController.hangUp(); // 挂断本地通话
    _popVideoCallPageIfOpen(); // 关闭可能的通话页面
  }

  /// 发送视频通话接听信令
  void sendVideoAnswer(String receiverId, String roomId) {
    final currentUser = authController.currentUser;
    if (currentUser == null) return;

    final message = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUser.id,
      receiverId: receiverId,
      roomId: roomId,
      type: MessageType.videoAnswer, // 视频通话接听类型
      status: MessageStatus.sent,
      content: '视频通话已接听',
      timestamp: DateTime.now(),
      attachments: [],
      metadata: {},
      read: [],
    );
    sendMessage(message);
  }

  /// 发送视频通话挂断信令
  void sendVideoHangup() {
    final currentUser = authController.currentUser;
    final targetId =
        _currentCallPeerId ??
        determineReceiverId(currentUser!.id); // 优先使用当前通话对象

    if (currentUser == null || targetId == null) {
      // 如果没有正在进行的通话对象，可能不需要发送挂断信令，只清理本地状态
      rtcCallController.hangUp();
      _popVideoCallPageIfOpen();
      AnoToast.showToast("已挂断本地通话", type: ToastType.info);
      return;
    }

    final message = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUser.id,
      receiverId: targetId,
      roomId: chatRoom?.roomId,
      type: MessageType.videoHangup, // 视频通话挂断类型
      status: MessageStatus.sent,
      content: '视频通话已挂断',
      timestamp: DateTime.now(),
      attachments: [],
      metadata: {},
      read: [],
    );
    sendMessage(message);
    rtcCallController.hangUp(); // 挂断本地通话
    AnoToast.showToast("已挂断通话", type: ToastType.info);
    _popVideoCallPageIfOpen(); // 关闭可能的通话页面
  }

  /// 内部辅助函数，用于发送 WebRTC 信令消息
  void _sendRtcSignalingMessage({
    required String senderId,
    required String receiverId,
    required String roomId,
    required Map<String, dynamic> signalData,
  }) {
    sendMessage(
      ChatMessage(
        messageId: 'RTC_${DateTime.now().millisecondsSinceEpoch}', // 唯一ID
        senderId: senderId,
        receiverId: receiverId,
        content: '',
        status: MessageStatus.sent,
        type: MessageType.signal,
        attachments: [],
        roomId: roomId,
        read: [],
        metadata: signalData, // 实际的 WebRTC 信令
        timestamp: DateTime.now(),
      ),
    );
  }

  /// 辅助函数：关闭当前导航栈中的 VideoCallPage（如果有的话）
  void _popVideoCallPageIfOpen() {
    // 这里只能简单地 pop，如果可以 pop 的话
    if (main.navigatorKey.currentState?.canPop() ?? false) {
      main.navigatorKey.currentState?.pop();
    }
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
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      listViewController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

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
