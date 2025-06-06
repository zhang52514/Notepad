import 'package:flutter/material.dart';
import 'package:notepad/controller/mixin/RoomMixin.dart';

import '../../common/domain/ChatMessage.dart';
import '../../core/websocket_service.dart';

mixin MessageMixin on ChangeNotifier, RoomMixin {
  ///
  /// k->v k=roomId,v= List ChatMessage 聊天消息
  Map<String, List<ChatMessage>> _roomMessages = {};

  get roomMessages => _roomMessages;

  ///初始化
  initMessage(WebSocketService ws, String token, String id,int limit) {
    ws.http("/getHistory", token, {"id":id,"limit": limit});
  }

  void setMessage(Map<String, dynamic> data) {
    data.forEach((roomId, messagesList) {
      if (messagesList is List) {
        _roomMessages[roomId] =
            messagesList
                .whereType<Map<String, dynamic>>()
                .map((e) => ChatMessage.fromJson(e))
                .toList();
      }
    });

    notifyListeners();
  }

  /// 获取某个房间的所有消息列表
  /// 注意：返回的是副本，避免外部直接修改导致UI不更新
  List<ChatMessage> getMessagesForRoom() {
    String roomId = getCurrentRoomId();
    return _roomMessages[roomId]?.reversed.toList() ?? [];
  }

  // 添加一条新消息到指定房间
  void addMessage(ChatMessage message, VoidCallback scrollToBottom) {
    String roomId = getCurrentRoomId();
    if (!_roomMessages.containsKey(roomId)) {
      _roomMessages[roomId] = []; // 如果房间不存在，则创建一个新的消息列表
    }
    // 添加消息
    _roomMessages[roomId]!.add(message);
    //房间添加最后一条消息
    chatRoom?.roomLastMessage = message.content;

    if (_roomMessages[roomId]!.length > 4) {
      scrollToBottom();
    }

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
}
