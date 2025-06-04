

import 'package:flustars/flustars.dart';
import 'package:intl/intl.dart';

class ChatMessage {
  String messageId;
  int senderId;
  int receiverId;
  String content;
  MessageStatus status;
  MessageType type;
  List<Attachment> attachments;
  int roomId;
  List<String> read;
  Map<String, dynamic> metadata;
  String timestamp;

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


  /// JSON 解析工厂方法
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // 辅助：dynamic -> int
    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    // attachments 列表解析
    List<Attachment> parseAttachments(dynamic raw) {
      if (raw is List) {
        return raw.map((e) {
          final m = e as Map<String, dynamic>;
          return Attachment(
            url: m['url'] as String? ?? '',
            name: m['name'] as String? ?? '',
            type: m['type'] as String? ?? '',
            size: parseInt(m['size']),
          );
        }).toList();
      }
      return [];
    }

    // read 字段可能是单 string，也可能是列表
    List<String> parseRead(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      if (raw != null) {
        return [raw.toString()];
      }
      return [];
    }

    // 枚举解析：int -> enum
    MessageStatus parseStatus(dynamic v) {
      final idx = parseInt(v);
      return MessageStatus.values.asMap().containsKey(idx)
          ? MessageStatus.values[idx]
          : MessageStatus.sent;
    }
    MessageType parseType(dynamic v) {
      final idx = parseInt(v);
      return MessageType.values.asMap().containsKey(idx)
          ? MessageType.values[idx]
          : MessageType.text;
    }

    return ChatMessage(
      messageId: json['messageId'].toString(),
      senderId: parseInt(json['senderId']),
      receiverId: parseInt(json['receiverId']),
      content: json['content'] as String? ?? '',
      status: parseStatus(json['status']),
      type: parseType(json['type']),
      attachments: parseAttachments(json['attachments']),
      roomId: parseInt(json['roomId']),
      read: parseRead(json['read'] ?? json['messageId']),
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>() ?? {},
      timestamp: DateUtil.formatDate(DateFormat("yyyy-MM-dd HH:mm:ss").parse(json['timestamp'] as String),format: DateFormats.h_m),
    );
  }

  @override
  String toString() {
    return 'ChatMessage{messageId: $messageId, senderId: $senderId, receiverId: $receiverId, content: $content, status: $status, type: $type, attachments: $attachments, roomId: $roomId, read: $read, metadata: $metadata}';
  }

}
class Attachment {
  String url;
  String name;
  String type;
  int size;

  Attachment({
    required this.url,
    required this.name,
    required this.type,
    required this.size,
  });

  @override
  String toString() {
    return 'Attachment{url: $url, name: $name, type: $type, size: $size}';
  }
}

enum MessageStatus { sending, sent, failed }

enum MessageType { text, file, quill , emoji }