import 'package:flutter/material.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class VideoMessageRenderer extends AbstractMessageRenderer {
  VideoMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) {
    // TODO: implement render
    throw UnimplementedError();
  }

  static void register() {
    MessageRendererRegistry.register(
      'video',
      (payload) => VideoMessageRenderer(payload),
    );
  }
}
