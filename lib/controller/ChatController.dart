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
import 'package:notepad/views/chat/Components/CallScreen.dart';

import '../common/domain/ChatEnumAll.dart';
import '../common/domain/ChatMessage.dart';
import '../common/module/AnoToast.dart';
import '../core/websocket_service.dart';

/// /// ChatController 核心控制器，负责聊天消息、用户、房间管理和 WebRTC 信令协调
class ChatController extends ChangeNotifier
    with UserMixin, RoomMixin, MessageMixin {
  final WebSocketService _ws = WebSocketService();
  late AuthController authController;
  late RtcCallController rtcCallController;

  ChatController({
    required this.authController,
    required this.rtcCallController,
  }) {
    ///滚动监听
    scrollChatListController.addListener(_onScroll);

    ///接受消息监听
    _ws.addListener((msg) {
      // print("Chat new Message:$msg");

      if (msg.code == "200") {
        final raw = msg.data;
        if (raw != null && raw['cmd'] == Cmd.chat.name) {
          final message = ChatMessage.fromJson(raw);

          if (message.type == MessageType.videoCall ||
              message.type == MessageType.videoAnswer ||
              message.type == MessageType.videoReject ||
              message.type == MessageType.videoHangup ||
              message.type == MessageType.signal) {
            handleIncoming(message);
            return;
          }

          addMessage(message, scrollToBottom, authController.currentUser!.id);
        }
        if (raw != null && raw['cmd'] == Cmd.http.name) {
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
      } else {
        AnoToast.showToast(msg.message, type: ToastType.error);
      }
    });
  }

  void handleIncoming(ChatMessage msg) {
    if (msg.senderId == authController.currentUser?.id) {
      return;
    }
    if (msg.type == MessageType.videoCall) {
      // 对方收到呼叫请求，弹窗
      DialogUtil.showGlobalDialog(showIncomingCallDialog(msg));
    } else if (msg.type == MessageType.videoHangup) {
      // 收到视频通话挂断请求
      AnoToast.showToast("对方已挂断通话", type: ToastType.info);
      rtcCallController.hangUp(); // 挂断本地通话
      // 可能需要关闭通话页面或弹窗
      if (main.navigatorKey.currentState?.canPop() ?? false) {
        main.navigatorKey.currentState?.pop(); // 关闭可能的通话页面
      }
    } else if (msg.type == MessageType.signal) {
      if (msg.metadata.isNotEmpty) {
        // WebRTC 信令处理
        rtcCallController.handleSignal(msg.metadata, (signalData) {
          sendMessage(
            ChatMessage(
              messageId: 'RTC',
              senderId: msg.receiverId,
              receiverId: msg.senderId,
              content: '',
              status: msg.status,
              type: MessageType.signal,
              attachments: [],
              roomId: msg.roomId,
              read: [],
              metadata: signalData,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    } else if (msg.type == MessageType.videoAnswer) {
      // 对方已接听，可切换 UI 状态或提示
    } else if (msg.type == MessageType.videoReject) {
      // 对方拒绝通话，做出 UI 提示并清理通话状态
    }
  }

  /// 显示来电弹窗
  Widget showIncomingCallDialog(ChatMessage msg) {
    return AlertDialog(
      title: const Text("收到视频通话请求"),
      content: Text("来自 ${msg.senderId} 的视频通话请求"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(main.globalContext);
            // 拒绝通话，发送挂断信令
            sendVideoHangup();
            AnoToast.showToast("已拒绝通话", type: ToastType.info);
          },
          child: const Text("拒绝"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(main.globalContext);
            // 接听通话，并初始化 WebRTC 为被叫方
            rtcCallController.initCall(
              isOffer: false,
              onSignalSend: (signalData) {
                sendMessage(
                  ChatMessage(
                    messageId: 'RTC_Answer', // 适当的 messageId
                    senderId: authController.currentUser!.id, // 确保是你自己
                    receiverId: msg.senderId, // 回复给呼叫方
                    content: '',
                    status: MessageStatus.sent,
                    type: MessageType.signal, // 发送信令类型
                    attachments: [],
                    roomId: msg.roomId,
                    read: [],
                    metadata: signalData, // 实际的 WebRTC 信令
                    timestamp: DateTime.now(),
                  ),
                );
              },
            );
            AnoToast.showToast("正在接听...", type: ToastType.info);
            // 导航到视频通话页面 (如果需要独立页面)
            Navigator.push(
              main.globalContext,
              MaterialPageRoute(
                builder: (_) => const VideoCallPage(isCaller: false), // 主叫方
              ),
            );
          },
          child: const Text("接听"),
        ),
      ],
    );
  }

  /// 发送视频通话呼叫请求
  void sendVideoCallRequest() {
    final currentUser = authController.currentUser;
    if (currentUser == null) return;

    final message = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUser.id,
      receiverId: determineReceiverId(currentUser.id),
      roomId: chatRoom?.roomId,
      type: MessageType.videoCall, // 视频通话呼叫类型
      status: MessageStatus.sent,
      content: '发起视频通话',
      timestamp: DateTime.now(),
      attachments: [],
      metadata: {},
      read: [],
    );
    sendMessage(message);
    AnoToast.showToast("已发起视频通话请求...", type: ToastType.info);
    rtcCallController.initCall(
      isOffer: true,
      onSignalSend: (signalData) {
        sendMessage(
          ChatMessage(
            messageId: 'RTC_Offer', // 适当的 messageId
            senderId: currentUser.id,
            receiverId: determineReceiverId(currentUser.id),
            content: '',
            status: MessageStatus.sent,
            type: MessageType.signal,
            attachments: [],
            roomId: chatRoom?.roomId,
            read: [],
            metadata: signalData,
            timestamp: DateTime.now(),
          ),
        );
      },
    ); // 作为主叫方初始化 WebRTC
    Navigator.push(
      main.globalContext,
      MaterialPageRoute(
        builder: (_) => const VideoCallPage(isCaller: true), // 主叫方
      ),
    );
  }

  /// 发送视频通话挂断/拒绝信令
  void sendVideoHangup() {
    final currentUser = authController.currentUser;
    if (currentUser == null) return;

    final message = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUser.id,
      receiverId: determineReceiverId(currentUser.id),
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
  /// 滚动到顶部
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
  ///   选择切换 ChatDetail
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
