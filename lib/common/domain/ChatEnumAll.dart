///
/// ChatRoom
///
enum ChatRoomType {
  single, //SINGLE   私聊
  group, //GROUP     群组
  ai, //   AI
}

enum ChatRoomStatus {
  normal, // 正常
  muted, // 全员禁言
  blocked, // 封禁（例如被举报）
  deleted, // 解散
}

///
/// ChatMessage
///
enum MessageType {
  text,
  file,
  image,
  audio,
  video,
  quill, // 富文本（富内容）
  emoji,
  system, // 系统通知
  aiReply, // AI回复（特化处理）
}

enum MessageStatus {
  sending, // 消息正在发送（客户端已发出但未收到服务端ACK）
  sent, // 消息已成功发送到服务端
  delivered, //消息已成功送达接收者
  read, //消息已被接收者阅读
  failed, // 消息发送失败（需重试）
}

///
/// ChatUser
///

enum ChatUserRole {
  owner, // 群主
  admin, // 管理员
  member, // 普通成员
}

