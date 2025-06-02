
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
  final bool reverse;
  // 可选的附加数据（用于特定渲染器）
  final Map<String, dynamic> extra;

  MessagePayload( {
    required this.name,
    required this.time,
    required this.avatar,
    required this.type,
    required this.content,
    required this.reverse,
    this.extra = const {},
  });

  T? get<T>(String key) {
    final value = extra[key];
    if (value is T) return value;
    return null;
  }
}
