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
      if(keyword.isNotEmpty && !showAtSuggestion){
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
  final List<Operation> ops = _controller.document.toDelta().toList();
  final buffer = StringBuffer();
  final List<Attachment> attachments = [];
  final Map<String, dynamic> metadata = {};
  bool hasText = false;
  bool isAllEmoji = true;
  bool hasEmbed = false;

  for (final op in ops) {
    final data = op.data;

    if (data is String) {
      if (!isPureEmoji(data)) {
        isAllEmoji = false;
      }
      hasText = true;
      buffer.write(data);
    } else if (data is Map) {
      hasEmbed = true;
      if (data.containsKey('image')) {
        attachments.add(Attachment(
          url: data['image'],
          type: 'image/png',
          name: '',
          size: 12563,
        ));
      } else if (data.containsKey('file')) {
        attachments.add(Attachment(
          url: data['file'],
          type: 'application/pdf',
          name: '',
          size: 122153,
        ));
      } else if (data.containsKey('at')) {
        metadata['at'] = '${data['at']}';
      }
    }
  }

  final content = buffer.toString().trim();

  // 判断最终消息类型
  MessageType messageType;
  if (!hasEmbed && isAllEmoji && hasText) {
    messageType = MessageType.emoji;
  } else if (!hasEmbed && hasText) {
    messageType = MessageType.text;
  } else if (attachments.isNotEmpty && !hasText) {
    messageType = MessageType.file;
  } else {
    messageType = MessageType.quill;
  }

  // 构造 ChatMessage 实例
  final chatMsg = ChatMessage(
    messageId: DateTime.now().millisecondsSinceEpoch.toString(),
    senderId: value.authController.currentUser!.id,
    receiverId: _determineReceiverId(value),
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
    chatMsg.content = jsonEncode(_controller.document.toDelta().toJson());
  }

  return chatMsg;
}


  /// 根据房间类型确定接收者 ID
  /// 私聊：取第一个非当前用户的成员 ID
  /// 群聊：房间 ID 解析为整数
  String _determineReceiverId(ChatController controller) {
    final room = controller.chatRoom;
    if (room.roomType == ChatRoomType.group) {
      return room.roomId;
    }
    // 私聊场景：安全取除自己外的成员
    // 找到“不等于当前 uid” 的那个成员
    final otherId = room.memberIds.firstWhere(
      (memberId) => memberId != controller.authController.currentUser!.id,
      orElse: () => '',
    );
    return otherId;
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
