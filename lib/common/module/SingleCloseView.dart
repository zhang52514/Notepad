import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/utils/themeUtil.dart';
import 'package:window_manager/window_manager.dart';

class SingleCloseView extends StatelessWidget {
  final Widget child;
  const SingleCloseView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          ThemeUtil.isDarkMode(context) ? Colors.transparent : Color(0xFFE6E6E9),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DragToMoveArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: "关闭",
                  padding: EdgeInsets.zero,
                  hoverColor: Colors.red,
                  onPressed: () {
                    windowManager.close();
                  },
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return Colors.white;
                      }
                      return null;
                    }),
                  ),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
