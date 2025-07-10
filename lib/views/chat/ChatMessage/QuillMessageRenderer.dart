import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notepad/views/chat/ChatMessage/AbstractMessageRenderer.dart';

import '../Components/ChatInputBar/QuillCustomBuild/AtBuilder.dart';
import '../Components/ChatInputBar/QuillCustomBuild/FileBuilder.dart';
import '../Components/ChatInputBar/QuillCustomBuild/ImageBuilder.dart';

class QuillMessageRenderer extends AbstractMessageRenderer {
  // 1. 将 _controller 声明为 final，并在构造函数中初始化
  // 这样每个 QuillMessageRenderer 实例都有自己的控制器，避免重复创建
  final QuillController _controller = QuillController.basic();

  QuillMessageRenderer(super.payload);

  @override
  Widget render(BuildContext context) { // 将 render 方法更名为 build，更符合Flutter Widget生命周期
    // 设置为只读模式
    _controller.readOnly = true;

    // 尝试解析消息内容
    try {
      _controller.document = Document.fromJson(jsonDecode(payload.content));
    } catch (e, stack) { // 捕获堆栈信息，方便调试
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
          selectionColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
        customStyles: DefaultStyles(
          paragraph: DefaultTextBlockStyle(
            TextStyle(fontSize: 14, color: messageColor(context)), // 段落文本颜色根据主题动态设置
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(0, 0),
            const VerticalSpacing(0, 0),
            null,
          ),
        ),
        embedBuilders: [
          ImageBuilder(),
          AtBuilder(),
          FileBuilder(),
        ],
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