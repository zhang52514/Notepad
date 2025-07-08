import 'ChatEnumAll.dart';

/// ChatMessage类代表一条聊天消息。
/// 它封装了消息的各种属性，如消息ID、发送者ID、接收者ID、消息内容等。
/// 此类还包含了消息的状态、类型、附件信息以及阅读和元数据信息。
class ChatMessage {
  /// 房间ID，表示消息所属的聊天房间。
  String roomId;

  /// 消息ID，用于唯一标识一条消息。
  String messageId;

  /// 发送者ID，表示消息的发送者。
  String senderId;

  /// 接收者ID，表示消息的接收者。
  String receiverId;

  /// 消息内容，包含实际的文本信息。
  String content;

  /// 消息状态，表示消息的发送或接收状态。
  MessageStatus status;

  /// 消息类型，如文本、图片等。
  MessageType type;

  /// 附件列表，包含消息的所有附件。
  List<Attachment> attachments;

  /// 已读列表，记录已读消息ID。
  List<String> read;

  /// 元数据，用于存储额外的信息。
  Map<String, dynamic> metadata;

  /// 时间戳，表示消息发送的时间。
  DateTime? timestamp;

  /// ChatMessage构造函数，初始化消息对象。
  /// 参数均为必需，以确保每条消息都有完整的属性。
  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.status,
    required this.type,
    required this.attachments,
    required this.roomId,
    required this.read,
    required this.metadata,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'senderId': senderId,
    'receiverId': receiverId,
    'content': content,
    'status': status.name,
    'type': type.name,
    'attachments': attachments.map((e) => e.toJson()).toList(),
    'roomId': roomId,
    'read': read,
    'metadata': metadata,
    'timestamp': timestamp?.toIso8601String(),
  };

  static ChatMessage fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      content: json['content'] ?? '',
      status: MessageStatus.values.byName(json['status']),
      type: MessageType.values.byName(json['type']),
      attachments:
          (json['attachments'] as List<dynamic>? ?? [])
              .map((e) => Attachment.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
      roomId: json['roomId'] ?? '',
      read: List<String>.from(json['read'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      timestamp:
          json['timestamp'] != null
              ? DateTime.tryParse(json['timestamp'])
              : null,
    );
  }
}

/// Attachment类代表一个附件。
/// 它包含了附件的URL、名称、类型和大小等信息。
class Attachment {
  /// 附件的URL，用于访问附件资源。
  String url;

  /// 附件的名称，便于识别附件。
  String name;

  /// 附件的类型，如图片、文档等。
  String type;

  /// 附件的大小，以字节为单位。
  int size;

  /// Attachment构造函数，初始化附件对象。
  /// 所有参数均为必需，以确保附件信息的完整性。
  Attachment({
    required this.url,
    required this.name,
    required this.type,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
    'url': url,
    'name': name,
    'type': type,
    'size': size,
  };

  static Attachment fromJson(Map<String, dynamic> json) => Attachment(
    url: json['url'],
    name: json['name'],
    type: json['type'],
    size: json['size'],
  );
}
