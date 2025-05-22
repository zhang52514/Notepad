import 'package:flutter/material.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class TextMessageRenderer extends AbstractMessageRenderer {
  TextMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) {
    return Text(
      payload.content,
      style: TextStyle(color: payload.reverse ? Colors.black : Colors.white),
    );
  }

  static void register() {
    MessageRendererRegistry.register(
      'text',
      (payload) => TextMessageRenderer(payload),
    );
  }
}
