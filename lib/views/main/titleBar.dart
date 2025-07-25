import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/domain/ChatUser.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/controller/AuthController.dart';
import 'package:notepad/controller/MainController.dart';
import 'package:notepad/views/main/mainBody.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../common/module/AvatarWidget.dart';

class TitleBar extends StatefulWidget {
  final String title;
  final MainController mainCtl;

  const TitleBar({super.key, required this.title, required this.mainCtl});

  @override
  State<TitleBar> createState() => TitleBarState();
}

class TitleBarState extends State<TitleBar> {
  final btnStyle = ButtonStyle(
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    Color btnColor= ThemeUtil.isDarkMode(context)
        ? Colors.white
        : Colors.grey.shade800;
    // 监听窗口最大化和还原
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor:
            ThemeUtil.isDarkMode(context) ? Colors.transparent : Color(0xFFE6E6E9),
        title: Text(widget.title, style: TextStyle(fontSize: 14)),
        actions: [
          buildUserInfo(),
          SizedBox(width: 10),
          IconButton(
            tooltip: "最小化",
            padding: EdgeInsets.zero,
            onPressed: () {
              windowManager.minimize();
            },
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSolidLine01,
              color: btnColor,
              size: 16,
            ),
            style: btnStyle,
          ),
          widget.mainCtl.extended
              ? IconButton(
                tooltip: "还原",
                padding: EdgeInsets.zero,
                onPressed: () {
                  windowManager.unmaximize();
                },
                style: btnStyle,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedChangeScreenMode,
                  color: btnColor,
                  size: 18,
                ),
              )
              : IconButton(
                tooltip: "最大化",
                padding: EdgeInsets.zero,
                onPressed: () {
                  windowManager.maximize();
                },
                style: btnStyle,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedSquare,
                  color: btnColor,
                  size: 16,
                ),
              ),
          IconButton(
            tooltip: "关闭",
            padding: EdgeInsets.zero,
            hoverColor: Colors.red,
            onPressed: () {
              windowManager.hide();
            },
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return Colors.white;
                }
                return btnColor;
              }),
            ),
            icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, size: 18),
          ),
          const SizedBox(width: 8),
        ],
        flexibleSpace: const DragToMoveArea(child: SizedBox.expand()),
      ),
      body: Mainbody(mainctl: widget.mainCtl),
    );
  }

  Widget buildUserInfo() {
    ChatUser? user = context.read<AuthController>().currentUser;
    if (user == null) {
      return IconButton(
        onPressed: null,
        icon: HugeIcon(icon: HugeIcons.strokeRoundedUserCircle02),
      );
    }
    return Builder(
      builder: (context) {
        return Tooltip(
          message: "${user.nickname} 已登录",
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
            child: AvatarWidget(url: user.avatarUrl),
          ),
        );
      },
    );
  }
}
