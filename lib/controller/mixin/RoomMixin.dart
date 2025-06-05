import 'package:flutter/material.dart';

import '../../common/domain/ChatRoom.dart';
import '../../core/websocket_service.dart';

mixin RoomMixin on ChangeNotifier {
  ///
  /// ChatRoom List
  final List<ChatRoom> _chatroomList = [];

  /// 当前房间
  ChatRoom? _chatRoom;

  get chatRoom => _chatRoom;

  set setChatRoom(ChatRoom? room) {
    _chatRoom = room;
  }

  ///初始化ROOM
  initRoom(WebSocketService ws, String token, String id) {
    ws.http("/getRooms", token, {"id": id});
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

  String getCurrentRoomId() {
    return _chatRoom?.roomId ?? "";
  }
}
