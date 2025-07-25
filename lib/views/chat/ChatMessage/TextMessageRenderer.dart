import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';
import 'package:notepad/views/chat/Components/ChatInputBar/QuillCustomBuild/AtBuilder.dart';
import 'package:notepad/views/chat/Components/ChatInputBar/QuillCustomBuild/FileBuilder.dart';
import 'package:notepad/views/chat/Components/ChatInputBar/QuillCustomBuild/ImageBuilder.dart';

class TextMessageRenderer extends AbstractMessageRenderer {
  TextMessageRenderer(super.payload);
  final QuillController _controller = QuillController.basic();
  @override
  Widget render(BuildContext context) {
    // 设置为只读模式
    _controller.readOnly = true;

    // 尝试解析消息内容
    try {
      // 1. 获取纯文本内容
      String plainText = payload.content;
      final quillContentJson = [
        {'insert': '$plainText\n'}, // 添加一个换行符，确保文本末尾有光标位置
      ];
      _controller.document = Document.fromJson(quillContentJson);
    } catch (e, stack) {
      // 捕获堆栈信息，方便调试
      debugPrint('QuillMessageRenderer 格式化错误：$e\n$stack'); // 输出更详细的错误信息
      return SelectableText(
        "消息格式解析错误，无法显示。", // 更友好的错误提示
        style: TextStyle(
          color: Theme.of(context).colorScheme.error, // 使用主题的错误颜色，更醒目
          fontWeight: FontWeight.bold,
          fontSize: 14, // 适当的字体大小
        ),
      );
    }

    return QuillEditor.basic(
      config: QuillEditorConfig(
        showCursor: false,
        textSelectionThemeData: TextSelectionThemeData(
          selectionColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.3),
        ),
        customStyles: DefaultStyles(
          paragraph: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 14,
              color: messageColor(context),
            ), // 段落文本颜色根据主题动态设置
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(0, 0),
            const VerticalSpacing(0, 0),
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
      'text',
      (payload) => TextMessageRenderer(payload),
    );
  }
}
