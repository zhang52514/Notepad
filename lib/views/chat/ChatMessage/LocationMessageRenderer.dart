import 'package:flutter/material.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

class LocationMessageRenderer extends AbstractMessageRenderer {
  LocationMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) {
    // TODO: implement render
    throw UnimplementedError();
  }

  static void register() {
    MessageRendererRegistry.register(
      'location',
      (payload) => LocationMessageRenderer(payload),
    );
  }
}
