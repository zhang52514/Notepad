import 'package:flutter/material.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class ImageMessageRenderer extends AbstractMessageRenderer {
  ImageMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) {
    throw UnimplementedError();
  }

  static void register() {
    MessageRendererRegistry.register(
      'image',
      (payload) => ImageMessageRenderer(payload),
    );
  }
}
