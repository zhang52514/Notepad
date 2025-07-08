import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

import '../Components/ChatInputBar/QuillCustomBuild/AtBuilder.dart';
import '../Components/ChatInputBar/QuillCustomBuild/FileBuilder.dart';
import '../Components/ChatInputBar/QuillCustomBuild/ImageBuilder.dart';

class QuillMessageRenderer extends AbstractMessageRenderer {
  QuillMessageRenderer(super.payload);

  final QuillController _controller = QuillController.basic();

  @override
  Widget render(BuildContext context) {
    _controller.readOnly = true;

    try {
      _controller.document = Document.fromJson(jsonDecode(payload.content));
    } catch (e) {
      debugPrint('格式化错误：$e');
      return SelectableText(
        "消息格式解析错误!",
        style: TextStyle(
          color: Colors.amberAccent,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return QuillEditor.basic(
      config: QuillEditorConfig(
        showCursor: false,
        textSelectionThemeData: TextSelectionThemeData(
          selectionColor: Colors.blue.withValues(alpha: 0.5),
        ),
        customStyles: DefaultStyles(
          paragraph: DefaultTextBlockStyle(
            TextStyle(fontSize: 14, color: Colors.white),
            HorizontalSpacing(0, 0),
            VerticalSpacing(0, 0),
            VerticalSpacing(0, 0),
            null,
          ),
        ),
        embedBuilders: [ImageBuilder(), AtBuilder(), FileBuilder()],
      ),
      controller: _controller,
    );
  }

  static void register() {
    MessageRendererRegistry.register(
      'quill',
      (payload) => QuillMessageRenderer(payload),
    );
  }
}
