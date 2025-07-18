import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/domain/ChatEnumAll.dart';
import 'package:notepad/common/domain/ChatMessage.dart';
import 'package:notepad/common/domain/ChatUser.dart';

class LastMessagePreview extends StatelessWidget {
  final ChatMessage? lastMessage;
  final ChatUser? currentUser; // 当前登录用户
  final ChatUser Function(String senderId) getUserById; // 获取用户信息的函数
  final Color textColor;

  const LastMessagePreview({
    super.key,
    required this.lastMessage,
    required this.currentUser,
    required this.getUserById,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (lastMessage == null) {
      return const SizedBox.shrink();
    }

    String contentText = "";
    IconData? icon;

    // 获取发送者昵称
    String senderNickname = "";
    if (lastMessage!.senderId != currentUser?.id) {
      // 如果不是当前用户发送的
      ChatUser sender = getUserById(lastMessage!.senderId);
      senderNickname = "${sender.nickname}: "; // 添加昵称和冒号
    } else {
      senderNickname = "你: "; // 如果是自己发送的，显示“你”
    }

    int attachmentCount = lastMessage!.attachments.length;
    String attachmentCountStr =
        attachmentCount > 1 ? "$attachmentCount个" : ""; // 优化数量显示

    switch (lastMessage!.type) {
      case MessageType.text:
      case MessageType.emoji: // emoji 也可以直接显示内容
        contentText = "$senderNickname${lastMessage!.content}";
        icon = HugeIcons.strokeRoundedBubbleChatTranslate; // 文本图标
        break;
      case MessageType.file:
        contentText = "$senderNickname[ 文件$attachmentCountStr ]";
        icon = HugeIcons.strokeRoundedFileAttachment; // 文件图标
        break;
      case MessageType.image:
        contentText = "$senderNickname[ 图片$attachmentCountStr ]";
        icon = HugeIcons.strokeRoundedImage01; // 图片图标
        break;
      case MessageType.audio:
        contentText = "$senderNickname[ 语音 ]";
        icon = HugeIcons.strokeRoundedAudioWave01; // 语音图标
        break;
      case MessageType.video:
        contentText = "$senderNickname[ 视频$attachmentCountStr ]";
        icon = HugeIcons.strokeRoundedVideoReplay; // 视频图标
        break;
      case MessageType.quill: // Quill富文本消息，可以考虑显示为 [消息] 或截取部分内容
        contentText = "$senderNickname[ 消息 ]"; // 如果富文本内容不方便直接显示，就用通用提示
        icon = HugeIcons.strokeRoundedQuillWrite01; // 消息/文档图标
        break;
      case MessageType.system:
        contentText = "[ 通知 ] ${lastMessage!.content}"; // 系统通知通常不需要发送者
        icon = HugeIcons.strokeRoundedInstallingUpdates01; // 通知图标
        break;
      case MessageType.aiReply:
        contentText = "[ AI ] ${lastMessage!.content}"; // AI 回复
        icon = HugeIcons.strokeRoundedBot; // AI 图标
        break;
      case MessageType.videoCall:
        contentText = "$senderNickname[ 通话请求 ]"; // 通话请求
        icon = HugeIcons.strokeRoundedCall02;
      case MessageType.videoAnswer:
        contentText = "$senderNickname[ 通话中 ]"; // 通话中
        icon = HugeIcons.strokeRoundedCall02;
      case MessageType.videoReject:
        contentText = "$senderNickname[ 通话拒绝 ]"; // 通话拒绝
        icon = HugeIcons.strokeRoundedCall02;
      case MessageType.videoHangup:
        contentText = "$senderNickname[ 通话结束 ]"; // 通话结束
        icon = HugeIcons.strokeRoundedCall02;
      case MessageType.signal:
        contentText = "$senderNickname[ 连接中 ]"; // 连接中
        icon = HugeIcons.strokeRoundedCall02;
    }

    return Row(
      mainAxisSize: MainAxisSize.min, // 尽可能小地占据空间
      children: [
        // 如果有图标，则显示
        HugeIcon(
          icon: icon,
          size: 14, // 图标大小与文字匹配
          color: textColor.withValues(alpha: 0.7), // 图标颜色稍微浅一点
        ),
        SizedBox(width: 4), // 如果有图标，给一点间距
        Expanded(
          // 使用 Expanded 确保文本在必要时截断
          child: Text(
            contentText,
            overflow: TextOverflow.ellipsis, // 文本溢出时显示省略号
            maxLines: 1, // 只显示一行
            style: TextStyle(
              fontSize: 11, // 字体大小
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
