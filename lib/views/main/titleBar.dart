import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/controller/MainController.dart';
import 'package:notepad/views/main/mainBody.dart';
import 'package:window_manager/window_manager.dart';

class Titlebar extends StatefulWidget {
  final String title;
  final MainController mainctl;
  const Titlebar({super.key, required this.title, required this.mainctl});

  @override
  State<Titlebar> createState() => TitlebarState();
}

class TitlebarState extends State<Titlebar> {
  final btnStyle = ButtonStyle(
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    // 监听窗口最大化和还原
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            ThemeUtil.isDarkMode(context) ? null : Color(0xFFE6E6E9),
        title: Text(widget.title, style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            tooltip: "最小化",
            padding: EdgeInsets.zero,
            onPressed: () {
              windowManager.minimize();
            },
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSolidLine01,
              color: Colors.grey.shade500,
              size: 16,
            ),
            style: btnStyle,
          ),
          widget.mainctl.extended
              ? IconButton(
                tooltip: "还原",
                padding: EdgeInsets.zero,
                onPressed: () {
                  windowManager.unmaximize();
                },
                style: btnStyle,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedMinimizeScreen,
                  color: Colors.grey.shade500,
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
                  icon: HugeIcons.strokeRoundedMaximizeScreen,
                  color: Colors.grey.shade500,
                  size: 18,
                ),
              ),
          IconButton(
            tooltip: "关闭",
            padding: EdgeInsets.zero,
            hoverColor: Colors.red,
            onPressed: () {
              windowManager.close();
            },
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return Colors.white;
                }
                return null;
              }),
            ),
            icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, size: 18),
          ),
          const SizedBox(width: 8),
        ],
        flexibleSpace: const DragToMoveArea(child: SizedBox.expand()),
      ),
      body: Mainbody(mainctl: widget.mainctl),
    );
  }
}
