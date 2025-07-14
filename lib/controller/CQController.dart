import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:notepad/controller/ChatController.dart';

import '../common/domain/ChatEnumAll.dart';
import '../common/domain/ChatMessage.dart';

class CQController extends ChangeNotifier {
  ///Quill 控制器
  final GlobalKey editorKey = GlobalKey();
  final QuillController _controller = QuillController.basic();
  final ScrollController scrollController = ScrollController();
  QuillController get controller => _controller;

  String currentMentionKeyword = '';

  ///
  /// 插入文本
  void insertTextAtCursor(String text) {
    final offset = _controller.selection.baseOffset;
    if (offset < 0) return;
    _controller.replaceText(
      offset,
      0,
      text,
      TextSelection.collapsed(offset: offset + text.length),
    );
  }

  ///
  /// 添加组件
  void insertEmbedAtCursor(String type, Map<String, dynamic> data) {
    final offset = _controller.selection.baseOffset;
    if (offset < 0) return;
    final embed = BlockEmbed(type, jsonEncode(data));
    _controller.replaceText(
      offset,
      0,
      embed,
      TextSelection.collapsed(offset: offset + 1),
    );
  }

  ///
  /// @ 删除用户输入@符号
  void deleteEmbedAtCursor() {
    final offset = _controller.selection.baseOffset;
    if (offset < 0) return;
    _controller.replaceText(
      offset - 1,
      1,
      '',
      TextSelection.collapsed(offset: offset),
    );
  }

  ///
  /// 显示@组件
  ///
  bool showAtSuggestion = false;

  ///
  /// 监听@组件显示
  ///
  // void setupAtMentionListener() {
  //   _controller.document.changes.listen((event) {
  //     final selection = _controller.selection;

  //     // 光标未聚焦或无效时不处理
  //     if (!selection.isValid || !selection.isCollapsed) return;

  //     final offset = selection.baseOffset;
  //     final plainText = _controller.document.toPlainText();

  //     // 光标在首位或越界，直接返回
  //     if (offset <= 0 || offset > plainText.length) return;

  //     // 取得光标前一个字符
  //     final char = plainText[offset - 1];

  //     // 如果是中文拼音组合输入中，char 可能为空字符，需过滤
  //     if (char.trim().isEmpty) return;

  //     final isAtChar = char == '@';

  //     // 避免重复通知
  //     if (isAtChar != showAtSuggestion) {
  //       showAtSuggestion = isAtChar;

  //       // 异步通知监听者更新 UI
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         notifyListeners();
  //       });
  //     }
  //   });
  // }

  void setupAtMentionListener() {
    _controller.document.changes.listen((event) {
      final selection = _controller.selection;
      // 光标未聚焦或无效时不处理
      if (!selection.isValid || !selection.isCollapsed) return;

      final offset = selection.baseOffset;
      final plainText = _controller.document.toPlainText();

      if (offset <= 0 || offset > plainText.length) return;

      final beforeCursor = plainText.substring(0, offset);
      int atIndex = beforeCursor.lastIndexOf('@');

      if (atIndex == -1) {
        // 没有@符号，只隐藏建议框，但光标保持正常
        if (showAtSuggestion || currentMentionKeyword.isNotEmpty) {
          showAtSuggestion = true;
          currentMentionKeyword = '';
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        }
        return;
      }

      final keyword = beforeCursor.substring(atIndex + 1);
      if (keyword.isNotEmpty && !showAtSuggestion) {
        return;
      }
      // 含非法字符（空格、标点等） 或者 长度过长，视为非法
      final illegal =
          keyword.contains(RegExp(r'[^\u4e00-\u9fa5\w]')) ||
          keyword.length > 20;
      if (illegal || keyword.isEmpty) {
        showAtSuggestion = true;
        currentMentionKeyword = '';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return;
      }

      // 如果有@ 但是已经关闭了  不显示框子 可以直接删除关键字

      // 一切正常
      showAtSuggestion = true;
      currentMentionKeyword = keyword;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    });
  }

  Offset getCursorOffset() {
    final selection = controller.selection;
    if (!selection.isValid || !selection.isCollapsed) return Offset.zero;

    final context = editorKey.currentContext;
    if (context == null) return Offset.zero;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return Offset.zero;

    RenderObject? renderEditor;
    void findEditor(RenderObject? node) {
      if (node is RenderEditor) {
        renderEditor = node;
        return;
      }
      node?.visitChildren(findEditor);
    }

    findEditor(renderBox);

    if (renderEditor is! RenderEditor) return Offset.zero;

    final endpoints = (renderEditor! as RenderEditor).getEndpointsForSelection(
      TextSelection.collapsed(offset: selection.baseOffset),
    );

    if (endpoints.isEmpty) return Offset.zero;

    final caretOffset = endpoints.first.point;

    final scrollOffset = scrollController.offset;

    final localOffset = Offset(
      caretOffset.dx - 10,
      caretOffset.dy - scrollOffset - 20,
    );

    return renderBox.localToGlobal(localOffset);
  }

  bool showQuillButtons = false;

  void setQuillButtons() {
    showQuillButtons = !showQuillButtons;
    notifyListeners();
  }

  /// 解析富文本内容为 ChatMessage 实例
  ChatMessage parseDeltaToMessage(ChatController value) {
    final List<Operation> ops =
        _controller.document.toDelta().toList(); // 直接使用传入的 value.document
    final buffer = StringBuffer();
    final List<Attachment> attachments = [];
    final Map<String, dynamic> metadata = {};
    bool hasText = false;
    bool isAllEmoji = true;
    bool hasImage = false; // 新增标记，用于判断是否包含图片
    bool hasFile = false; // 新增标记，用于判断是否包含文件（非图片）
    bool hasOtherEmbed = false; // 新增标记，用于判断是否包含其他嵌入内容（如@at）

    for (final op in ops) {
      final data = op.data;

      if (data is String) {
        //去除前后空格
        String text = data.toString().trim();
        if (text.isNotEmpty && text != "") {
          // 确保是实际的文本内容
          if (!isPureEmoji(text)) {
            isAllEmoji = false;
          }
          hasText = true;
          buffer.write(text);
        }
      } else if (data is Map) {
        if (data.containsKey('image')) {
          hasImage = true; // 标记包含图片
          final dynamic imageData = data['image'];
          Map<String, dynamic> imageProps = {};
          if (imageData is String) {
            try {
              imageProps = jsonDecode(imageData) as Map<String, dynamic>; // 对内层 JSON 字符串进行解码
            } catch (e) {
              imageProps['url'] = imageData;
            }
          } else if (imageData is Map) {
            imageProps = imageData.cast<String, dynamic>(); // 如果已经是 Map，直接用
          }
          attachments.add(
            Attachment(
              url: imageProps['url'] ?? '', // 从解析后的 Map 中获取
              type: imageProps['type'] ?? 'image/png',
              name: imageProps['name'] ?? '',
              size: int.tryParse(imageProps['size']?.toString() ?? '') ?? 0,
            ),
          );
        } else if (data.containsKey('file')) {
          hasFile = true; // 标记包含文件
          final dynamic fileData = data['file'];
          Map<String, dynamic> fileProps = {};
          if (fileData is String) {
            try {
              fileProps = jsonDecode(fileData) as Map<String, dynamic>; // 对内层 JSON 字符串进行解码
            } catch (e) {
              fileProps['url'] = fileData;
            }
          } else if (fileData is Map) {
            fileProps = fileData.cast<String, dynamic>(); // 如果已经是 Map，直接用
          }
          attachments.add(
            Attachment(
              url: fileProps['url'] ?? '', // 从解析后的 Map 中获取
              type: fileProps['type'] ?? 'image/png',
              name: fileProps['name'] ?? '',
              size: int.tryParse(fileProps['size']?.toString() ?? '') ?? 0,
            ),
          );
        } else if (data.containsKey('at')) {
          hasOtherEmbed = true; // 标记包含其他嵌入内容
          metadata['at'] = '${data['at']}';
        }
        // 可以添加其他嵌入内容的解析
      }
    }

    final content = buffer.toString().trim();

    // 判断最终消息类型
    MessageType messageType;
    if (!hasImage && !hasFile && !hasOtherEmbed && isAllEmoji && hasText) {
      // 纯表情消息：没有嵌入内容，全是表情，且有文本内容（表情也算文本）
      messageType = MessageType.emoji;
    } else if (!hasImage && !hasFile && !hasOtherEmbed && hasText) {
      // 纯文本消息：没有嵌入内容，只有文本
      messageType = MessageType.text;
    } else if (hasImage && !hasText && !hasFile && !hasOtherEmbed) {
      // 纯图片消息：只有图片，没有文本和其他文件/嵌入内容
      messageType = MessageType.image;
    } else if (hasFile && !hasText && !hasImage && !hasOtherEmbed) {
      // 纯文件消息：只有文件，没有文本、图片和其他嵌入内容
      messageType = MessageType.file;
    } else if (attachments.isNotEmpty || hasOtherEmbed || hasText) {
      // 富文本消息：包含图片/文件/其他嵌入内容或混合文本
      messageType = MessageType.quill;
    } else {
      // 默认或未知类型
      messageType = MessageType.quill;
    }

    // 构造 ChatMessage 实例
    final chatMsg = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: value.authController.currentUser!.id,
      receiverId: value.determineReceiverId(value.authController.currentUser!.id),
      content: content,
      status: MessageStatus.sent,
      type: messageType,
      attachments: attachments,
      roomId: value.chatRoom.roomId,
      read: [],
      metadata: metadata,
      timestamp: DateTime.now(),
    );

    // 如果为富文本，保存原始 delta json
    if (messageType == MessageType.quill) {
      chatMsg.content = jsonEncode(
        _controller.document.toDelta().toJson(),
      ); // 直接使用传入的 value.document
    }

    return chatMsg;
  }



  ///
  /// 判断是否是纯emoji
  bool isPureEmoji(String input) {
    final trimmed = input.trim(); // 移除换行符和空格
    // Emoji Unicode 范围匹配
    final emojiRegex = RegExp(
      r"^([\u203C-\u3299]|[\uD83C-\uDBFF\uDC00-\uDFFF])+?$",
      unicode: true,
    );
    return emojiRegex.hasMatch(trimmed);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
