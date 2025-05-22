import 'package:flutter/material.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class LinkMessageRenderer extends AbstractMessageRenderer {
  LinkMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) {
    // TODO: implement render
    throw UnimplementedError();
  }

  static void register() {
    MessageRendererRegistry.register(
      'link',
      (payload) => LinkMessageRenderer(payload),
    );
  }
}
