import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mime/mime.dart';
import 'package:notepad/common/module/AnoToast.dart';
import 'package:notepad/common/module/ColorsBox.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/controller/CQController.dart';
import 'package:notepad/controller/ChatController.dart';
import 'package:notepad/views/chat/Components/ChatInputBar/AtUserListWidget.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

import '../Emoji/ChatEmojiWidget.dart';
import 'QuillCustomBuild/AtBuilder.dart';
import 'QuillCustomBuild/FileBuilder.dart';
import 'QuillCustomBuild/ImageBuilder.dart';

class ChatInputBar extends StatefulWidget {
  final ChatController chatController;

  const ChatInputBar({super.key, required this.chatController});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  ///资源管理器防抖
  bool _isPicking = false;
  Function? atClose; // 持久化引用避免重复弹窗
  Function? close;

  @override
  void initState() {
    super.initState();
    Provider.of<CQController>(context, listen: false).setupAtMentionListener();
  }

  ///toggle attribute
  void toggleAttribute(QuillController controller, Attribute attr) {
    final attrs = controller.getSelectionStyle().attributes;
    final has = attrs.containsKey(attr.key);
    controller.formatSelection(has ? Attribute.clone(attr, null) : attr);
  }

  ///Clear all attributes
  void clearAttributes(QuillController controller) {
    final attributes = <Attribute>{};
    for (final style in controller.getAllSelectionStyles()) {
      for (final attr in style.attributes.values) {
        attributes.add(attr);
      }
    }
    for (final attribute in attributes) {
      controller.formatSelection(Attribute.clone(attribute, null));
    }
  }

  ///quill buttons
  Widget quillButtons(QuillController controller) {
    Color color =
        ThemeUtil.isDarkMode(context) ? Colors.grey.shade600 : Colors.white;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: "加粗",
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: () => toggleAttribute(controller, Attribute.bold),
            icon: HugeIcon(icon: HugeIcons.strokeRoundedTextBold, size: 14),
          ),
          IconButton(
            tooltip: "斜体",
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: () {
              toggleAttribute(controller, Attribute.italic);
            },
            icon: HugeIcon(icon: HugeIcons.strokeRoundedTextItalic, size: 14),
          ),
          IconButton(
            tooltip: "下划线",
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: () => toggleAttribute(controller, Attribute.underline),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedTextUnderline,
              size: 14,
            ),
          ),
          IconButton(
            tooltip: "删除线",
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed:
                () => toggleAttribute(controller, Attribute.strikeThrough),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedTextStrikethrough,
              size: 14,
            ),
          ),
          IconButton(
            tooltip: "清除格式",
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: () => clearAttributes(controller),
            icon: HugeIcon(icon: HugeIcons.strokeRoundedTextClear, size: 14),
          ),
          Builder(
            builder: (context) {
              return IconButton(
                tooltip: "文字颜色",
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  Function? onCancel;
                  onCancel = AnoToast.showWidget(
                    context,
                    child: ColorsBox.buildColorsWidget((hex) {
                      controller.formatSelection(ColorAttribute(hex));
                      onCancel?.call();
                    }, color),
                  );
                },
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedTextColor,
                  size: 14,
                ),
              );
            },
          ),
          Builder(
            builder: (context) {
              return IconButton(
                tooltip: "背景颜色",
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  Function? onCancel;
                  onCancel = AnoToast.showWidget(
                    context,
                    child: ColorsBox.buildColorsWidget((hex) {
                      controller.formatSelection(BackgroundAttribute(hex));
                      onCancel?.call();
                    }, color),
                  );
                },
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedBackground,
                  size: 14,
                ),
              );
            },
          ),
          IconButton(
            tooltip: "左对齐",
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed:
                () => toggleAttribute(controller, Attribute.leftAlignment),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedTextAlignLeft,
              size: 14,
            ),
          ),
          IconButton(
            tooltip: "居中对齐",
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed:
                () => toggleAttribute(controller, Attribute.centerAlignment),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedTextAlignCenter,
              size: 14,
            ),
          ),
          IconButton(
            tooltip: "右对齐",
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed:
                () => toggleAttribute(controller, Attribute.rightAlignment),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedTextAlignRight,
              size: 14,
            ),
          ),
          IconButton(
            tooltip: "引用",
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: () => toggleAttribute(controller, Attribute.blockQuote),
            icon: HugeIcon(icon: HugeIcons.strokeRoundedQuoteDown, size: 14),
          ),
          IconButton(
            tooltip: "代码块",
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: () => toggleAttribute(controller, Attribute.codeBlock),
            icon: HugeIcon(icon: HugeIcons.strokeRoundedSourceCode, size: 14),
          ),
          IconButton(
            tooltip: "无序列表",
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: () => toggleAttribute(controller, Attribute.ul),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedLeftToRightListBullet,
              size: 14,
            ),
          ),
          IconButton(
            tooltip: "有序列表",
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: () => toggleAttribute(controller, Attribute.ol),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedLeftToRightListNumber,
              size: 14,
            ),
          ),
          IconButton(
            tooltip: "插入链接",
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: () => toggleAttribute(controller, Attribute.link),
            icon: HugeIcon(icon: HugeIcons.strokeRoundedLink01, size: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CQController>(
      builder: (context, CQController value, child) {
        ///@列表
        if (value.showAtSuggestion && atClose == null) {
          atClose = AnoToast.showWidgetOffset(
            child: AtUserListWidget(
              closeSelected: () {
                atClose?.call();
                atClose = null;
              },
              cqController: value,
              atUsers: widget.chatController.getRoomMembers(
                widget.chatController.authController.currentUser!.id,
              ),
            ),
            onClose: () {
              value.showAtSuggestion = false;
              value.currentMentionKeyword = '';
              atClose = null;
            },
            target: value.getCursorOffset(),
            direction: PreferDirection.topLeft,
          );
        }

        DefaultListBlockStyle listBlockStyle = DefaultListBlockStyle(
          TextStyle(fontSize: 14),
          HorizontalSpacing(0, 0),
          VerticalSpacing(6, 0),
          VerticalSpacing(6, 0),
          null,
          null,
        );
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    ThemeUtil.isDarkMode(context)
                        ? Colors.grey.shade600
                        : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                value.showQuillButtons
                    ? quillButtons(value.controller)
                    : SizedBox.shrink(),

                /// quill editor
                Container(
                  key: value.editorKey,
                  constraints: BoxConstraints(maxHeight: 200.h),
                  child: QuillEditor.basic(
                    scrollController: value.scrollController,
                    controller: value.controller,
                    config: QuillEditorConfig(
                      textSelectionThemeData: TextSelectionThemeData(
                        cursorColor:
                            ThemeUtil.isDarkMode(context)
                                ? Colors.white
                                : Colors.indigo,
                        selectionColor: Colors.blue.withValues(alpha: 0.5),
                      ),

                      customStyles: DefaultStyles(
                        leading: listBlockStyle,
                        link: TextStyle(
                          fontFamily: 'HarmonyOS',
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                        lists: listBlockStyle,
                        paragraph: DefaultTextBlockStyle(
                          TextStyle(
                            fontFamily: 'HarmonyOS',
                            fontSize: 14,
                            color:
                                ThemeUtil.isDarkMode(context)
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          HorizontalSpacing(0, 0),
                          VerticalSpacing.zero,
                          VerticalSpacing.zero,
                          null,
                        ),
                        placeHolder: DefaultTextBlockStyle(
                          TextStyle(fontSize: 14, color: Colors.grey),
                          HorizontalSpacing(0, 0),
                          VerticalSpacing(0, 0),
                          VerticalSpacing(0, 0),
                          null,
                        ),
                      ),
                      scrollBottomInset: 10,
                      scrollable: true,
                      placeholder: "输入消息",
                      autoFocus: true,
                      padding: const EdgeInsets.all(8),
                      embedBuilders: [
                        ImageBuilder(),
                        AtBuilder(),
                        FileBuilder(controller: value.controller),
                      ],
                    ),
                  ),
                ),

                /// toolbar
                Container(
                  height: 30.h,
                  padding: EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Builder(
                        builder: (context) {
                          return IconButton(
                            tooltip: "表情及符号",
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              close = AnoToast.showWidget(
                                context,
                                direction: PreferDirection.topCenter,
                                child: ChatEmojiWidget(
                                  cqController: value,
                                  closeSelected: () {
                                    close?.call();
                                  },
                                ),
                              );
                            },
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedRelieved02,
                              size: 18,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: "图片",
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        onPressed: () async {
                          if (_isPicking) return; // 阻止多次点击
                          setState(() => _isPicking = true);
                          try {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(
                                  allowMultiple: true,
                                  type: FileType.custom,
                                  allowedExtensions: [
                                    'jpg',
                                    'jpeg',
                                    'png',
                                    'gif',
                                    'bmp',
                                    'webp',
                                  ],
                                );
                            if (result != null) {
                              List<File> files =
                                  result.paths
                                      .map((path) => File(path!))
                                      .toList();
                              for (var file in files) {
                                final filePath = file.path;
                                final String fileName = p.basename(filePath);
                                final int fileSize = file.lengthSync();

                                final String? mimeType = lookupMimeType(
                                  filePath,
                                );
                                // 如果无法识别，可以给一个默认值
                                final String fileType =
                                    mimeType ?? 'application/octet-stream';
                                value.insertEmbedAtCursor("image", {
                                  "url": filePath,
                                  "name": fileName,
                                  "type": fileType,
                                  "size": fileSize,
                                });
                              }
                            }
                          } catch (e) {
                            print("选择图片失败: $e");
                          } finally {
                            setState(() => _isPicking = false);
                          }
                        },
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedImage02,
                          size: 18,
                        ),
                      ),
                      IconButton(
                        tooltip: "文件",
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        onPressed: () async {
                          if (_isPicking) return; // 阻止多次点击
                          setState(() => _isPicking = true);
                          try {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(allowMultiple: true);
                            if (result != null) {
                              List<File> files =
                                  result.paths
                                      .map((path) => File(path!))
                                      .toList();
                              for (var file in files) {
                                final filePath = file.path;
                                final String fileName = p.basename(filePath);
                                final int fileSize = file.lengthSync();

                                final String? mimeType = lookupMimeType(
                                  filePath,
                                );
                                // 如果无法识别，可以给一个默认值
                                final String fileType =
                                    mimeType ?? 'application/octet-stream';
                                value.insertEmbedAtCursor("file", {
                                  "url": filePath,
                                  "name": fileName,
                                  "type": fileType,
                                  "size": fileSize,
                                });
                              }
                            }
                          } catch (e) {
                            print("选择图片失败: $e");
                          } finally {
                            setState(() => _isPicking = false);
                          }
                        },
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedFiles02,
                          size: 18,
                        ),
                      ),
                      IconButton(
                        tooltip: "更多格式",
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        onPressed: () => value.setQuillButtons(),
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedAdd01,
                          size: 18,
                        ),
                      ),
                      VerticalDivider(),
                      IconButton(
                        tooltip: "发送",
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          // final String json = jsonEncode(
                          //   value.controller.document.toDelta().toJson(),
                          // );
                          widget.chatController.sendMessage(
                            value.parseDeltaToMessage(widget.chatController),
                          );
                          value.controller.replaceText(
                            0,
                            value.controller.document.length - 1,
                            '',
                            const TextSelection.collapsed(offset: 0),
                          );
                        },
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedSent,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 5.w),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
