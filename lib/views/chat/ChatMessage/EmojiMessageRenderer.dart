import 'package:flutter/material.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class EmojiMessageRenderer extends AbstractMessageRenderer {
  EmojiMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) {
    return Text(payload.content,style: TextStyle(fontSize: 38),);
  }

  static void register() {
    MessageRendererRegistry.register(
      'emoji',
      (payload) => EmojiMessageRenderer(payload),
    );
  }
}
