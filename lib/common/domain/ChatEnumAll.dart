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
  file, //纯文件
  image,//纯图片
  audio,//音频
  video,//视频
  quill, // 富文本（富内容）
  emoji,//表情
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

extension MessageStatusExtension on MessageStatus {
  String get label {
    switch (this) {
      case MessageStatus.sending:
        return "发送中";
      case MessageStatus.sent:
        return "已发送";
      case MessageStatus.delivered:
        return "已送达";
      case MessageStatus.read:
        return "已读";
      case MessageStatus.failed:
        return "发送失败";
      }
  }
}

///
/// ChatUser
///

enum ChatUserRole {
  owner, // 群主
  admin, // 管理员
  member, // 普通成员
}

enum Cmd { chat, http, auth }

enum HttpPath { getRooms, getUsers, getHistory }
