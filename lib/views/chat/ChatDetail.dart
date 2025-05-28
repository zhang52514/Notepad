import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/domain/ChatMessage.dart';
import 'package:notepad/common/module/AnoToast.dart';
import 'package:notepad/common/utils/themeUtil.dart';
import 'package:notepad/controller/CQController.dart';
import 'package:notepad/views/chat/ChatMessage/ChatMessageWidget/ChatMessageBubble.dart';
import 'package:notepad/views/chat/ChatMessage/ChatMessageWidget/MessagePayload.dart';
import 'package:notepad/views/chat/Components/ChatEmojiWidget.dart';
import 'package:notepad/views/chat/Components/ChatInputBar/AtUserListWidget.dart';
import 'package:notepad/views/chat/Components/ChatInputBar/QuillCustomBuild/AtBuilder.dart';
import 'package:notepad/views/chat/Components/ChatInputBar/QuillCustomBuild/FileBuilder.dart';
import 'package:provider/provider.dart';

import 'Components/ChatInputBar/QuillCustomBuild/ImageBuilder.dart';

class ChatDetail extends StatefulWidget {
  const ChatDetail({super.key});

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Color? color =
        ThemeUtil.isDarkMode(context) ? Color(0xFF292929) : Colors.white;
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
            icon: HugeIcon(icon: HugeIcons.strokeRoundedUserMultiple, size: 18),
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
      body: ListView.builder(
        itemCount: 2,
        padding: EdgeInsets.only(left: 10.w, right: 10.w),
        itemBuilder: (context, index) {
          MessagePayload payload = MessagePayload(
            type: index == 1 ? 'quill' : 'text',
            reverse: index % 2 == 0,
            content:
                '[{"insert":"\\n\\n\\n\\n\\n超级市场你参考才能\\n\\n\\n\\n\\n城市客车  撒擦\\n\\n场景四\\n\\n\\nCsiro\\nJIC\\n\\n"},{"insert":{"image":"C:\\\\Users\\\\Administrator\\\\Downloads\\\\no image L size.png"}},{"insert":"\\n"},{"insert":{"file":"C:\\\\Users\\\\Administrator\\\\Downloads\\\\2025年团建相关注意事项通知.pdf"}},{"insert":"\\n"},{"insert":{"file":"C:\\\\Users\\\\Administrator\\\\Downloads\\\\OM.apk"}},{"insert":"\\n"},{"insert":{"image":"C:\\\\Users\\\\Administrator\\\\Downloads\\\\壁纸3.png"}},{"insert":"\\n"},{"insert":{"image":"C:\\\\Users\\\\Administrator\\\\Downloads\\\\top_bottom_new.jpg"}},{"insert":"\\n⏰🐕😃💼\\n\\n承诺书基础上\\n\\n"},{"insert":{"at":"data6"}},{"insert":"\\n@"},{"insert":{"at":"data5"}},{"insert":"\\n\\n"}]',
            extra: {'value': 'data3'},
          );
          return ChatMessageBubble(payload: payload);
        },
      ),
      endDrawer: Padding(
        padding: EdgeInsets.only(top: 50),
        child: Drawer(
          surfaceTintColor: Colors.transparent,
          backgroundColor: color,
          width: 80.w,
          child: Center(child: Text("data")),
        ),
      ),
      bottomNavigationBar: ChatInputBar()
    );
  }
}

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key});

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

  @override
  Widget build(BuildContext context) {
    late Function close;
    late Function atClose;
    return Consumer<CQController>(
      builder: (context, CQController value, child) {
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

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w,vertical: 4.h),
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
                        paragraph: DefaultTextBlockStyle(
                          TextStyle(
                            fontSize: 14,
                            color:
                                ThemeUtil.isDarkMode(context)
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          HorizontalSpacing(0, 0),
                          VerticalSpacing(6, 0),
                          VerticalSpacing(6, 0),
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
                      padding: const EdgeInsets.all(4),
                      embedBuilders: [
                        ImageBuilder(),
                        AtBuilder(),
                        FileBuilder(controller: value.controller),
                      ],
                    ),
                  ),
                ),
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
                        onPressed: () {},
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
                          final String json = jsonEncode(
                            value.controller.document.toDelta().toJson(),
                          );
                          ChatMessage msg = value.parseDeltaToMessage();
                          // value.parseDeltaToMessage()
                          print(json);
                          print(msg);
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
