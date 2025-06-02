import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/module/VibratingBadge.dart';
import 'package:notepad/common/utils/DateUtil.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/controller/ChatController.dart';

/// 聊天列表
/// ListView + ListTile
class ChatList extends StatefulWidget {
  final ChatController value;

  const ChatList({super.key, required this.value});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    int count = widget.value.getRoomCount();
    return Column(
      children: [
        Container(
          color:
              ThemeUtil.isDarkMode(context)
                  ? Colors.black12
                  : Color(0xFFE6E6E9),
          height: 50.h,
          child: Row(
            children: [
              Expanded(child: Text(widget.value.getMessagesForRoom().length.toString())),
              IconButton(icon: const Icon(Icons.add), onPressed: () {}),
            ],
          ),
        ),
        count == 0
            ? Expanded(child: Center(child: Text("暂无数据")))
            : Expanded(
              child: ListView.builder(
                controller: widget.value.scrollChatListController,
                itemCount: widget.value.getRoomCount(),
                itemBuilder:
                    (context, index) => Padding(
                      padding: EdgeInsets.only(left: 2.w, right: 7.w),
                      child: ListTile(
                        visualDensity: VisualDensity.compact,
                        key: ValueKey(widget.value.isScrolling),
                        selected: widget.value.selectIndex == index,
                        selectedColor: Colors.white,
                        selectedTileColor: Colors.indigo.shade500,
                        hoverColor:
                            widget.value.isScrolling
                                ? Colors.transparent
                                : Colors.indigo.shade400,
                        leading: _buildAvatar(widget.value.getRoom(index).roomAvatar),
                        title: Text(
                          widget.value.getRoom(index).roomName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          widget.value.getRoom(index).roomLastMessage,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontSize: 11),
                        ),
                        trailing: Column(
                          children: [
                            Text(
                              DateUtil.formatTime(widget.value.getRoom(index).roomLastMessageTime),
                              style: TextStyle(
                                color:
                                    widget.value.selectIndex == index
                                        ? Colors.white
                                        : Colors.grey.shade900,
                              ),
                            ),
                            Expanded(child: SizedBox.shrink()),
                            VibratingBadge(messageCount: index),
                          ],
                        ),
                        onTap: () => widget.value.setSelectIndex(index),
                      ),
                    ),
              ),
            ),
      ],
    );
  }

  Widget _buildAvatar(String url) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: 40,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => HugeIcon(icon: HugeIcons.strokeRoundedLoading03),
        errorWidget:
            (_, __, ___) => Center(
              child: HugeIcon(icon: HugeIcons.strokeRoundedImageNotFound01),
            ),
      ),
    );
  }
}
