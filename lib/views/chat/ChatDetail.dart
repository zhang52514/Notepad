import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/domain/ChatEnumAll.dart';
import 'package:notepad/common/domain/ChatMessage.dart';
import 'package:notepad/common/domain/ChatRoom.dart';
import 'package:notepad/common/domain/ChatUser.dart';
import 'package:notepad/common/utils/themeUtil.dart';
import 'package:notepad/controller/ChatController.dart';
import 'package:notepad/views/chat/ChatMessage/ChatMessageWidget/ChatMessageBubble.dart';
import 'package:notepad/views/chat/ChatMessage/ChatMessageWidget/MessagePayload.dart';
import 'package:notepad/views/chat/Components/ChatInputBar.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../common/utils/DateUtil.dart';

class ChatDetail extends StatefulWidget {
  const ChatDetail({super.key});

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
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
        //未选择任何ChatRoom
        if (value.chatRoom == null) {
          return Center(child: Text("欢迎"));
        }
        //当前选择的ChatRoom
        ChatRoom room = value.chatRoom;
        //获取当前房间的所有消息
        List<ChatMessage> chatMessages = value.getMessagesForRoom();

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: color,
          //头部信息
          appBar: AppBar(
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            actionsPadding: EdgeInsets.zero,
            backgroundColor: color,
            title: Text(room.roomName),
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
          //内容
          body: () {
            //如果消息列表为空 显示提示
            if (chatMessages.isEmpty) {
              return Center(child: Text("暂无数据"));
            }
            //获取当前用户
            ChatUser user = value.authController.currentUser!;

            //有数据 开始构建ChatListView
            return ScrollablePositionedList.builder(
              reverse: true,
              padding: EdgeInsets.only(left: 10.w, right: 10.w),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                //获取消息
                final msg = chatMessages[index];
                //判断是不是自己
                bool isMe = msg.senderId == user.id;

                ChatUser u = value.getUser(msg.senderId);

                MessagePayload payload = MessagePayload(
                  name: u.nickname,
                  type: msg.type.name,
                  reverse: !isMe,
                  avatar: u.avatarUrl,
                  content: msg.content,
                  extra: {'value': 'data3'},
                  time:
                      msg.timestamp != null
                          ? DateUtil.formatTime(msg.timestamp!)
                          : '',
                );
                return ChatMessageBubble(payload: payload);
              },
              itemScrollController: value.itemScrollController,
              itemPositionsListener: value.itemPositionsListener,
            );
          }(),
          //固定跳转
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
