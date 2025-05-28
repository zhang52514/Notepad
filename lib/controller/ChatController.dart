import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../common/domain/ChatMessage.dart';

class ChatController extends ChangeNotifier {

  ///
  /// 核心 消息列表
  ///

  final Map<String,List<ChatMessage>> _roomMessages  = {};
  /// 获取某个房间的所有消息列表
  /// 注意：返回的是副本，避免外部直接修改导致UI不更新
  List<ChatMessage> getMessagesForRoom(String roomId) {
    return _roomMessages[roomId] ?? [];
  }
  // 添加一条新消息到指定房间
  void addMessage(String roomId, ChatMessage message) {
    if (!_roomMessages.containsKey(roomId)) {
      _roomMessages[roomId] = []; // 如果房间不存在，则创建一个新的消息列表
    }
    _roomMessages[roomId]!.add(message);
    notifyListeners(); // 通知所有监听者数据已更新
  }

  // 批量添加消息到指定房间 (例如：从历史记录加载)
  void addMessagesBatch(String roomId, List<ChatMessage> messages) {
    if (!_roomMessages.containsKey(roomId)) {
      _roomMessages[roomId] = [];
    }
    _roomMessages[roomId]!.addAll(messages);

    notifyListeners();
  }

  // 更新某条消息的状态 (例如：已读)
  void updateMessageStatus(String roomId, String messageId, {bool? isRead}) {
    final messages = _roomMessages[roomId];
    if (messages != null) {
      final index = messages.indexWhere((msg) => msg.messageId == messageId);
      if (index != -1) {
        final originalMessage = messages[index];
        // messages[index] = ChatMessage(
        //   id: originalMessage.id,
        //   senderId: originalMessage.senderId,
        //   content: originalMessage.content,
        //   timestamp: originalMessage.timestamp,
        //   isRead: isRead ?? originalMessage.isRead, // 更新指定字段
        //   type: originalMessage.type,
        // );
        notifyListeners();
      }
    }
  }

  // 清空某个房间的所有消息
  void clearRoomMessages(String roomId) {
    if (_roomMessages.containsKey(roomId)) {
      _roomMessages.remove(roomId);
      notifyListeners();
    }
  }

  // 清空所有房间的消息 (例如：用户登出)
  void clearAllMessages() {
    _roomMessages.clear();
    notifyListeners();
  }

  // 获取所有房间ID
  Set<String> getAllRoomIds() {
    return _roomMessages.keys.toSet();
  }

  // 可以在这里添加更多业务逻辑，例如：
  // - 从本地存储加载消息 (SQLite, Hive, Shared Preferences)
  // - 处理消息发送失败/成功的状态
  // - 获取未读消息计数


  ///ListView 控制器 左侧列表
  final ScrollController scrollController = ScrollController();

  ///是否滚动
  bool _isScrolling = false;

  ///滚动延时计时器
  /// 滚动结束后才Hover ListTile颜色 优化
  Timer? _scrollStopTimer;

  bool get isScrolling => _isScrolling;

  ChatController() {
    ///监听滚动
    scrollController.addListener(_onScroll);
  }

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

  void setSelectIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }



  @override
  void dispose() {
    scrollController.dispose();
    _scrollStopTimer?.cancel();
    super.dispose();
  }
}
