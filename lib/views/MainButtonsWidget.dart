import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// 主窗口的按钮
/// 主要用于最小化、最大化、关闭窗口
class MainButtonsWidget extends StatelessWidget {
  final bool extended;

  const MainButtonsWidget({super.key, required this.extended});


  @override
  Widget build(BuildContext context) {
    final btnStyle = ButtonStyle(
      shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
    );
    return Row(
      children: [
        IconButton(
          tooltip: "最小化",
          padding: EdgeInsets.zero,
          onPressed: () {
            windowManager.minimize();
          },
          icon: const Icon(CupertinoIcons.minus, size: 18),
          style: btnStyle,
        ),
        extended
            ? IconButton(
              tooltip: "还原",
              padding: EdgeInsets.zero,
              onPressed: () {
                windowManager.unmaximize();
              },
              style: btnStyle,
              icon: const Icon(CupertinoIcons.rectangle_on_rectangle, size: 18),
            )
            : IconButton(
              tooltip: "最大化",
              padding: EdgeInsets.zero,
              onPressed: () {
                windowManager.maximize();
              },
              style: btnStyle,
              icon: const Icon(CupertinoIcons.app, size: 18),
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
                return Colors.white; // 悬停时的颜色
              }
              return null;
            }),
          ),
          icon: const Icon(CupertinoIcons.clear, size: 20),
        ),
      ],
    );
  }
}
