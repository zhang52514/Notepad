
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notepad/common/domain/ChatEnumAll.dart'; // 假设包含 ChatMessageType, MessageStatus 等枚举
import 'package:notepad/common/module/bubbleDialog.dart'; // 您的气泡组件
import 'package:notepad/common/utils/themeUtil.dart'; // 您的主题工具类
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';
import 'package:notepad/views/chat/ChatMessage/ChatMessageWidget/MessagePayload.dart';

import '../../../../common/module/AvatarWidget.dart'; // 您的头像组件

/// 消息气泡框
/// [ChatMessageBubble] 消息气泡框
/// [MessagePayload] 消息数据
class ChatMessageBubble extends StatelessWidget {
  final MessagePayload payload;

  const ChatMessageBubble({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    // 判断消息是否由当前用户发送
    final bool isCurrentUser = !payload.reverse;

    // 根据发送方设置 Column 的主轴对齐方式（时间/名称和气泡整体的对齐）
    final CrossAxisAlignment columnCrossAxisAlignment =
        isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    // 根据发送方设置 Row 的主轴对齐方式（头像和气泡的对齐）

    // 根据主题动态调整颜色
    final bool isDarkMode = ThemeUtil.isDarkMode(context);
    final Color timeNameColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600; // 时间名称颜色更柔和
    final Color currentUserBubbleColor = isDarkMode?Colors.black87:Colors.indigo; // 我方气泡颜色使用主题主色
    final Color otherUserBubbleColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200; // 对方气泡颜色，深色/浅色适配

    // 定义哪些消息类型需要气泡包裹
    // 这里保持您原有的逻辑，只有 quill 和 text 类型才包裹气泡
    final bool needsBubble = payload.type == MessageType.quill.name || payload.type == MessageType.text.name;


    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft, // 消息整体左右对齐
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // 增加左右外边距，让消息不那么贴边
        child: Column(
          crossAxisAlignment: columnCrossAxisAlignment, // 时间和消息整体的对齐方式
          mainAxisSize: MainAxisSize.min, // Column 宽度自适应内容
          children: [
            // --- 消息时间 + 名称 ---
            // 为了让时间名称与气泡内容对齐，将其包裹在 Padding 中
            // 考虑头像的宽度 (40w) + 间距 (4w)，总共 44w 的偏移量
            Padding(
              padding: isCurrentUser
                  ? EdgeInsets.only(right: 44) // 我方消息，右侧头像+间距的宽度
                  : EdgeInsets.only(left: 44), // 对方消息，左侧头像+间距的宽度
              child: Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 10, color: timeNameColor),
                  children: [
                    // 我方消息显示状态和时间
                    if (isCurrentUser) ...[
                      TextSpan(text: payload.status.label), // 例如：已读、未读
                      const TextSpan(text: "  "), // 间距
                      TextSpan(text: payload.time),
                    ],
                    // 对方消息显示名称和时间
                    if (!isCurrentUser) ...[
                      TextSpan(text: payload.name),
                      const TextSpan(text: "  "), // 间距
                      TextSpan(text: payload.time),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 4.h), // 时间名称与气泡之间的垂直间距

            // --- 消息气泡框或直接内容 ---
            Row(
              mainAxisSize: MainAxisSize.min, // Row 宽度自适应内容
              crossAxisAlignment: CrossAxisAlignment.start, // 确保头像和气泡顶部对齐
              children: [
                // 对方头像
                if (!isCurrentUser) ...[
                  _buildAvatar(payload.avatar),
                  SizedBox(width: 4), // 头像和气泡之间的间距，保持与您原有的 4 相同
                ],

                // 消息内容区域
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      // 保持您原有的 maxWidth
                      maxWidth: MediaQuery.of(context).size.width * 0.4,
                    ),
                    // IntrinsicWidth 在这里可能导致性能问题，但在您明确要求下保留
                    // 它可以强制其子 Widget 的宽度收缩到最小
                    child: IntrinsicWidth(
                      child: needsBubble
                          ? BubbleWidget(
                              arrowDirection: isCurrentUser ? AxisDirection.right : AxisDirection.left,
                              arrowOffset: 20, // 箭头偏移量
                              arrowLength: 6, // 箭头长度
                              arrowRadius: 3, // 箭头圆角
                              arrowWidth: 17, // 箭头宽度
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10), // 气泡内边距，保持您原有的值
                              borderRadius: BorderRadius.circular(8), // 气泡主体圆角，稍微调整使其更美观
                              backgroundColor: isCurrentUser ? currentUserBubbleColor : otherUserBubbleColor,
                              contentBuilder: (context) => _buildMessageContent(context),
                            )
                          : _buildMessageContent(context), // 非气泡消息直接渲染内容
                    ),
                  ),
                ),

                // 我方头像
                if (isCurrentUser) ...[
                  SizedBox(width: 4), // 气泡和头像之间的间距
                  _buildAvatar(payload.avatar),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建头像 Widget
  Widget _buildAvatar(String url) {
    return AvatarWidget(
      url: url,
    );
  }

  /// 根据消息类型构建消息组件
  /// [payload] 消息数据
  /// [context] 上下文
  /// [return] 消息组件
  Widget _buildMessageContent(BuildContext context) { // 修改为私有方法
    final renderer = MessageRendererRegistry.fromType(payload);
    return renderer.render(context);
  }
}