import 'package:flutter/material.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class QuillMessageRenderer extends AbstractMessageRenderer {
  QuillMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) {
    // TODO: implement render
    throw UnimplementedError();
  }

  static void register() {
    MessageRendererRegistry.register(
      'quill',
      (payload) => QuillMessageRenderer(payload),
    );
  }
}
