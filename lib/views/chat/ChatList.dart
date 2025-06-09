import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notepad/common/module/VibratingBadge.dart';
import 'package:notepad/common/utils/DateUtil.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/controller/ChatController.dart';

import '../../common/module/AvatarWidget.dart';

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
    //获取房间数量
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
              Expanded(
                child: Text(
                  widget.value.getMessagesForRoom().length.toString(),
                ),
              ),
              IconButton(icon: const Icon(Icons.add), onPressed: () {}),
            ],
          ),
        ),
        count == 0
            ? Expanded(child: Center(child: Text("暂无数据")))
            : Expanded(
              child: ListView.builder(
                controller: widget.value.scrollChatListController,
                itemCount: count,
                itemBuilder: (context, index) {
                  var room=widget.value.getRoom(index);

                  return Padding(
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
                              : ThemeUtil.isDarkMode(context)
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.05),
                      leading: _buildAvatar(
                        room.roomAvatar,
                      ),
                      title: Text(
                        room.roomName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        room.roomLastMessage ?? '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 11),
                      ),
                      trailing: Column(
                        children: [
                          /// 时间
                          Text(
                            room.roomLastMessageTime ==
                                    null
                                ? ''
                                : DateUtil.formatTime(room.roomLastMessageTime!),
                            style: TextStyle(
                              color:
                                  widget.value.selectIndex == index
                                      ? Colors.white
                                      : Colors.grey.shade600,
                            ),
                          ),
                          Expanded(child: SizedBox.shrink()),

                          ///未读消息数量
                          VibratingBadge(
                            messageCount: widget.value.getRoomUnReadCount(
                              index,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => widget.value.setSelectIndex(index),
                    ),
                  );
                },
              ),
            ),
      ],
    );
  }

  /// 构建头像
  Widget _buildAvatar(String url) {
    return AvatarWidget(url: url);
  }
}
