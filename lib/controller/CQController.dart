import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:notepad/controller/ChatController.dart';

import '../common/domain/ChatEnumAll.dart';
import '../common/domain/ChatMessage.dart';
import '../common/domain/ChatRoom.dart';

class CQController extends ChangeNotifier {
  ///Quill 控制器
  final QuillController _controller = QuillController.basic();

  QuillController get controller => _controller;

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
  void insertEmbedAtCursor(String type, String url) {
    final offset = _controller.selection.baseOffset;
    if (offset < 0) return;
    final embed = BlockEmbed(type, url);
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
  void setupAtMentionListener() {
    _controller.addListener(() {
      final offset = _controller.selection.baseOffset;
      final plainText = _controller.document.toPlainText();
      if (offset <= 0 || offset > plainText.length) return;

      final char = plainText[offset - 1];
      if (char == '@') {
        if (!showAtSuggestion) {
          showAtSuggestion = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        }
      } else {
        if (showAtSuggestion) {
          showAtSuggestion = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        }
      }
    });
  }

  bool showQuillButtons = false;

  void setQuillButtons() {
    showQuillButtons = !showQuillButtons;
    notifyListeners();
  }

  ///
  /// 解析富文本到消息
  ChatMessage parseDeltaToMessage(ChatController value) {
    final List<Operation> ops = _controller.document.toDelta().toList();
    final buffer = StringBuffer();
    final List<Attachment> attachments = [];
    final Map<String, dynamic> metadata = {};
    bool isEmoji = false;
    for (final op in ops) {
      ///纯文本消息
      if (op.data is String) {
        ///是否是emoji
        isEmoji = isPureEmoji(op.data.toString());
        buffer.write(op.data);
      } else if (op.data is Map) {
        ///嵌入组件 image
        final embedded = op.data as Map;
        if (embedded.containsKey('image')) {
          attachments.add(
            Attachment(
              url: embedded['image'],
              type: 'image/png',
              name: '',
              size: 12563,
            ),
          );
        } else if (embedded.containsKey('file')) {
          ///嵌入组件 file
          attachments.add(
            Attachment(
              url: embedded['file'],
              type: 'application/pdf',
              name: '',
              size: 122153,
            ),
          );
        } else if (embedded.containsKey('at')) {
          ///嵌入组件 @组件
          metadata["at"] = '@${embedded['at']}';
        }
      }
    }

    final chatMsg = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: value.authController.currentUser!.id,
      // receiverId: _determineReceiverId(value),
       receiverId: "_determineReceiverId(value)",
      content: buffer.toString().trim(),
      status: MessageStatus.sent,
      type:
          attachments.isEmpty
              ? isEmoji
                  ? MessageType.emoji
                  : MessageType.text
              : (buffer.toString().trim().isEmpty
                  ? MessageType.file
                  : MessageType.quill),
      attachments: attachments,
      roomId: value.chatRoom.roomId,
      read: [],
      metadata: metadata,
      timestamp: DateTime.now(),
    );

    if (chatMsg.type == MessageType.quill) {
      chatMsg.content = jsonEncode(_controller.document.toDelta().toJson());
      print(chatMsg.content);
    }
    return chatMsg;
  }
  /// 根据房间类型确定接收者 ID
  /// 私聊：取第一个非当前用户的成员 ID
  /// 群聊：房间 ID 解析为整数
  String _determineReceiverId(ChatController controller) {
    // final room = controller.chatRoom;
    // if (room.roomType == RoomType.group) {
    //   // 假设 roomId 可转为整数，否则返回 -1
    //   return int.tryParse(room.roomId) ?? -1;
    // }
    // // 私聊场景：安全取除自己外的成员
    // return room.memberIds.firstWhere(
    //       (id) => id != controller.authController.currentUser!.uid,
    //   orElse: () => -1,  // 如果没有找到，就返回 -1
    // );
    return "";
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
