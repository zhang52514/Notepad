import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../views/chat/Components/ChatInputBar/QuillCustomBuild/ImageBuilder.dart';

class CQController extends ChangeNotifier {

  final QuillController _controller = QuillController.basic();

  QuillController get controller => _controller;

  void insertTextAtCursor(String text) {
    final offset = controller.selection.baseOffset;
    if (offset < 0) return;
    controller.replaceText(
      offset,
      0,
      text,
      TextSelection.collapsed(offset: offset + text.length),
    );
  }
  void insertEmbedAtCursor(String type, String url) {
    final offset = controller.selection.baseOffset;
    if (offset < 0) return;
    final embed = BlockEmbed(type,url);
    controller.replaceText(
      offset,
      0,
      embed,
      TextSelection.collapsed(offset: offset + 1),
    );
  }
}
