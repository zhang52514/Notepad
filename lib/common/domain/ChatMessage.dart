

class ChatMessage {
  String messageId;
  String senderId;
  String receiverId;
  String content;
  MessageStatus status;
  MessageType type;
  List<Attachment> attachments;
  String roomId;
  List<String> read;
  Map<String, dynamic> metadata;

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
  });

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