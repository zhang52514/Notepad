import 'package:flutter/material.dart';
import 'package:notepad/common/domain/ChatEnumAll.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/views/chat/ChatMessage/ChatMessageWidget/MessagePayload.dart';
import 'package:notepad/views/chat/ChatMessage/TextMessageRenderer.dart';

abstract class AbstractMessageRenderer {
  final MessagePayload payload;

  AbstractMessageRenderer(this.payload);

  Widget render(BuildContext context);

  Color messageColor(BuildContext context) {
    Color reverseColor =
        ThemeUtil.isDarkMode(context) ? Colors.white70: Colors.black;
    return payload.reverse ? reverseColor : Colors.white.withValues(alpha: 0.9);
  }
}

typedef MessageRendererBuilder =
    AbstractMessageRenderer Function(MessagePayload payload);

class MessageRendererRegistry {
  static final Map<String, MessageRendererBuilder> _registry = {};

  static void register(String type, MessageRendererBuilder builder) {
    _registry[type.toLowerCase()] = builder;
  }

  static AbstractMessageRenderer fromType(MessagePayload payload) {
    final builder = _registry[payload.type.toLowerCase()];
    if (builder != null) {
      return builder(payload);
    } else {
      return TextMessageRenderer(
        MessagePayload(
          avatar: '',
          name: payload.name,
          time: payload.time,
          status: MessageStatus.sent,
          type: 'text',
          reverse: true,
          content: '暂不支持的消息类型: ${payload.type}',
          metadata: payload.metadata,
          attachments: payload.attachments
        ),
      );
    }
  }
}
