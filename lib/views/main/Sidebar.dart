import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/utils/themeUtil.dart';
import 'package:notepad/controller/MainController.dart';

class Sidebar extends StatefulWidget {
  final MainController mainctl;
  const Sidebar({super.key, required this.mainctl});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            ThemeUtil.isDarkMode(context)
                ? null
                : LinearGradient(
                  begin: Alignment.topCenter, // 或者 Alignment.topLeft
                  end: Alignment.bottomCenter, // 或者 Alignment.bottomRight
                  colors: [
                    Color(0xFFE6E6E9), // 开始颜色
                    Color(0xFFEAE6DB), // 结束颜色
                  ],
                ),
        border: Border(
          right: BorderSide(
            color:
                ThemeUtil.isDarkMode(context)
                    ? Colors.grey.shade800
                    : Colors.grey.shade400,
            width: 1,
          ),
        ),
      ),
      width: 70,
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Teams 图标位置
          Icon(Icons.groups, color: Colors.indigo),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SidebarButton(
                  mainctl: widget.mainctl,
                  index: 0,
                  name: "聊天",
                  icon: HugeIcons.strokeRoundedComment01,
                ),
                SidebarButton(
                  mainctl: widget.mainctl,
                  index: 1,
                  name: "联系",
                  icon: HugeIcons.strokeRoundedContact01,
                ),
                SidebarButton(
                  mainctl: widget.mainctl,
                  index: 2,
                  name: "记事",
                  icon: HugeIcons.strokeRoundedNote01,
                ),
                SidebarButton(
                  mainctl: widget.mainctl,
                  index: 3,
                  name: "发现",
                  icon: HugeIcons.strokeRoundedPathfinderCrop,
                ),
                SidebarButton(
                  mainctl: widget.mainctl,
                  index: 4,
                  name: "我的",
                  icon: HugeIcons.strokeRoundedUser,
                ),
              ],
            ),
          ),
          SidebarButton(
            mainctl: widget.mainctl,
            index: 4,
            name: "设置",
            icon: HugeIcons.strokeRoundedUser,
          ),
        ],
      ),
    );
  }
}

class SidebarButton extends StatelessWidget {
  final MainController mainctl;
  final int index;
  final String name;
  final IconData icon;
  const SidebarButton({
    super.key,
    required this.mainctl,
    required this.index,
    required this.name,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = mainctl.currentIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          mainctl.setCurrentIndex(index);
        },
        child: SizedBox(
          width: 70,
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: icon,
                color: isActive ? Colors.indigo : Colors.grey.shade500,
                size: 18,
              ),
              Text(
                name,
                style: TextStyle(
                  color: isActive ? Colors.indigo : Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
