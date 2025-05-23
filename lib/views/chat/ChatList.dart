import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notepad/common/module/VibratingBadge.dart';
import 'package:notepad/common/utils/DateUtil.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/controller/ChatController.dart';

/// 聊天列表
/// ListView + ListTile
class Chatlist extends StatefulWidget {
  final ChatController value;
  const Chatlist({super.key, required this.value});

  @override
  State<Chatlist> createState() => _ChatlistState();
}

class _ChatlistState extends State<Chatlist> {
  @override
  Widget build(BuildContext context) {
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
              Expanded(child: Text("data")),
              IconButton(icon: const Icon(Icons.add), onPressed: () {}),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: widget.value.scrollController,
            itemCount: 50,
            itemBuilder:
                (context, index) => Padding(
                  padding: EdgeInsets.only(left: 2.w, right: 7.w),
                  child: ListTile(
                    visualDensity: VisualDensity.compact,
                    key: ValueKey(widget.value.isScrolling),
                    selected: widget.value.selectIndex == index,
                    selectedColor: Colors.white,
                    selectedTileColor: Colors.indigo,
                    hoverColor:
                        widget.value.isScrolling
                            ? Colors.transparent
                            : Colors.indigo.shade300,
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        'https://gd-filems.dancf.com/gaoding/cms/mcm79j/mcm79j/91878/c29d3bc0-0801-4ec7-a885-a52dedc3e5961503149.png',
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    title: Text(
                      "项目 ${index + 1}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(fontSize: 13),
                    ),
                    subtitle: Text(
                      "项目 ${index + 1} 的描述的描述的描述的描述的描述的描述的描述的描述的描述的描述的描述的描述的描述的描述的描述",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(fontSize: 11),
                    ),
                    trailing: Column(
                      children: [
                        Expanded(
                          child: Text(
                            DateUtil.formatTime(DateTime.now()),
                            style: TextStyle(
                              color:
                                  ThemeUtil.isDarkMode(context)
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ),
                        ),
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
}
