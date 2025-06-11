import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notepad/common/domain/ChatEnumAll.dart';
import 'package:notepad/common/domain/ChatUser.dart';
import 'package:notepad/controller/mixin/UserMixin.dart';

import '../../common/domain/ChatRoom.dart';
import '../../core/websocket_service.dart';

mixin RoomMixin on ChangeNotifier ,UserMixin{
  ///
  /// ChatRoom List
  final List<ChatRoom> _chatroomList = [];
  get chatroomList => _chatroomList;

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

  void setRooms(List<dynamic> data, String uid) {
    // 1. 清空旧列表
    _chatroomList.clear();

    // 2. 填充房间列表
    _chatroomList.addAll(
        data.map((item) => ChatRoom.fromJson(item as Map<String, dynamic>))
    );

    // 3. 单聊房间重命名为对方用户信息
    for (var room in _chatroomList) {
      if (room.roomType == ChatRoomType.single) {
        // 找到“不等于当前 uid” 的那个成员
        final otherId = room.memberIds.firstWhere(
              (memberId) => memberId != uid,
          orElse: () => '',
        );
        if (otherId.isNotEmpty && users.containsKey(otherId)) {
          final user = users[otherId]!;
          room.roomName = user.nickname;
          room.roomAvatar = user.avatarUrl;
        }
      }
    }

    // 4. 通知 UI 更新
    notifyListeners();
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

  /// 获取当前房间id
  String getCurrentRoomId() {
    return _chatRoom?.roomId ?? "";
  }

  /// 获取当前房间成员列表
  /// 如果当前房间不存在，返回空列表
  List<ChatUser> getRoomMembers() {
    if (_chatRoom == null) return [];
    return _chatRoom!.memberIds.map((id) => users[id]!).toList();
  }
}
