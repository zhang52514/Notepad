import 'package:flutter/material.dart';
import 'package:notepad/common/module/bubbleDialog.dart';
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
    return FractionallySizedBox(
      alignment: payload.reverse ? Alignment.centerLeft : Alignment.centerRight,
      widthFactor: 0.8,
      child: BubbleWidget(
        arrowDirection:
            payload.reverse ? AxisDirection.left : AxisDirection.right,
        arrowOffset: 22,
        arrowLength: 8,
        arrowRadius: 4,
        arrowWidth: 14,
        padding: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(4),
        backgroundColor: payload.reverse ? Colors.grey.shade200 : Colors.indigo,
        contentBuilder: (context) {
          return buildMessageWidget(payload, context);
        },
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
