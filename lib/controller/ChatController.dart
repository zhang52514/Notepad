import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:notepad/controller/AuthController.dart';
import 'package:notepad/controller/mixin/MessageMixin.dart';
import 'package:notepad/controller/mixin/RoomMixin.dart';
import 'package:notepad/controller/mixin/UserMixin.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../common/domain/ChatMessage.dart';
import '../common/module/AnoToast.dart';
import '../core/websocket_service.dart';

///
///
/// ChatController core controller
class ChatController extends ChangeNotifier
    with RoomMixin, UserMixin, MessageMixin {
  final WebSocketService _ws = WebSocketService();
  late AuthController authController;

  ChatController({required this.authController}) {
    ///滚动监听
    scrollChatListController.addListener(_onScroll);
    _ws.addListener((msg) {
      print("Chat new Message:$msg");

      final raw = msg.data;

      if (msg.code == "200" && raw != null && raw['cmd'] == 'chat') {
        final message = ChatMessage.fromJson(raw);
        addMessage(message, scrollToBottom);
      } else {
        AnoToast.showToast(msg.message, type: ToastType.error);
      }
    });
    _initData();
  }

  ///初始化数据
  _initData() {
    String token=authController.token!;
    initUser();
    initRoom(_ws,token,authController.currentUser!.id);
    addUser(authController.currentUser!);
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
    });
  }

  ///ListView 控制器 左侧列表
  final ScrollController scrollChatListController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  ///
  /// 滚动到顶部
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (itemScrollController.isAttached) {
        itemScrollController.scrollTo(
          index: 0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
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
    scrollChatListController.dispose();
    _scrollStopTimer?.cancel();
    super.dispose();
  }
}
