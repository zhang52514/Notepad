import 'package:flutter/material.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class AudioMessageRenderer extends AbstractMessageRenderer {
  AudioMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) {
    throw UnimplementedError();
  }

  static void register() {
    MessageRendererRegistry.register(
      'audio',
      (payload) => AudioMessageRenderer(payload),
    );
  }
}
