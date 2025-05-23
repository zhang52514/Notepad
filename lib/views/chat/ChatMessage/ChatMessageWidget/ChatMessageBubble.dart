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
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8, // 最大不超过80%
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children:
                payload.reverse
                    ? [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                          'https://gd-filems.dancf.com/gaoding/cms/mcm79j/mcm79j/91878/c29d3bc0-0801-4ec7-a885-a52dedc3e5961503149.png',
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      SizedBox(width: 4),
                      Flexible(
                        child: BubbleWidget(
                          arrowDirection: AxisDirection.left,
                          arrowOffset: 22,
                          arrowLength: 8,
                          arrowRadius: 4,
                          arrowWidth: 14,
                          padding: const EdgeInsets.all(8),
                          borderRadius: BorderRadius.circular(4),
                          backgroundColor:
                              ThemeUtil.isDarkMode(context)
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade300,
                          contentBuilder:
                              (context) => buildMessageWidget(payload, context),
                        ),
                      ),
                    ]
                    : [
                      Flexible(
                        child: BubbleWidget(
                          arrowDirection: AxisDirection.right,
                          arrowOffset: 22,
                          arrowLength: 8,
                          arrowRadius: 4,
                          arrowWidth: 14,
                          padding: const EdgeInsets.all(8),
                          borderRadius: BorderRadius.circular(4),
                          backgroundColor: Colors.indigo,
                          contentBuilder:
                              (context) => buildMessageWidget(payload, context),
                        ),
                      ),
                      SizedBox(width: 4),
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                          'https://gd-filems.dancf.com/gaoding/cms/mcm79j/mcm79j/91878/c29d3bc0-0801-4ec7-a885-a52dedc3e5961503149.png',
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                    ],
          ),
        ),
      ),
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
