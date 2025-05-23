import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/utils/themeUtil.dart';
import 'package:notepad/views/chat/ChatMessage/ChatMessageWidget/ChatMessageBubble.dart';
import 'package:notepad/views/chat/ChatMessage/ChatMessageWidget/MessagePayload.dart';

class Chatdeatil extends StatefulWidget {
  const Chatdeatil({super.key});

  @override
  State<Chatdeatil> createState() => _ChatdeatilState();
}

class _ChatdeatilState extends State<Chatdeatil> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Color? color =
        ThemeUtil.isDarkMode(context) ? Color(0xFF424242) : Colors.white;
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
        itemCount: 10,
        padding: EdgeInsets.only(left: 10.w, right: 10.w),
        itemBuilder: (context, index) {
          MessagePayload payload = MessagePayload(
            type: "text",
            reverse: index % 2 == 0,
            content: "Hello$index",
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
      bottomNavigationBar: Container(
        height: 120.h,
        color: color,
        child: Padding(padding: EdgeInsets.all(10), child: ChatInputBar()),
      ),
    );
  }
}

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final QuillController controller = QuillController.basic();
  @override
  Widget build(BuildContext context) {
    return Container(
    
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
        children: [
          Expanded(
            child: QuillEditor.basic(
              controller: controller,
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
                placeholder: "输入消息",
                autoFocus: true,
                padding: const EdgeInsets.all(10),
              ),
            ),
          ),
          Container(
            height: 30.h,
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: "发送",
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  alignment: Alignment.bottomCenter,
                  onPressed: () {},
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedSent, size: 18),
                ),
                IconButton(
                  tooltip: "发送",
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  alignment: Alignment.bottomCenter,
                  onPressed: () {},
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedSent, size: 18),
                ),
                IconButton(
                  tooltip: "发送",
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  alignment: Alignment.bottomCenter,
                  onPressed: () {},
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedSent, size: 18),
                ),
                SizedBox(width: 5.w),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
