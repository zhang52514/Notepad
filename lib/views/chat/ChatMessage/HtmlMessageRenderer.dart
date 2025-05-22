import 'package:flutter/material.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class HtmlMessageRenderer extends AbstractMessageRenderer {
  HtmlMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) {
    // TODO: implement render
    throw UnimplementedError();
  }

  static void register() {
    MessageRendererRegistry.register(
      'html',
      (payload) => HtmlMessageRenderer(payload),
    );
  }
}
