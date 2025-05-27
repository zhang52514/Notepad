import 'package:flutter/material.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class FileMessageRenderer extends AbstractMessageRenderer {
  FileMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) {
    throw UnimplementedError();
  }

  static void register() {
    MessageRendererRegistry.register(
      'file',
      (payload) => FileMessageRenderer(payload),
    );
  }
}
