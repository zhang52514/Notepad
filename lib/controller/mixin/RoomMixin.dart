import 'package:flutter/material.dart';

import '../../common/domain/ChatRoom.dart';

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

  initRoom() {
    //模拟后端返回
    _chatroomList.add(
      ChatRoom(
        roomId: 100,
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
        roomType: RoomType.private,
        memberIds: [1, 101],
      ),
    );
    _chatroomList.add(
      ChatRoom(
        roomId: 200,
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
        roomType: RoomType.private,
        memberIds: [1, 102],
      ),
    );
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

  int getCurrentRoomId(){
    return _chatRoom?.roomId ?? -1;
  }

}
