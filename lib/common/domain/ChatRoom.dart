import 'ChatEnumAll.dart';

/// ChatRoom类代表一个聊天室的信息。
/// 它封装了聊天室的各种属性，如房间ID、名称、头像、描述、最后一条消息等。
/// 该类还包含了成员ID列表和成员角色的映射，用于管理聊天室成员和他们的权限。
class ChatRoom {
  /// 聊天室的唯一标识符。
  String roomId;

  /// 聊天室的名称。
  String roomName;

  /// 聊天室的头像URL或路径。
  String roomAvatar;

  /// 聊天室的描述。
  String roomDescription;

  /// 聊天室的最后一条消息内容。
  String roomLastMessage;

  /// 聊天室最后一条消息发送的时间。
  DateTime roomLastMessageTime;

  /// 聊天室的未读消息计数。
  int roomUnreadCount;

  /// 聊天室的状态码，用于表示聊天室的不同状态（如活跃、静默等）。
  ChatRoomStatus roomStatus;

  /// 聊天室的类型，可能是一个枚举类型，表示不同的聊天室类别（如公共、私有等）。
  ChatRoomType roomType;

  /// 聊天室成员的ID列表，用于记录谁是该聊天室的成员。
  List<String> memberIds;

  /// 聊天室成员的角色映射，键是成员ID，值是该成员在聊天室中的角色。
  /// 这用于快速查找特定成员的角色和权限。
  Map<String, ChatUserRole> memberRoles;

  ChatRoom({
    required this.roomId,
    required this.roomName,
    required this.roomAvatar,
    required this.roomDescription,
    required this.roomLastMessage,
    required this.roomLastMessageTime,
    required this.roomUnreadCount,
    required this.roomStatus,
    required this.memberIds,
    required this.roomType,
    required this.memberRoles,
  });

  Map<String, dynamic> toJson() => {
    'roomId': roomId,
    'roomName': roomName,
    'roomAvatar': roomAvatar,
    'roomDescription': roomDescription,
    'roomLastMessage': roomLastMessage,
    'roomLastMessageTime': roomLastMessageTime.toIso8601String(),
    'roomUnreadCount': roomUnreadCount,
    'roomStatus': roomStatus.name,
    'roomType': roomType.name,
    'memberIds': memberIds,
    'memberRoles': memberRoles.map((k, v) => MapEntry(k, v.name)),
  };

  static ChatRoom fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      roomId: json['roomId'] ?? '',
      roomName: json['roomName'] ?? '',
      roomAvatar: json['roomAvatar'] ?? '',
      roomDescription: json['roomDescription'] ?? '',
      roomLastMessage: json['roomLastMessage'] ?? '',
      // 这里json里如果没有roomLastMessageTime或为空，默认当前时间，避免异常
      roomLastMessageTime: json['roomLastMessageTime'] != null
          ? DateTime.parse(json['roomLastMessageTime'])
          : DateTime.now(),
      // 这个字段示例中没出现，给默认值0
      roomUnreadCount: json['roomUnreadCount'] ?? 0,
      roomStatus: json['roomStatus'] != null
          ? ChatRoomStatus.values.byName(json['roomStatus'])
          : ChatRoomStatus.normal, // 根据你枚举定义给默认值
      roomType: json['roomType'] != null
          ? ChatRoomType.values.byName(json['roomType'])
          : ChatRoomType.single, // 根据你枚举定义给默认值
      memberIds: json['memberIds'] != null
          ? List<String>.from(json['memberIds'])
          : [],
      memberRoles: json['memberRoles'] != null
          ? Map<String, ChatUserRole>.from(
        (json['memberRoles'] as Map).map(
              (k, v) => MapEntry(k, ChatUserRole.values.byName(v)),
        ),
      )
          : {},
    );
  }

}
