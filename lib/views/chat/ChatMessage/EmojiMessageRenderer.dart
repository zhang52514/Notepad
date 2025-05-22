import 'package:flutter/material.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class EmojiMessageRenderer extends AbstractMessageRenderer {
  EmojiMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) {
    // TODO: implement render
    throw UnimplementedError();
  }

  static void register() {
    MessageRendererRegistry.register(
      'emoji',
      (payload) => EmojiMessageRenderer(payload),
    );
  }
}
