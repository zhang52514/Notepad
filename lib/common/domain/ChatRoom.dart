import 'package:notepad/common/domain/ChatMessage.dart';
import 'package:notepad/common/domain/ChatUser.dart';

class ChatRoom {
  String roomId;
  String roomName;
  String roomAvatar;
  String roomDescription;
  String roomLastMessage;
  DateTime roomLastMessageTime;
  int roomUnreadCount;
  int roomCreateTime;
  int roomUpdateTime;
  int roomStatus;
  int roomType;
  List<int> memberIds;

  ChatRoom({
    required this.roomId,
    required this.roomName,
    required this.roomAvatar,
    required this.roomDescription,
    required this.roomLastMessage,
    required this.roomLastMessageTime,
    required this.roomUnreadCount,
    required this.roomCreateTime,
    required this.roomUpdateTime,
    required this.roomStatus,
    required this.memberIds,
    required this.roomType,
  });

  @override
  String toString() {
    return 'ChatRoom{roomId: $roomId, roomName: $roomName, roomAvatar: $roomAvatar, roomDescription: $roomDescription, roomLastMessage: $roomLastMessage, roomLastMessageTime: $roomLastMessageTime, roomUnreadCount: $roomUnreadCount, roomCreateTime: $roomCreateTime, roomUpdateTime: $roomUpdateTime, roomStatus: $roomStatus, roomType: $roomType}';
  }
}
