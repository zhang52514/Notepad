import 'package:flutter/material.dart';
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
      bottomNavigationBar: Container(child: ChatInputBar(), color: color),
    );
  }
}

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: '键入消息',
                border: InputBorder.none,
                isCollapsed: true,
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.image_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
          const VerticalDivider(width: 16, thickness: 1),
          IconButton(icon: const Icon(Icons.send), onPressed: () {}),
        ],
      ),
    );
  }
}
