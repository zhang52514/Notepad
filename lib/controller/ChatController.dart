import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:notepad/controller/AuthController.dart';
import 'package:notepad/controller/mixin/MessageMixin.dart';
import 'package:notepad/controller/mixin/RoomMixin.dart';
import 'package:notepad/controller/mixin/UserMixin.dart';

import '../common/domain/ChatEnumAll.dart';
import '../common/domain/ChatMessage.dart';
import '../common/module/AnoToast.dart';
import '../core/websocket_service.dart';

///
///
/// ChatController core controller
class ChatController extends ChangeNotifier
    with UserMixin, RoomMixin, MessageMixin {
  final WebSocketService _ws = WebSocketService();
  late AuthController authController;

  ChatController({required this.authController}) {
    ///滚动监听
    scrollChatListController.addListener(_onScroll);

    ///接受消息监听
    _ws.addListener((msg) {
      // print("Chat new Message:$msg");

      if (msg.code == "200") {
        final raw = msg.data;
        if (raw != null && raw['cmd'] == Cmd.chat.name) {
          final message = ChatMessage.fromJson(raw);
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

  ///
  /// 发送消息
  void sendMessage(ChatMessage message) {
    _ws.send({
      "cmd": "chat",
      "token": authController.token,
      "senderId": message.senderId,
      "receiverId": message.receiverId,
      "content": message.content,
      "type": message.type.name,
      "roomId": chatRoom?.roomId,
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
