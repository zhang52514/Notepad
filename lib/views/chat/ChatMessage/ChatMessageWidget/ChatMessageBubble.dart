import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notepad/common/module/bubbleDialog.dart';
import 'package:notepad/common/utils/themeUtil.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';
import 'package:notepad/views/chat/ChatMessage/ChatMessageWidget/MessagePayload.dart';

/// 消息气泡框
/// [ChatMessageBubble] 消息气泡框
/// [MessagePayload] 消息数据
class ChatMessageBubble extends StatelessWidget {
  final MessagePayload payload;

  const ChatMessageBubble({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: payload.reverse ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          crossAxisAlignment:
              payload.reverse
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (payload.reverse) ...[SizedBox(width: 35)],
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                    children: [
                      TextSpan(text: payload.reverse?payload.name:payload.time),
                      TextSpan(text: "  "),
                      TextSpan(text: payload.reverse?payload.time:payload.name),
                    ],
                  ),
                ),
                if (!payload.reverse) ...[SizedBox(width: 35)],
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (payload.reverse) ...[_buildAvatar(), SizedBox(width: 4)],
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.5,
                    ),
                    child: IntrinsicWidth(
                      child: BubbleWidget(
                        arrowDirection:
                            payload.reverse
                                ? AxisDirection.left
                                : AxisDirection.right,
                        arrowOffset: 22,
                        arrowLength: 8,
                        arrowRadius: 4,
                        arrowWidth: 14,
                        padding: const EdgeInsets.all(8),
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor:
                            !payload.reverse
                                ? Colors.indigo
                                : ThemeUtil.isDarkMode(context)
                                ? Colors.grey.shade600
                                : Colors.grey.shade300,
                        contentBuilder:
                            (context) => buildMessageWidget(payload, context),
                      ),
                    ),
                  ),
                ),
                if (!payload.reverse) ...[SizedBox(width: 4), _buildAvatar()],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return const CircleAvatar(
      radius: 18,
      backgroundImage: NetworkImage(
        'https://gd-filems.dancf.com/gaoding/cms/mcm79j/mcm79j/91878/c29d3bc0-0801-4ec7-a885-a52dedc3e5961503149.png',
      ),
      backgroundColor: Colors.transparent,
    );
  }

  /// 根据消息类型构建消息组件
  /// [payload] 消息数据
  /// [context] 上下文
  /// [return] 消息组件
  Widget buildMessageWidget(MessagePayload payload, BuildContext context) {
    final renderer = MessageRendererRegistry.fromType(payload);
    return renderer.render(context);
  }
}
