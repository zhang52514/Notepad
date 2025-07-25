import 'package:notepad/common/domain/ChatEnumAll.dart';
import 'package:notepad/common/domain/ChatMessage.dart';

///
/// ChatMessage 载体
///   渲染用
///
class MessagePayload {
  final String name;
  final String time;
  final String avatar;
  final String type;
  final String content;

  final MessageStatus status;

  /// 是否反转（是否为当前用户发送）true=左边 false=右边
  final bool reverse;
  // 可选的附加数据（用于特定渲染器）
  final Map<String, dynamic> extra;
  final Map<String, dynamic> metadata;
  final List<Attachment> attachments;

  MessagePayload({
    required this.name,
    required this.time,
    required this.avatar,
    required this.type,
    required this.content,
    required this.status,
    required this.reverse,
    required this.metadata,
    required this.attachments,
    this.extra = const {},
  });

  T? get<T>(String key) {
    final value = extra[key];
    if (value is T) return value;
    return null;
  }
}
