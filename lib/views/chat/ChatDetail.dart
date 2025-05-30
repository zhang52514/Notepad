import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/domain/ChatMessage.dart';
import 'package:notepad/common/module/AnoToast.dart';
import 'package:notepad/common/module/ColorsBox.dart';
import 'package:notepad/common/utils/themeUtil.dart';
import 'package:notepad/controller/CQController.dart';
import 'package:notepad/controller/ChatController.dart';
import 'package:notepad/views/chat/ChatMessage/ChatMessageWidget/ChatMessageBubble.dart';
import 'package:notepad/views/chat/ChatMessage/ChatMessageWidget/MessagePayload.dart';
import 'package:notepad/views/chat/Components/ChatEmojiWidget.dart';
import 'package:notepad/views/chat/Components/ChatInputBar/AtUserListWidget.dart';
import 'package:notepad/views/chat/Components/ChatInputBar/QuillCustomBuild/AtBuilder.dart';
import 'package:notepad/views/chat/Components/ChatInputBar/QuillCustomBuild/FileBuilder.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'Components/ChatInputBar/QuillCustomBuild/ImageBuilder.dart';

class ChatDetail extends StatefulWidget {
  final String roomId;

  const ChatDetail({super.key, required this.roomId});

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<ChatMessage> chatMessages = [];

  @override
  void initState() {
    super.initState();
    debugPrint("ChatDetail initState");
    final ctl = Provider.of<ChatController>(context, listen: false);
    ctl.itemPositionsListener.itemPositions.addListener(() {
      final positions = ctl.itemPositionsListener.itemPositions.value;

      if (positions.isEmpty) return; // 防止空列表报错

      final minIndex = positions
          .where((item) => item.itemLeadingEdge >= 0)
          .fold<int?>(
            null,
            (min, item) => min == null || item.index < min ? item.index : min,
          );

      final maxIndex = positions.fold<int?>(
        null,
        (max, item) => max == null || item.index > max ? item.index : max,
      );

      debugPrint('Visible range: ${minIndex ?? "?"} ~ ${maxIndex ?? "?"}');
    });
  }

  @override
  Widget build(BuildContext context) {
    Color? color =
        ThemeUtil.isDarkMode(context) ? Color(0xFF292929) : Colors.white;
    return Consumer<ChatController>(
      builder: (context, ChatController value, child) {
        chatMessages = value.getMessagesForRoom(widget.roomId);
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: color,
          appBar: AppBar(
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            actionsPadding: EdgeInsets.zero,
            backgroundColor: color,
            title: Text("Saikoune"),
            actions: [
              IconButton(
                onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedUserMultiple,
                  size: 18,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedMoreHorizontal,
                  size: 18,
                ),
              ),
            ],
          ),
          body: () {
            if (chatMessages.isEmpty) {
              return Center(child: Text("暂无数据"));
            }
            // return ListView.builder(
            //   reverse: true,
            //   itemCount: chatMessages.length,
            //   padding: EdgeInsets.only(left: 10.w, right: 10.w),
            //   itemBuilder: (context, index) {
            //     final msg = chatMessages[index];
            //
            //     MessagePayload payload = MessagePayload(
            //       type: msg.type.name,
            //       reverse: msg.senderId == 'admin',
            //       content: msg.content,
            //       extra: {'value': 'data3'},
            //     );
            //
            //     return ChatMessageBubble(payload: payload);
            //   },
            // );
            return ScrollablePositionedList.builder(
              reverse: true,
              padding: EdgeInsets.only(left: 10.w, right: 10.w),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final msg = chatMessages[index];

                MessagePayload payload = MessagePayload(
                  name: msg.senderId == 'admin' ? 'Saikoune' : 'admin',
                  type: msg.type.name,
                  reverse: index % 2 == 0,
                  content: msg.content,
                  extra: {'value': 'data3'},
                  time: index % 2 == 0 ? '13:23' : '13:56',
                );

                return ChatMessageBubble(payload: payload);
              },
              itemScrollController: value.itemScrollController,
              itemPositionsListener: value.itemPositionsListener,
            );
          }(),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     value.itemScrollController.jumpTo(index: 180);
          //   },
          //   child: Text("80"),
          // ),
          endDrawer: Padding(
            padding: EdgeInsets.only(top: 50),
            child: Drawer(
              surfaceTintColor: Colors.transparent,
              backgroundColor: color,
              width: 80.w,
              child: Center(child: Text("data")),
            ),
          ),
          bottomNavigationBar: ChatInputBar(chatController: value),
        );
      },
    );
  }
}

class ChatInputBar extends StatefulWidget {
  final ChatController chatController;

  const ChatInputBar({super.key, required this.chatController});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  ///资源管理器防抖
  bool _isPicking = false;

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
    late Function close;
    late Function atClose;
    return Consumer<CQController>(
      builder: (context, CQController value, child) {
        ///@列表
        if (value.showAtSuggestion) {
          atClose = AnoToast.showWidget(
            context,
            child: AtUserListWidget(
              closeSelected: () {
                atClose();
              },
              cqController: value,
            ),
            onClose: () {
              value.showAtSuggestion = false;
            },
          );
        }



        DefaultListBlockStyle listBlockStyle=DefaultListBlockStyle(
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
                  constraints: BoxConstraints(maxHeight: 200.h),
                  child: QuillEditor.basic(
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
                        lists:listBlockStyle,
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
                          VerticalSpacing(6, 0),
                          VerticalSpacing(6, 0),
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
                                    close();
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
                                final path = file.path;
                                int fileSize = file.lengthSync();
                                print("图片：$fileSize=$path");
                                value.insertEmbedAtCursor("image", path);
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
                                final path = file.path;
                                int fileSize = file.lengthSync();
                                print("文件：$fileSize=$path");
                                value.insertEmbedAtCursor("file", path);
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

                          ChatMessage msg = value.parseDeltaToMessage();
                          widget.chatController.addMessage("001", msg);
                          value.controller.document = Document();
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
