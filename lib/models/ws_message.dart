abstract class WsMessage {
  String get type;
}

class ChatMessage extends WsMessage {
  final String from;
  final String content;

  ChatMessage({required this.from, required this.content});

  @override
  String get type => 'chat';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      from: json['from'],
      content: json['content'],
    );
  }
}

class NoticeMessage extends WsMessage {
  final String title;
  final String body;

  NoticeMessage({required this.title, required this.body});

  @override
  String get type => 'notice';

  factory NoticeMessage.fromJson(Map<String, dynamic> json) {
    return NoticeMessage(
      title: json['title'],
      body: json['body'],
    );
  }
}
