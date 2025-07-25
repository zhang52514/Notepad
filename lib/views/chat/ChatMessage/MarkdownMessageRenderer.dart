import 'package:flutter/src/widgets/framework.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class MarkdownMessageRenderer extends AbstractMessageRenderer {
  MarkdownMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) {
    // TODO: implement render
    throw UnimplementedError();
  }

  static void register() {
    MessageRendererRegistry.register(
      'markdown',
      (payload) => MarkdownMessageRenderer(payload),
    );
  }
}
