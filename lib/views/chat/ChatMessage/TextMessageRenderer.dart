import 'package:flutter/material.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class TextMessageRenderer extends AbstractMessageRenderer {
  TextMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) {
    return SelectableText(
      payload.content,
      style: TextStyle(color: messageColor(context)),
    );
  }

  static void register() {
    MessageRendererRegistry.register(
      'text',
      (payload) => TextMessageRenderer(payload),
    );
  }
}
