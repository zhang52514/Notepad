import 'package:flutter/material.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class EmptyMessageRenderer extends AbstractMessageRenderer {
   EmptyMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) => const SizedBox.shrink();

  static void register() {
    MessageRendererRegistry.register(
      'video',
      (payload) => EmptyMessageRenderer(payload),
    );
  }
}
