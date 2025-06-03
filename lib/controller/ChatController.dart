import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:notepad/common/domain/ChatRoom.dart';
import 'package:notepad/common/domain/ChatUser.dart';
import 'package:notepad/controller/AuthController.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../common/domain/ChatMessage.dart';
import '../common/module/AnoToast.dart';
import '../core/websocket_service.dart';

class ChatController extends ChangeNotifier {
  ///
  /// 核心
  ///================================================================
  ///
  final WebSocketService _service = WebSocketService();
  late AuthController authController;
  final List<ChatRoom> _chatroomList = [];
  final Map<String, List<ChatMessage>> _roomMessages = {};
  final List<ChatUser> _users = [];

  ChatController({required this.authController}) {
    ///滚动监听
    scrollChatListController.addListener(_onScroll);
    _service.addListener((msg) {
      print("Chat new Message:$msg");
      if (msg.code == "200" && msg.data != null) {
      }else{
        AnoToast.showToast(msg.message,type: ToastType.error);
      }
    });
    _initData();
  }

  ///初始化数据
  _initData() {
    var u1 = ChatUser(
      uid: 101,
      nickname: 'test-02',
      avatarUrl: 'https://img.keaitupian.cn/newupload/11/1668492556474791.jpg',
    );
    var u2 = ChatUser(
      uid: 102,
      nickname: 'text-03',
      avatarUrl:
          'https://c-ssl.dtstatic.com/uploads/blog/202212/18/20221218144515_64111.thumb.1000_0.jpg',
    );
    var u3 = ChatUser(
      uid: 1,
      nickname: 'admin',
      avatarUrl:
          'https://c-ssl.duitang.com/uploads/blog/202107/17/20210717100716_31038.jpg',
    );
    //模拟后端返回
    _chatroomList.add(
      ChatRoom(
        roomId: 'room1',
        roomName: '私聊测试1',
        roomAvatar:
            'https://img.keaitupian.cn/newupload/11/1668492556474791.jpg',
        roomDescription: '私聊测试1描述',
        roomLastMessage: '',
        roomLastMessageTime: DateTime.now(),
        roomUnreadCount: 0,
        roomCreateTime: 1920902,
        roomUpdateTime: 1920902,
        roomStatus: 0,
        roomType: 0,
        memberIds: [1,1],
      ),
    );
    _chatroomList.add(
      ChatRoom(
        roomId: 'room2',
        roomName: '私聊测试2',
        roomAvatar:
            'https://c-ssl.dtstatic.com/uploads/blog/202212/18/20221218144515_64111.thumb.1000_0.jpg',
        roomDescription: '私聊测试2描述',
        roomLastMessage: '',
        roomLastMessageTime: DateTime.now(),
        roomUnreadCount: 0,
        roomCreateTime: 1920902,
        roomUpdateTime: 1920902,
        roomStatus: 0,
        roomType: 0,
        memberIds: [2,1],
      ),
    );
    _users.add(u1);
    _users.add(u2);
    _users.add(u3);
    _chatRoom = _chatroomList[0];
  }

  ///
  ///核心
  ///================================================================

  /// 当前房间ID
  late ChatRoom _chatRoom;

  get chatRoom => _chatRoom;

  /// 获取某个房间的所有消息列表
  /// 注意：返回的是副本，避免外部直接修改导致UI不更新
  List<ChatMessage> getMessagesForRoom() {
    return _roomMessages[_chatRoom.roomId]?.reversed.toList() ?? [];
  }

  ///
  /// 获取房间列表数量
  int getRoomCount() {
    return _chatroomList.length;
  }

  ///
  /// 获取房间未读消息数量
  int getRoomUnReadCount(int index) {
    return _chatroomList[index].roomUnreadCount;
  }

  ///
  /// 获取房间
  ChatRoom getRoom(int index) {
    return _chatroomList[index];
  }
  ///
  /// 获取所有房间成员 除了自己
  int getRoomMembersExceptSelf() {
    return 0;
    // return _chatRoom.memberIds
    //     .where((memberId) => memberId != authController.currentUser!.uid)
    //     .join(','); // 可以替换成你想要的分隔符，比如 '|' 或 ';'
  }

  ///
  /// 获取用户
  ChatUser getUser(int uid) {
    return _users.firstWhere(
      (u) => u.uid == uid,
      orElse: () => ChatUser(uid: uid, nickname: '未知用户', avatarUrl: ''),
    );
  }

  // 添加一条新消息到指定房间
  void addMessage(ChatMessage message) {
    if (!_roomMessages.containsKey(_chatRoom.roomId)) {
      _roomMessages[_chatRoom.roomId] = []; // 如果房间不存在，则创建一个新的消息列表
    }
    // 添加消息
    _roomMessages[_chatRoom.roomId]!.add(message);
    //房间添加最后一条消息
    _chatRoom.roomLastMessage = message.content;

    if (_roomMessages[_chatRoom.roomId]!.length > 4) {
      scrollToBottom();
    }

    _service.send({
      "cmd": "chat",
      "token": authController.token,
      "senderId": message.senderId,
      "receiverId": message.receiverId,
      "content": message.content,
      "type": message.type.name,
      "roomId": _chatRoom.roomId,
    });
    notifyListeners();
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
  final ScrollController scrollChatListController = ScrollController();

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

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
    _chatRoom = getRoom(index);
    notifyListeners();
  }

  @override
  void dispose() {
    scrollChatListController.dispose();
    _scrollStopTimer?.cancel();
    super.dispose();
  }
}
